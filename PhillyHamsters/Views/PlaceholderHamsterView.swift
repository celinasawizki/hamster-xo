import SwiftUI

/// A simple vector-drawn hamster, used whenever Codex's sprite art for a
/// given state isn't in the asset catalog yet. This is what lets the app
/// compile and run before any real artwork exists — see DESIGN_HANDOFF.md.
struct PlaceholderHamsterView: View {
    let role: HamsterRole
    var eyesClosed: Bool = false
    var bounce: Bool = false
    var sad: Bool = false

    private var furColor: Color {
        role == .celina
            ? Color(red: 0.96, green: 0.90, blue: 0.80)
            : Color(red: 0.80, green: 0.60, blue: 0.38)
    }

    private var bellyColor: Color {
        role == .celina ? Color(red: 1.0, green: 0.95, blue: 0.90) : Color(red: 0.93, green: 0.85, blue: 0.72)
    }

    var body: some View {
        ZStack {
            // Body
            Ellipse()
                .fill(furColor)
                .frame(width: 70, height: 56)
            // Belly
            Ellipse()
                .fill(bellyColor)
                .frame(width: 40, height: 30)
                .offset(y: 10)
            // Ears
            HStack(spacing: 34) {
                Circle().fill(furColor).frame(width: 16, height: 16)
                Circle().fill(furColor).frame(width: 16, height: 16)
            }
            .offset(y: -24)
            // Cheeks
            HStack(spacing: 44) {
                Circle().fill(Color.pink.opacity(0.35)).frame(width: 14, height: 14)
                Circle().fill(Color.pink.opacity(0.35)).frame(width: 14, height: 14)
            }
            .offset(y: 2)
            // Eyes
            HStack(spacing: 18) {
                eye
                eye
            }
            .offset(y: -6)
            // Nose
            Circle().fill(Color.pink).frame(width: 6, height: 6).offset(y: 4)
            // Bow (Celina only)
            if role == .celina {
                HStack(spacing: -2) {
                    Triangle().fill(Color.pink).frame(width: 8, height: 8)
                    Circle().fill(Color.pink).frame(width: 5, height: 5)
                    Triangle().rotation(.degrees(180)).fill(Color.pink).frame(width: 8, height: 8)
                }
                .offset(x: -14, y: -26)
            }
            if sad {
                Text("…")
                    .font(.system(size: 14, weight: .bold))
                    .offset(y: -34)
            }
        }
        .frame(width: 80, height: 80)
        .offset(y: bounce ? -10 : 0)
        .animation(.interpolatingSpring(stiffness: 220, damping: 10), value: bounce)
    }

    @ViewBuilder
    private var eye: some View {
        if eyesClosed {
            Capsule().fill(Color.black).frame(width: 7, height: 2)
        } else {
            Circle().fill(Color.black).frame(width: 5, height: 5)
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
