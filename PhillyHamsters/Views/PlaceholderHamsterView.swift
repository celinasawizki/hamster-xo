import SwiftUI

/// A vector-drawn hamster, used whenever Codex's sprite art for a given
/// state isn't in the asset catalog yet. This is what lets the app compile
/// and run before any real artwork exists — see DESIGN_HANDOFF.md. Drawn
/// as one big round chibi body (not a separate head+torso) with a thin
/// outline stroke, matching the target cute/rounded reference style.
struct PlaceholderHamsterView: View {
    let role: HamsterRole
    var eyesClosed: Bool = false
    var bounce: Bool = false
    var sad: Bool = false

    private var furColor: Color {
        role == .celina
            ? Color(red: 0.97, green: 0.85, blue: 0.68)
            : Color(red: 0.91, green: 0.73, blue: 0.52)
    }

    private var bellyColor: Color {
        role == .celina ? Color(red: 1.0, green: 0.95, blue: 0.88) : Color(red: 0.98, green: 0.90, blue: 0.76)
    }

    private var outlineColor: Color {
        Color(red: 0.42, green: 0.29, blue: 0.19)
    }

    private let bodyDiameter: CGFloat = 62

    var body: some View {
        ZStack {
            // Soft contact shadow for grounding.
            Ellipse()
                .fill(Color.black.opacity(0.12))
                .frame(width: 44, height: 8)
                .offset(y: 35)

            // Ears, tucked behind the body so only the tops peek out.
            earPair

            // Feet, peeking from under the body.
            HStack(spacing: 30) {
                foot
                foot
            }
            .offset(y: 30)

            // Body: one big round chibi blob, not a separate head/torso.
            Circle()
                .fill(furColor)
                .overlay(Circle().stroke(outlineColor, lineWidth: 2))
                .frame(width: bodyDiameter, height: bodyDiameter)

            // Belly patch.
            Ellipse()
                .fill(bellyColor)
                .frame(width: 34, height: 26)
                .offset(y: 14)

            // Little paws clasped together near the chest.
            HStack(spacing: 6) {
                paw
                paw
            }
            .offset(y: 10)

            // Cheeks.
            HStack(spacing: 38) {
                Circle().fill(Color(red: 0.98, green: 0.62, blue: 0.58).opacity(0.55)).frame(width: 15, height: 12)
                Circle().fill(Color(red: 0.98, green: 0.62, blue: 0.58).opacity(0.55)).frame(width: 15, height: 12)
            }
            .offset(y: 2)

            // Eyes.
            HStack(spacing: 17) {
                eye
                eye
            }
            .offset(y: -5)

            // Nose.
            Triangle()
                .fill(Color(red: 0.55, green: 0.33, blue: 0.3))
                .frame(width: 5, height: 4)
                .offset(y: 2)

            // Bow (Celina only).
            if role == .celina {
                bow.offset(x: -16, y: -24)
            }

            if sad {
                Text("…")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(outlineColor)
                    .offset(y: -34)
            }
        }
        .frame(width: 80, height: 80)
        .offset(y: bounce ? -10 : 0)
        .animation(.interpolatingSpring(stiffness: 220, damping: 10), value: bounce)
    }

    private var earPair: some View {
        HStack(spacing: 38) {
            ear
            ear
        }
        .offset(y: -28)
    }

    private var ear: some View {
        ZStack {
            Circle()
                .fill(furColor)
                .overlay(Circle().stroke(outlineColor, lineWidth: 1.5))
                .frame(width: 18, height: 18)
            Circle()
                .fill(Color(red: 0.98, green: 0.72, blue: 0.7))
                .frame(width: 9, height: 9)
        }
    }

    private var foot: some View {
        Ellipse()
            .fill(bellyColor)
            .overlay(Ellipse().stroke(outlineColor, lineWidth: 1.2))
            .frame(width: 14, height: 9)
    }

    private var paw: some View {
        Circle()
            .fill(bellyColor)
            .overlay(Circle().stroke(outlineColor, lineWidth: 1.2))
            .frame(width: 11, height: 11)
    }

    private var bow: some View {
        HStack(spacing: -2) {
            Triangle().fill(Color(red: 0.93, green: 0.45, blue: 0.56)).frame(width: 8, height: 8)
            Circle().fill(Color(red: 0.93, green: 0.45, blue: 0.56)).frame(width: 5, height: 5)
            Triangle().rotation(.degrees(180)).fill(Color(red: 0.93, green: 0.45, blue: 0.56)).frame(width: 8, height: 8)
        }
    }

    @ViewBuilder
    private var eye: some View {
        if eyesClosed {
            Capsule().fill(Color.black).frame(width: 7, height: 2)
        } else {
            ZStack {
                Circle().fill(Color.black).frame(width: 6, height: 6)
                Circle().fill(Color.white).frame(width: 1.6, height: 1.6).offset(x: 1, y: -1)
            }
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
