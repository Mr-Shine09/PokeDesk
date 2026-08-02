import Foundation

enum AppResourcesError: Error, LocalizedError {
    case missingAtlas
    case missingOrangeAtlas
    case missingContract

    var errorDescription: String? {
        switch self {
        case .missingAtlas: "The bundled mascot atlas is missing."
        case .missingOrangeAtlas: "The bundled orange-fashion mascot atlas is missing."
        case .missingContract: "The bundled atlas contract is missing."
        }
    }
}

struct AppResources {
    /// The classic navy wardrobe, worn by the Codex mascot since 2026-08-01.
    let atlasURL: URL
    /// The orange/sunglasses wardrobe, worn by the Claude mascot since
    /// 2026-08-01. Still named `mascot-atlas-codex@2x.png` on disk: the file
    /// predates the mapping swap and renaming it would also mean touching the
    /// contract, the Xcode resource list, and the authoring tool.
    let orangeAtlasURL: URL
    let contractURL: URL

    static func load(bundle: Bundle = .main) throws -> AppResources {
        guard let atlasURL = bundle.url(forResource: "mascot-atlas@2x", withExtension: "png") else {
            throw AppResourcesError.missingAtlas
        }
        guard let orangeAtlasURL = bundle.url(forResource: "mascot-atlas-codex@2x", withExtension: "png") else {
            throw AppResourcesError.missingOrangeAtlas
        }
        guard let contractURL = bundle.url(forResource: "atlas-contract", withExtension: "json") else {
            throw AppResourcesError.missingContract
        }
        return AppResources(
            atlasURL: atlasURL,
            orangeAtlasURL: orangeAtlasURL,
            contractURL: contractURL
        )
    }
}
