import XCTest
import AppKit
@testable import PhillyHamsters

final class ArtworkTests: XCTestCase {
    func testAllRequiredSheetsHaveTransparentNonemptyFrames() throws {
        let specs = HamsterRole.allArtworkRoles.flatMap { role in
            [HamsterAnimationState.idle, .blinking, .excited].compactMap { SpriteCatalog.soloSpec(for: role, state: $0) }
        } + [HamsterAnimationState.hugging, .missingYou, .sleeping, .celebration].compactMap { SpriteCatalog.pairSpec(for: $0) }
        XCTAssertEqual(specs.count, 10)
        for spec in specs {
            let image = try XCTUnwrap(NSImage(named: spec.assetName), spec.assetName)
            var rect = CGRect(origin: .zero, size: image.size)
            let cg = try XCTUnwrap(image.cgImage(forProposedRect: &rect, context: nil, hints: nil))
            XCTAssertEqual(cg.width, (spec.assetName.hasPrefix("pair") ? 512 : 256) * spec.frameCount)
            XCTAssertEqual(cg.height, 256)
            XCTAssertNotEqual(cg.alphaInfo, .none)
            for index in 0..<spec.frameCount {
                let frame = try XCTUnwrap(image.spriteFrame(index: index, frameCount: spec.frameCount))
                XCTAssertGreaterThan(try XCTUnwrap(frame.tiffRepresentation).count, 100)
            }
        }
    }

    func testClickReactionsAdvanceAndHugHoldsLastFrame() {
        // Exercise random click selection until both relevant paths have run.
        var seen: Set<HamsterAnimationState> = []
        for _ in 0..<100 {
            let animator = HamsterSceneAnimator()
            animator.handleClick(on: .celina)
            let state = animator.currentState
            if state == .excited && !seen.contains(state) {
                RunLoop.main.run(until: Date().addingTimeInterval(0.25))
                XCTAssertGreaterThan(animator.frameIndex, 0)
                seen.insert(state)
            } else if state == .hugging && !seen.contains(state) {
                RunLoop.main.run(until: Date().addingTimeInterval(1.15))
                XCTAssertEqual(animator.frameIndex, 7)
                RunLoop.main.run(until: Date().addingTimeInterval(0.25))
                XCTAssertEqual(animator.frameIndex, 7)
                seen.insert(state)
            }
            animator.stop()
            if seen.count == 2 { break }
        }
        XCTAssertEqual(seen, [.excited, .hugging])
    }
}

private extension HamsterRole {
    static let allArtworkRoles: [HamsterRole] = [.celina, .kivanc]
}
