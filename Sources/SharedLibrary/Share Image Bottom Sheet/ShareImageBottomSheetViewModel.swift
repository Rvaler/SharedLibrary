import Foundation

final class ShareImageBottomSheetViewModel: ObservableObject {
    let socialSharingCarouselViewModel: SocialSharingCarouselViewModel
    let onCloseTapped: () -> Void
    let onMoreTapped: () -> Void
    let onSaveTapped: () -> Void

    init(shareImagePreviewViewModel viewModel: ShareImagePreviewViewModel) {
        self.socialSharingCarouselViewModel = SocialSharingCarouselViewModel(onShareServiceTapped: viewModel.onShareServiceTapped)
        self.onCloseTapped = viewModel.onCloseTapped
        self.onMoreTapped = viewModel.onMoreTapped
        self.onSaveTapped = viewModel.onSaveTapped
    }
}
