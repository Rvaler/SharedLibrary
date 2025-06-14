import SwiftUI

struct RoundedBorderedButton: View {
    let action: () -> Void
    let imageName: String
    let title: String
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.black)
                Image(packageResource: imageName)
            }
            .frame(maxWidth: .infinity,
                   maxHeight: .infinity)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.appLightGray, lineWidth: 2)
                .foregroundColor(.clear)
        )
    }
}

struct RoundedBorderedButton_Previews: PreviewProvider {
    static var previews: some View {
        RoundedBorderedButton(action: {},
                              imageName: "download-icon",
                              title: "Download")
        .frame(width: 240, height: 56)
    }
}
