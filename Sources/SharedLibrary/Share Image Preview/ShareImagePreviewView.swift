import SwiftUI

struct ShareImagePreviewView: View {
    private let imageSize: CGFloat = 320

    let imageToBeShared: Image
    let backgroundColor: Color
    let backgroundImage: Image?
    @ObservedObject var viewModel: ShareImagePreviewViewModel

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                previewImage
                Spacer()
                ShareImageBottomSheetView(viewModel: viewModel.bottomSheetViewModel)
            }
        }
        .background(background)
        .edgesIgnoringSafeArea([.top, .bottom])
        .alert(isPresented: .constant(viewModel.error != nil), content: {
            errorAlert
        })
    }
    
    @ViewBuilder
    private var background: some View {
        if let backgroundImage {
            backgroundImage
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
        } else {
            backgroundColor
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
        }
    }

    private var previewImage: some View {
        imageToBeShared
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: imageSize, height: imageSize)
            .cornerRadius(12)
            .shadow(radius: 24)
    }

    private var errorAlert: Alert {
        let alertTitle = viewModel.error?.description ?? "unknown_description".localized
        let alertMessage = viewModel.error?.recoverySuggestion ?? "unknown_recovery_suggestion".localized

        let closeButton = Alert.Button.cancel(Text("close".localized)) {
            viewModel.error = nil
            viewModel.alertAction = nil
        }

        let alert: Alert

        if let alertAction = viewModel.alertAction {
            let actionButton = Alert.Button.default(Text(alertAction.title)) {
                viewModel.error = nil
                viewModel.alertAction = nil
                alertAction.action()
            }

            alert = Alert(title: Text(alertTitle),
                          message: Text(alertMessage),
                          primaryButton: actionButton,
                          secondaryButton: closeButton)
        } else {
            alert = Alert(title: Text(alertTitle),
                          message: Text(alertMessage),
                          dismissButton: closeButton)
        }

        return alert
    }
}
