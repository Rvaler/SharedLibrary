import Combine
import FBSDKShareKit
import MessageUI
import SwiftUI

final public class ShareImagePreviewViewController: ShareImageDelegate {
    public enum BackgroundType {
        case image(UIImage)
        case color(UIColor)
    }
    
    public struct RequiredData {
        let image: UIImage
        let backgroundType: BackgroundType
        let facebookId: String
        
        public init(image: UIImage,
                    backgroundType: BackgroundType,
                    facebookId: String) {
            self.image = image
            self.backgroundType = backgroundType
            self.facebookId = facebookId
        }
    }

    private let shareImageHelper: ShareImageHelper
    private let image: UIImage
    private let backgroundType: BackgroundType
    private var cancellables: [AnyCancellable] = []

    private lazy var viewModel: ShareImagePreviewViewModel = {
        ShareImagePreviewViewModel(onCloseTapped: closeTapped,
                                   onMoreTapped: moreTapped,
                                   onSaveTapped: saveTapped,
                                   onShareServiceTapped: shareServiceTapped)
    }()

    private lazy var contentView: UIHostingController = {
        var backgroundImage: Image?
        var backgroundColor: Color = .clear
        switch backgroundType {
        case .color(let color):
            backgroundColor = Color(color)
        case .image(let image):
            backgroundImage = Image(uiImage: image)
        }
        
        let shareImagePreviewView = ShareImagePreviewView(imageToBeShared: Image(uiImage: image),
                                                          backgroundColor: backgroundColor,
                                                          backgroundImage: backgroundImage,
                                                          viewModel: viewModel)
        let hostingController = UIHostingController(rootView: shareImagePreviewView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        return hostingController
    }()

    private lazy var closeTapped: () -> Void = { [weak self] in
        self?.dismiss(animated: true)
    }

    private lazy var moreTapped: () -> Void = { [weak self] in
        self?.presentActivityShareSheet()
    }

    private lazy var saveTapped: () -> Void = { [weak self] in
        guard let self = self else { return }
        UIImageWriteToSavedPhotosAlbum(self.image, self, #selector(self.saveCompleted), nil)
    }

    private lazy var shareServiceTapped: (ShareService) -> Void = { [weak self] service in
        guard let self = self else { return }
        self.shareImageHelper.share(service: service, image: self.image)
    }

    public init(requiredData: RequiredData) {
        self.image = requiredData.image
        
        self.backgroundType = requiredData.backgroundType
        self.shareImageHelper = ShareImageHelper(facebookID: requiredData.facebookId)
        super.init(nibName: nil, bundle: nil)

        shareImageHelper.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
        setupObservers()
    }

    private func configureViews() {
        view.backgroundColor = .clear
        view.addSubview(contentView.view)
        contentView.didMove(toParent: self)

        NSLayoutConstraint.activate([
            contentView.view.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    private func setupObservers() {
        shareImageHelper.errorSubject.sink { [weak self] error, service in
            self?.handleShareError(shareImageError: error)
        }
        .store(in: &cancellables)
    }

    private func presentActivityShareSheet() {
        let activityViewController = UIActivityViewController(activityItems: [self.image],
                                                              applicationActivities: nil)

        activityViewController.completionWithItemsHandler = { [weak self] activityType, completed, _, error in
            if completed {
                self?.handleShareSucceeded()
                return
            }

            if error != nil {
                self?.handleShareError(shareImageError: .unknown,
                                       error: error)
            }
        }

        // prevents iPads from crashing
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.popoverPresentationController?.sourceRect = self.accessibilityFrame
        }

        self.present(activityViewController, animated: true)
    }

    @objc private func saveCompleted(_ image: UIImage,
                                     didFinishSavingWithError error: Error?,
                                     contextInfo: UnsafeRawPointer) {
        if let error {
            let alertTitle = "settings".localized
            let alertAction = ShareImagePreviewViewModel.ErrorAlertAction(title: alertTitle) { [weak self] in
                self?.openSettings()
            }
            handleShareError(shareImageError: .couldntSaveImage,
                             error: error,
                             alertAction: alertAction)
        } else {
            let alert = UIAlertController(title: "image_saved".localized,
                                          message: "image_saved_description".localized,
                                          preferredStyle: .alert)
            alert.addAction(.init(title: "ok".localized,
                                  style: .default,
                                  handler: { [weak self] _ in
                self?.handleShareSucceeded()
            }))
            
            present(alert, animated: true)
        }
    }

    private func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsUrl) else {
            return
        }

        UIApplication.shared.open(settingsUrl)
    }

    private func handleShareSucceeded() {
        dismiss(animated: true)
    }

    private func handleShareError(shareImageError: ShareImageError,
                                  error: Error? = nil,
                                  alertAction: ShareImagePreviewViewModel.ErrorAlertAction? = nil) {
        viewModel.presentError(shareImageError, alertAction: alertAction)
    }
}

// MARK: - MFMessageComposeViewControllerDelegate
extension ShareImagePreviewViewController {
    public func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                      didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true)

        switch result {
        case .failed:
            handleShareError(shareImageError: .unknown)
        case .sent:
            handleShareSucceeded()
        default:
            break
        }
    }
}

// MARK: - SharingDelegate
extension ShareImagePreviewViewController {
    public func sharer(_ sharer: Sharing, didCompleteWithResults results: [String: Any]) {
        // This delay is necessary for dismissing the view properly after FB modal is dismissed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.handleShareSucceeded()
        })
    }

    public func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        handleShareError(shareImageError: .unknown,
                         error: error)
    }

    public func sharerDidCancel(_ sharer: Sharing) {}
}

// MARK: - UIDocumentInteractionControllerDelegate
extension ShareImagePreviewViewController {
    public func documentInteractionControllerDidDismissOpenInMenu(_ controller: UIDocumentInteractionController) {
        handleShareSucceeded()
    }
}
