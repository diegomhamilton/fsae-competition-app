# Photo capture component checkpoint

Source checkpoint: the camera feature commit containing this note and both images. FocusedPhotoSourcePicker and FocusedCameraCapture replace the photo-library-only entry. The evidence storage actor moves out of Views into Services in the same commit.

Xcode 26.2 build passed. All five evidence persistence/compatibility tests passed in `/tmp/FSAE-camera-targeted.xcresult`. Camera and library sources persist actual image bytes before attachment metadata is added to a draft. Camera source survives serialization. Invalid images produce no fake attachment.

Dedicated iPhone 17 Pro / iOS 26.2 simulator, retained DerivedData, boot readiness confirmed, image gates passed, both images visually inspected:

- `01-photo-sources.png` (`-inspection-snapshot photo-sources`): the actual source sheet offers Take photo and Choose existing photo. The simulator has no camera, so capture is disabled with a clear explanation.
- `02-persisted-photo.png` (`-inspection-snapshot evidence-ready`): a real stored image file satisfies the required-photo field and exposes preview and Save & next test. This isolated image is fixture evidence, not a physical camera capture.

Capture uses the native camera with permission handling and a generated camera usage description in Debug and Release. Cancel leaves existing input intact; denied permission gives Settings access. Required evidence cannot be satisfied by mock metadata or a missing asset. A physical iPhone is needed to validate actual camera interaction; no camera hardware or touch-flow claim is made here.
