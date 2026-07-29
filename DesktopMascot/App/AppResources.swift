import Foundation

enum AppResourcesError: Error, LocalizedError {
    case missingAtlas
    case missingContract

    var errorDescription: String? {
        switch self {
        case .missingAtlas: "The bundled mascot atlas is missing."
        case .missingContract: "The bundled atlas contract is missing."
        }
    }
}

struct AppResources {
    let atlasURL: URL
    let contractURL: URL

    static func load(bundle: Bundle = .main) throws -> AppResources {
        guard let atlasURL = bundle.url(forResource: "mascot-atlas@2x", withExtension: "png") else {
            throw AppResourcesError.missingAtlas
        }
        guard let contractURL = bundle.url(forResource: "atlas-contract", withExtension: "json") else {
            throw AppResourcesError.missingContract
        }
        return AppResources(atlasURL: atlasURL, contractURL: contractURL)
    }
}
