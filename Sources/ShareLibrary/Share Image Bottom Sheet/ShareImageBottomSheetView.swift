import SwiftUI

struct ShareImageBottomSheetView: View {
    private let contentPadding: CGFloat = 24
    private let closeButtonSize: CGFloat = 64

    let viewModel: ShareImageBottomSheetViewModel

    var body: some View {
        VStack(spacing: 0) {
            header

            VStack(spacing: 0) {
                shareSocialCarousel
                Spacer()
                    .frame(height: 28)
                actionButtons
            }
        }
        .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0)
        .edgesIgnoringSafeArea(.bottom)
        .background(Color.white)
        .cornerRadius(12, corners: [.topLeft, .topRight])
    }

    private var header: some View {
        HStack(spacing: 0) {
            Button {
                viewModel.onCloseTapped()
            } label: {
                Image(packageResource: "close-icon")
                    .frame(width: closeButtonSize,
                           height: closeButtonSize)
            }

            Text("share".localized)
                .frame(maxWidth: .infinity)
                .padding(.trailing, closeButtonSize)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
        }
    }

    private var shareSocialCarousel: some View {
        SocialSharingCarousel(contentPadding: contentPadding,
                              viewModel: viewModel.socialSharingCarouselViewModel)
        .frame(height: 100)
    }

    private var actionButtons: some View {
        HStack(spacing: 18) {
            RoundedBorderedButton(action: { viewModel.onSaveTapped() },
                                  imageName: "download-icon",
                                  title: "save_image".localized)
            RoundedBorderedButton(action: { viewModel.onMoreTapped() },
                                  imageName: "more-icon",
                                  title: "more".localized)
        }
        .frame(height: 50)
        .frame(maxWidth: 366)
        .padding(.horizontal, contentPadding)
        .padding(.bottom, contentPadding)
    }
}
