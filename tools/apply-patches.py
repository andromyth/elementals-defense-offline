#!/usr/bin/env python3
"""Apply Elementals Defense patches to a decoded apktool project.

Usage: patch.py <apktool-project-dir>

Patches:
  1. Wall fully heals after every completed wave (was +3% per wallRep level).
  2. PairIP license check is a no-op (repacked APKs otherwise get shut down).
  3. Ads and analytics are disabled in the web layer.
  4. Native telemetry (Firebase/AppMetrica) and AppLovin ad init are skipped.
  5. INTERNET, ad-ID and install-referrer permissions are removed.
  6. Ad/analytics auto-init ContentProviders are removed from the manifest.
  7. Every completed wave grants an extra 1000 gold.
  8. The Yandex interstitial wrapper invokes its completion callback
     (without this the game could hang after an ad slot).
"""
import os
import re
import sys

root = sys.argv[1] if len(sys.argv) > 1 else "decoded"
changed = []


def path(p):
    return os.path.join(root, p)


def read(p):
    with open(path(p), encoding="utf-8") as f:
        return f.read()


def write(p, s):
    with open(path(p), "w", encoding="utf-8") as f:
        f.write(s)
    changed.append(p)


def edit(p, old, new, count=1):
    s = read(p)
    n = s.count(old)
    if n != count:
        raise SystemExit(f"ERROR: {p}: expected {count} match(es), found {n}")
    write(p, s.replace(old, new))


def replace_method(p, signature, body):
    s = read(p)
    start = s.index(signature)
    end = s.index(".end method", start) + len(".end method")
    write(p, s[:start] + body + s[end:])


# ---------------------------------------------------------------- 1. wall heal
edit(
    "assets/index.html",
    'wallRepairPct()>0&&(wallHP=Math.min(wallMax,wallHP+wallMax*wallRepairPct())),bumpStat("waves")',
    'wallHP=wallMax,bumpStat("waves")',
)

# ------------------------------------------------------------- 2. wave gold
# winOrNext() is the single wave-completion handler, so this covers normal wins,
# skipped waves and the final wave of a world.
edit(
    "assets/index.html",
    "clearProjectiles(),gold+=waveEarned,worldEarned+=waveEarned,",
    "clearProjectiles(),gold+=waveEarned+1000,worldEarned+=waveEarned,",
)

# ------------------------------------------------------- 3. web ads / analytics
edit(
    "assets/gg.js",
    "window.GG_ADS_OFF=!1,window.GG_REWARDS_OFF=!1,",
    "window.GG_ADS_OFF=!0,window.GG_REWARDS_OFF=!0,",
)

# Hard override analytics and ad wrapper after the original definitions.
override = """
/* patched: ads and analytics removed */
window.GG_ADS_OFF=!0;window.GG_REWARDS_OFF=!0;
try{window.EDAM={progression:function(){},tutorial:function(){},shop:function(){},offer:function(){}}}catch(e){}
try{window.YA={sdk:function(){return null},player:function(){return null},ready:function(){},flush:function(){},restore:function(){},onCloudReady:function(){},syncGameplay:function(){},gameplayStop:function(){},paused:function(){return!1},hasAds:function(){return!1},hasPay:function(){return!1},hasCloud:function(){return!1},priceNum:function(){return null},priceLike:function(){return null},buy:function(t,e,n){try{n&&n("no-payments")}catch(x){}},buyNC:function(t,e,n){try{n&&n("no-payments")}catch(x){}},catalog:function(cb){try{cb&&cb([])}catch(x){}},rewarded:function(ok,fail){try{fail&&fail(!1)}catch(x){}},interstitial:function(cb){try{cb&&cb()}catch(x){}},cloudWipe:function(cb){try{cb&&cb()}catch(x){}}}}catch(e){}
"""
s = read("assets/gg.js")
if "patched: ads and analytics removed" not in s:
    write("assets/gg.js", s + override)

# ------------------------------------------------ 4. PairIP license check no-op
replace_method(
    "smali/com/pairip/licensecheck/LicenseClient.smali",
    ".method public static checkLicense(Landroid/content/Context;)V",
    ".method public static checkLicense(Landroid/content/Context;)V\n"
    "    .locals 0\n\n"
    "    return-void\n"
    ".end method",
)

# --------------------------------------------------------- 4b. App.init telemetry
replace_method(
    "smali_classes2/com/elementals/defence/App.smali",
    ".method public final onCreate()V",
    ".method public final onCreate()V\n"
    "    .locals 0\n\n"
    "    invoke-super {p0}, Landroid/app/Application;->onCreate()V\n\n"
    "    return-void\n"
    ".end method",
)

# ------------------------------------------------------- 4c. AppLovin/MAX init off
replace_method(
    "smali_classes2/h6/l.smali",
    ".method public final B()V",
    ".method public final B()V\n"
    "    .locals 0\n\n"
    "    return-void\n"
    ".end method",
)

# ---------------------------------------------------------- 5+6. manifest clean-up
DROP_PERMISSIONS = {
    "android.permission.INTERNET",
    "com.google.android.gms.permission.AD_ID",
    "android.permission.ACCESS_ADSERVICES_AD_ID",
    "android.permission.ACCESS_ADSERVICES_ATTRIBUTION",
    "android.permission.ACCESS_ADSERVICES_TOPICS",
    "com.google.android.finsky.permission.BIND_GET_INSTALL_REFERRER_SERVICE",
}
DROP_PROVIDERS = {
    "com.google.android.gms.ads.MobileAdsInitProvider",
    "com.yandex.mobile.ads.core.initializer.YandexAdsInitializeProvider",
    "com.applovin.sdk.AppLovinInitProvider",
    "io.appmetrica.analytics.internal.PreloadInfoContentProvider",
    "com.google.firebase.provider.FirebaseInitProvider",
    "io.bidmachine.BidMachineInitProvider",
    "com.vungle.ads.VungleProvider",
    "com.ironsource.lifecycle.IronsourceLifecycleProvider",
    "com.ironsource.lifecycle.LevelPlayActivityLifecycleProvider",
    "com.mbridge.msdk.config.component.status.MBComponentLifecycleProvider",
}
lines = read("AndroidManifest.xml").splitlines(keepends=True)
out = []
for line in lines:
    stripped = line.strip()
    if stripped.startswith("<uses-permission") and any(
        f'android:name="{p}"' in line for p in DROP_PERMISSIONS
    ):
        continue
    if stripped.startswith("<provider") and any(
        f'android:name="{p}"' in line for p in DROP_PROVIDERS
    ):
        continue
    out.append(line)
write("AndroidManifest.xml", "".join(out))

print("patched:")
for c in changed:
    print("  " + c)
