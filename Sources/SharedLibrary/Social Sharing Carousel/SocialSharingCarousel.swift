import SwiftUI

struct SocialSharingCarousel: View {
    let contentPadding: CGFloat
    @ObservedObject var viewModel: SocialSharingCarouselViewModel

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    Spacer()
                    socialShareServicesList
                    Spacer()
                }
                .padding(.horizontal, contentPadding)
                .frame(minWidth: geometry.size.width)
            }
        }
    }

    private var socialShareServicesList: some View {
        HStack(spacing: 2) {
            ForEach(viewModel.carouselItems) { item in
                SocialShareServiceButton(action: { viewModel.onShareServiceTapped(item.service) },
                                    imageName: item.imageName,
                                    title: item.title)
            }
        }
    }

    private struct SocialShareServiceButton: View {
        let action: () -> Void
        let imageName: String
        let title: String

        var body: some View {
            Button(action: action) {
                VStack(spacing: 10) {
                    Image(packageResource: imageName)
                    Text(title)
                        .foregroundColor(.black)
                        .font(.system(size: 12, weight: .regular))
                }
                .frame(width: 80)
            }
        }
    }
}
