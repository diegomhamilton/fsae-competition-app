import AVFoundation
import SwiftUI
import UIKit

/// Optional evidence choices appear only after the judge requests a photo.
struct FocusedPhotoSourcePicker: View {
    enum Source { case camera, library }
    private enum Strings {
        static let title = "Add photo"
        static let take = "Take photo"
        static let choose = "Choose existing photo"
        static let unavailable = "A camera is not available on this device."
        static let denied = "Camera access is off. Enable it in Settings to take a photo."
        static let settings = "Open Settings"
        static let cancel = "Cancel"
    }
    let choose: (Source) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var permissionDenied = false
    @State private var requestingAccess = false
    private var cameraAvailable: Bool { UIImagePickerController.isSourceTypeAvailable(.camera) }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Button {
                    requestingAccess = true
                    Task {
                        let granted: Bool
                        switch AVCaptureDevice.authorizationStatus(for: .video) {
                        case .authorized: granted = true
                        case .notDetermined: granted = await AVCaptureDevice.requestAccess(for: .video)
                        default: granted = false
                        }
                        requestingAccess = false
                        if granted { choose(.camera) } else { permissionDenied = true }
                    }
                } label: {
                    Label(Strings.take, systemImage: "camera").frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(.borderedProminent).tint(Color.fsaePrimary)
                .disabled(!cameraAvailable || requestingAccess)
                .accessibilityIdentifier("execution.evidence.camera")
                if !cameraAvailable { Text(Strings.unavailable).font(.callout).foregroundStyle(Color.fsaeSecondaryText) }
                if permissionDenied {
                    Text(Strings.denied).font(.callout)
                    Button(Strings.settings) {
                        if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                    }
                    .frame(minHeight: 48)
                }
                Button { choose(.library) } label: {
                    Label(Strings.choose, systemImage: "photo.on.rectangle").frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(.bordered).tint(Color.fsaePrimary)
                .accessibilityIdentifier("execution.evidence.library")
                Spacer(minLength: 0)
            }
            .padding().controlSize(.large)
            .navigationTitle(Strings.title).navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button(Strings.cancel) { dismiss() } } }
        }
    }
}
