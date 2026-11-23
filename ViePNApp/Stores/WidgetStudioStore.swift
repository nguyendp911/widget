import Foundation
import SwiftUI
import WidgetKit

@MainActor
final class WidgetStudioStore: ObservableObject {
    @Published private(set) var designs: [WidgetDesign]
    @Published var errorMessage: String?
    private let repository = SharedRepository()

    init() {
        designs = repository.loadDesigns()
    }

    func save(_ design: WidgetDesign) {
        var updated = designs
        if let index = updated.firstIndex(where: { $0.id == design.id }) {
            updated[index] = design
        } else {
            updated.insert(design, at: 0)
        }
        persist(updated)
    }

    func delete(_ design: WidgetDesign) {
        persist(designs.filter { $0.id != design.id })
    }

    private func persist(_ updated: [WidgetDesign]) {
        do {
            try repository.saveDesigns(updated)
            designs = updated
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            errorMessage = "Không lưu được thiết kế: \(error.localizedDescription)"
        }
    }
}
