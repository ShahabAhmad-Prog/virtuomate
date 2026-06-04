# On-device avatar stylizer model (optional)

Layer 1 uses **ML Kit face crop** + **CPU cartoon filter** by default (**no file needed**).

You do **not** need to run the download script before `flutter run`.

For stronger (optional) TFLite results:

```powershell
cd "D:\Virtomate Project\virtuomate_flutter"
.\tool\download_avatar_stylize_model.ps1
```

Expected path after download:

`assets/models/avatar_cartoon.tflite`

The app detects this file at runtime and prefers TFLite over the CPU fallback.
