import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, bundle: .module, comment: "\(self)_comment")
    }
}
