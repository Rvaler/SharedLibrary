import Foundation

final class SocialSharingCarouselViewModel: ObservableObject {
    struct CarouselItem: Identifiable {
        let id = UUID()
        let service: ShareService
        let title: String
        let imageName: String

        init(withService service: ShareService) {
            self.service = service

            switch service {
            case .facebook:
                self.title = "Facebook"
                self.imageName = "facebook-icon"
            case .facebookMessenger:
                self.title = "Messenger"
                self.imageName = "messenger-icon"
            case .instagram:
                self.title = "Instagram"
                self.imageName = "instagram-icon"
            case .messages:
                self.title = "messages".localized
                self.imageName = "messages-icon"
            case .whatsapp:
                self.title = "Whatsapp"
                self.imageName = "whatsapp-icon"
            }
        }
    }

    let carouselItems: [CarouselItem]
    let onShareServiceTapped: (ShareService) -> Void

    init(appValidator: AppValidating = AppValidator(),
         onShareServiceTapped: @escaping (ShareService) -> Void) {
        self.onShareServiceTapped = onShareServiceTapped
        self.carouselItems = ShareService.allCases
            .filter { appValidator.canOpenApp($0.rawValue) }
            .map { shareService in
                CarouselItem(withService: shareService)
            }
    }
}
