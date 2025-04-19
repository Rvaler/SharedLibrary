import SwiftUI

protocol AppValidating {
    func canOpenApp(_ appName: String) -> Bool
}

final class AppValidator: AppValidating {
    private let application: UIApplication

    init(application: UIApplication = UIApplication.shared) {
        self.application = application
    }

    func canOpenApp(_ appName: String) -> Bool {
        let appScheme = appName + "://app"
        guard let appUrl = URL(string: appScheme) else { return false }
        return application.canOpenURL(appUrl)
    }
}
