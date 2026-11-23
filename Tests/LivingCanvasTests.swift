import XCTest
@testable import ViePNWidgetPlus

final class LivingCanvasTests: XCTestCase {
    func testOldDesignJSONMigrates() throws {
        let json = """
        {"id":"D9D01B9B-F9EC-4B1D-A248-A77FC2DBB969","name":"Legacy","kind":"clock",\
        "title":"Now","message":"Test","backgroundHex":"#000000",\
        "foregroundHex":"#FFFFFF","accentHex":"#AABBCC"}
        """.data(using: .utf8)!
        let old = try JSONDecoder().decode(WidgetDesign.self, from: json)
        XCTAssertNil(old.scene)
        XCTAssertEqual(old.layers, [])
        XCTAssertEqual(old.fontScale, 1)
        XCTAssertEqual(old.smartGoals.count, 3)
    }

    func testSceneAndLayerRoundTrip() throws {
        var design = WidgetDesign.fresh(.smart, scene: .cosmos)
        design.layers = [.make(.clock), .make(.text)]
        let encoded = try JSONEncoder().encode(design)
        let decoded = try JSONDecoder().decode(WidgetDesign.self, from: encoded)
        XCTAssertEqual(design, decoded)
    }

    func testDuplicationGivesLayersUniqueIDs() {
        var design = WidgetDesign.fresh(.clock)
        design.layers = [.make(.text)]
        let copy = design.duplicate()
        XCTAssertNotEqual(copy.layers.first?.id, design.layers.first?.id)
    }

    func testSceneCatalogContainsSixUniqueScenes() {
        XCTAssertEqual(Set(LivingScene.allCases.map(\.id)).count, 6)
    }
}
