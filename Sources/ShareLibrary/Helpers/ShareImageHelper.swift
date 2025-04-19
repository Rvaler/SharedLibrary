import Combine
import FBSDKShareKit
import MessageUI

enum ShareService: String, CaseIterable {
    case instagram = "instagram"
    case whatsapp = "whatsapp"
    case facebookMessenger = "fb-messenger"
    case facebook = "fb"
    case messages = "sms"
}

public typealias ShareImageDelegate = AnyObject & UIViewController & SharingDelegate &
    MFMessageComposeViewControllerDelegate & UIDocumentInteractionControllerDelegate

final class ShareImageHelper {
    public let errorSubject = PassthroughSubject<(ShareImageError, ShareService?), Never>()
    weak var delegate: ShareImageDelegate?
    
    private(set) var currentService: ShareService?
    private let facebookID: String
    private var documentInteractionController: UIDocumentInteractionController?
    private let application: UIApplication

    init(application: UIApplication = .shared,
         facebookID: String) {
        self.application = application
        self.facebookID = facebookID
    }

    func share(service: ShareService, image: UIImage) {
        self.currentService = service

        switch service {
        case .instagram:
            shareWithInstagram(image: image)
        case .facebook:
            shareWithFacebook(image: image)
        case .facebookMessenger:
            shareWithFacebookMessenger(image: image)
        case .messages:
            shareWithMessages(image: image)
        case .whatsapp:
            shareWithWhatsApp(image: image)
        }
    }

    private func shareWithInstagram(image: UIImage) {
        guard let storiesUrl = URL(string: "instagram-stories://share?source_application=\(facebookID)"),
              let imageData = convertImageToPngData(image) else {
            return
        }

        let pasteboardItems: [String: Any] = [
            "com.instagram.sharedSticker.backgroundImage": imageData,
        ]

        let pasteboardOptions = [
            UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(300)
        ]

        UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
        application.open(storiesUrl, options: [:], completionHandler: nil)
        delegate?.dismiss(animated: true, completion: nil)
    }

    private func shareWithWhatsApp(image: UIImage) {
        guard let imageData = convertImageToPngData(image), let view = delegate?.view else { return }

        let tempFile = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents/Share.png")
        do {
            try imageData.write(to: tempFile, options: .atomic)
            self.documentInteractionController = UIDocumentInteractionController(url: tempFile)
            self.documentInteractionController?.delegate = delegate
            self.documentInteractionController?.uti = "net.whatsapp.image"
            self.documentInteractionController?.presentOpenInMenu(from: CGRect.zero, in: view, animated: true)
        } catch {
            sendError(.unknown)
        }
    }

    private func shareWithFacebook(image: UIImage) {
        let photo = SharePhoto(image: image, isUserGenerated: true)
        let content = SharePhotoContent()
        content.photos = [photo]

        let shareDialog = ShareDialog(viewController: delegate,
                                      content: content,
                                      delegate: delegate)

        shareDialog.show()
    }

    private func shareWithFacebookMessenger(image: UIImage) {
        let photo = SharePhoto(image: image, isUserGenerated: true)
        let content = SharePhotoContent()
        content.photos = [photo]

        let messageDialog = MessageDialog(content: content,
                                          delegate: delegate)

        messageDialog.show()
    }

    private func shareWithMessages(image: UIImage) {
        guard let imageData = convertImageToPngData(image) else { return }

        guard MFMessageComposeViewController.canSendAttachments() else {
            sendError(.attachmentsAreNotSupported)
            return
        }

        let messageComposer = MFMessageComposeViewController()
        messageComposer.messageComposeDelegate = delegate

        let fileName = "Score.png"
        messageComposer.addAttachmentData(imageData, typeIdentifier: "public.png", filename: fileName)

        delegate?.present(messageComposer, animated: true)
    }

    private func convertImageToPngData(_ image: UIImage) -> Data? {
        guard let imageData = image.pngData() else {
            sendError(.couldntConvertImageToData)
            return nil
        }
        return imageData
    }

    private func sendError(_ error: ShareImageError) {
        errorSubject.send((error, currentService))
    }
}
