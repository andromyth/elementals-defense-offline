# Supplying the original APK bundle to private CI

The repository is private. Keep the original bundle in a private GitHub Release asset rather than committing the 48 MB bundle to Git history.

1. Open **Releases**: https://github.com/andromyth/elementals-defense-offline/releases
2. Select **Draft a new release**.
3. Use tag `original-1.0.7`.
4. Attach the exact user-provided bundle. The workflow default asset name is `Elementals-Defense_1.0.7_apkcube (1).apks`. Rename the uploaded asset to that exact name if the browser changes it.
5. Publish the release (the repository remains private).
6. Open **Actions → Inspect original Android bundle → Run workflow**. Keep the default tag and asset name, then run.
7. Download the `elementals-inspection-reports` artifact from the completed run and share the report files in this chat.

The workflow only produces inspection reports; it does not patch or sign the game. A code patch must be based on the actual wall-health implementation and telemetry call paths found by inspection. Do not upload keystores or signing secrets.
