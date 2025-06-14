import Foundation

final class ShareImagePreviewViewModel: ObservableObject {
    struct ErrorAlertAction {
        let title: String
        let action: () -> Void
    }

    let onCloseTapped: () -> Void
    let onMoreTapped: () -> Void
    let onSaveTapped: () -> Void
    let onShareServiceTapped: (ShareService) -> Void
    var alertAction: ErrorAlertAction?

    lazy var bottomSheetViewModel: ShareImageBottomSheetViewModel = {
        ShareImageBottomSheetViewModel(shareImagePreviewViewModel: self)
    }()

    @Published var error: ShareImageError?

    init(onCloseTapped: @escaping () -> Void,
         onMoreTapped: @escaping () -> Void,
         onSaveTapped: @escaping () -> Void,
         onShareServiceTapped: @escaping (ShareService) -> Void) {
        self.onCloseTapped = onCloseTapped
        self.onMoreTapped = onMoreTapped
        self.onSaveTapped = onSaveTapped
        self.onShareServiceTapped = onShareServiceTapped
    }

    func presentError(_ error: ShareImageError,
                      alertAction: ErrorAlertAction? = nil) {
        self.error = error
        self.alertAction = alertAction
    }
}
