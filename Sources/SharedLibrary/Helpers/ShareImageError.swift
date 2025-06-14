import Foundation

struct ShareImageError: Error, Equatable {
    let description: String
    let recoverySuggestion: String
}

extension ShareImageError {
    static let attachmentsAreNotSupported = ShareImageError(description: "attachments_are_not_supported_description".localized,
                                                            recoverySuggestion: "attachments_are_not_supported_recovery_suggestion".localized)

    static let couldntConvertImageToData = ShareImageError(description: "couldnt_convert_image_to_data_description".localized,
                                                           recoverySuggestion: "couldnt_convert_image_to_data_recovery_suggestion".localized)

    static let couldntSaveImage = ShareImageError(description: "couldnt_save_image_description".localized,
                                                  recoverySuggestion: "couldnt_save_image_recovery_suggestion".localized)

    static let unknown = ShareImageError(description: "unknown_description".localized,
                                         recoverySuggestion: "unknown_recovery_suggestion".localized)
}
