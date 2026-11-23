import XCTest
@testable import ViePNWidgetPlus

final class WidgetDesignTests: XCTestCase {
    func testTemplateRoundTrip() throws {
        let template = SampleTemplates.catalog[0]
        let encoded = try JSONEncoder().encode(template)
        let decoded = try JSONDecoder().decode(WidgetDesign.self, from: encoded)
        XCTAssertEqual(template, decoded)
    }

    func testDuplicateGeneratesDifferentIdentifier() {
        let template = SampleTemplates.catalog[0]
        let duplicated = template.duplicate()
        XCTAssertNotEqual(template.id, duplicated.id)
        XCTAssertEqual(template.name, duplicated.name)
    }

    func testCatalogCoversSixKinds() {
        XCTAssertEqual(Set(SampleTemplates.catalog.map(\.kind)), Set(WidgetKind.allCases))
    }
}
