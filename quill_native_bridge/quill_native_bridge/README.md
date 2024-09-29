# 🪶 Quill Native Bridge

An internal plugin for [`flutter_quill`](https://pub.dev/packages/flutter_quill) package to access platform-specific APIs.

> [!NOTE]
> **Internal Use Only**: Exclusively for `flutter_quill`. Breaking changes may occur.

| Feature                  | iOS  | Android | macOS | Windows | Linux | Web   |
|--------------------------|------|---------|-------|---------|-------|-------|
| **isIOSSimulator**        | ✅   | ⚪      | ⚪    | ⚪      | ⚪    | ⚪    |
| **getClipboardHtml**      | ✅   | ✅      | ✅    | ✅      | ✅    | ✅    |
| **copyHtmlToClipboard**   | ✅   | ✅      | ✅    | ✅      | ✅    | ✅    |
| **copyImageToClipboard**  | ✅   | ✅      | ✅    | ❌      | ✅    | ✅    |
| **getClipboardImage**     | ✅   | ✅      | ✅    | ❌      | ✅    | ✅    |
| **getClipboardGif**       | ✅   | ✅      | ⚪    | ⚪      | ⚪    | ⚪    |

## 🔧 Platform Configuration

To support copying images to the clipboard to be accessed by other apps, you need to configure your Android project.
If not set up, a warning will appear in the log during debug mode only
if `copyImageToClipboard` was called without configuring the Android project.

> **IMPORTANT**
> This is only required on **Android** platform for this feature.
> Should be able to use other features on **Android** if `copyImageToClipboard` is not being used.

**1. Update `AndroidManifest.xml`**

Open `your_project/android/app/src/main/AndroidManifest.xml` and add the following inside the `<application>` tag:

```xml
<manifest>
    <application>
        ...
        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="${applicationId}.fileprovider"
            android:exported="false"
            android:grantUriPermissions="true" >
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/file_paths" />
        </provider>
        ...
    </application>
</manifest>
```

**2. Create `file_paths.xml`**

Create the file `your_project/android/app/src/main/res/xml/file_paths.xml` with the following content:

```xml
<paths>
    <cache-path name="cache" path="." />
</paths>
```