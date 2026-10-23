import SwiftUI

/// A smooth, soft-shaded vector hamster — used whenever Codex's sprite art
/// for a given state isn't in the asset catalog yet. This is what lets the
/// app compile and run before any real artwork exists — see
/// DESIGN_HANDOFF.md. Deliberately NOT pixel art: smooth curves, soft
/// gradient shading, a glossy highlight and a gentle blush, closer to a
/// polished sticker/mascot illustration.
struct PlaceholderHamsterView: View {
    let role: HamsterRole
    var eyesClosed: Bool = false
    var bounce: Bool = false
    var sad: Bool = false

    private var furColor: Color {
        role == .celina
            ? Color(red: 0.98, green: 0.87, blue: 0.71)
            : Color(red: 0.92, green: 0.75, blue: 0.54)
    }

    private var furShadowColor: Color {
        role == .celina
            ? Color(red: 0.93, green: 0.78, blue: 0.58)
            : Color(red: 0.83, green: 0.63, blue: 0.40)
    }

    private var bellyColor: Color {
        role == .celina ? Color(red: 1.0, green: 0.96, blue: 0.90) : Color(red: 0.99, green: 0.91, blue: 0.78)
    }

    private var outlineColor: Color {
        Color(red: 0.45, green: 0.31, blue: 0.21)
    }

    private var furGradient: LinearGradient {
        LinearGradient(colors: [furColor, furShadowColor], startPoint: .top, endPoint: .bottom)
    }

    private let bodyDiameter: CGFloat = 66

    var body: some View {
        ZStack {
            // Soft contact shadow for grounding.
            Ellipse()
                .fill(Color.black.opacity(0.12))
                .frame(width: 46, height: 8)
                .blur(radius: 1)
                .offset(y: 36)

            earPair

            HStack(spacing: 32) {
                foot
                foot
            }
            .offset(y: 31)

            // Body: one big round chibi blob, soft-shaded for a plush look.
            Circle()
                .fill(furGradient)
                .overlay(Circle().stroke(outlineColor, lineWidth: 2))
                .frame(width: bodyDiameter, height: bodyDiameter)

            // Glossy highlight.
            Ellipse()
                .fill(Color.white.opacity(0.35))
                .frame(width: 18, height: 11)
                .rotationEffect(.degrees(-20))
                .offset(x: -14, y: -20)
                .blendMode(.plusLighter)

            // Belly patch.
            Ellipse()
                .fill(bellyColor)
                .frame(width: 36, height: 27)
                .offset(y: 15)

            HStack(spacing: 6) {
                paw
                paw
            }
            .offset(y: 11)

            // Cheeks, blurred for a soft blush.
            HStack(spacing: 40) {
                blush
                blush
            }
            .offset(y: 2)

            HStack(spacing: 18) {
                eye
                eye
            }
            .offset(y: -5)

            mouth
                .offset(y: 7)

            Triangle()
                .fill(Color(red: 0.58, green: 0.36, blue: 0.32))
                .frame(width: 5, height: 4)
                .offset(y: 2)

            if role == .celina {
                bow.offset(x: -17, y: -26)
            }

            if sad {
                Text("…")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(outlineColor)
                    .offset(y: -36)
            }
        }
        .frame(width: 80, height: 80)
        .offset(y: bounce ? -10 : 0)
        .animation(.interpolatingSpring(stiffness: 220, damping: 10), value: bounce)
    }

    private var earPair: some View {
        HStack(spacing: 40) {
            ear
            ear
        }
        .offset(y: -29)
    }

    private var ear: some View {
        ZStack {
            Circle()
                .fill(furGradient)
                .overlay(Circle().stroke(outlineColor, lineWidth: 1.5))
                .frame(width: 19, height: 19)
            Circle()
                .fill(Color(red: 0.99, green: 0.76, blue: 0.74))
                .frame(width: 9.5, height: 9.5)
        }
        .shadow(color: .black.opacity(0.08), radius: 1, x: 0, y: 1)
    }

    private var foot: some View {
        Ellipse()
            .fill(bellyColor)
            .overlay(Ellipse().stroke(outlineColor, lineWidth: 1.2))
            .frame(width: 15, height: 9)
    }

    private var paw: some View {
        Circle()
            .fill(bellyColor)
            .overlay(Circle().stroke(outlineColor, lineWidth: 1.2))
            .frame(width: 11, height: 11)
    }

    private var blush: some View {
        Circle()
            .fill(Color(red: 0.98, green: 0.58, blue: 0.56).opacity(0.5))
            .frame(width: 16, height: 13)
            .blur(radius: 1.5)
    }

    private var bow: some View {
        HStack(spacing: -2) {
            Triangle().fill(Color(red: 0.94, green: 0.46, blue: 0.58)).frame(width: 8, height: 8)
            Circle().fill(Color(red: 0.94, green: 0.46, blue: 0.58)).frame(width: 5.5, height: 5.5)
            Triangle().rotation(.degrees(180)).fill(Color(red: 0.94, green: 0.46, blue: 0.58)).frame(width: 8, height: 8)
        }
    }

    @ViewBuilder
    private var eye: some View {
        if eyesClosed {
            Capsule().fill(outlineColor).frame(width: 7, height: 2)
        } else {
            ZStack {
                Circle().fill(Color.black).frame(width: 6.5, height: 6.5)
                Circle().fill(Color.white).frame(width: 2.0, height: 2.0).offset(x: 1.2, y: -1.2)
                Circle().fill(Color.white.opacity(0.7)).frame(width: 1.0, height: 1.0).offset(x: -1.0, y: 1.0)
            }
        }
    }

    @ViewBuilder
    private var mouth: some View {
        if sad {
            SmallArc(flipped: true)
                .stroke(outlineColor, style: StrokeStyle(lineWidth: 1.3, lineCap: .round))
                .frame(width: 7, height: 4)
        } else {
            SmallArc(flipped: false)
                .stroke(outlineColor, style: StrokeStyle(lineWidth: 1.3, lineCap: .round))
                .frame(width: 7, height: 4)
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

/// A tiny smile (or, flipped, a frown) for the mouth.
private struct SmallArc: Shape {
    let flipped: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let start = CGPoint(x: rect.minX, y: flipped ? rect.maxY : rect.minY)
        let end = CGPoint(x: rect.maxX, y: flipped ? rect.maxY : rect.minY)
        let control = CGPoint(x: rect.midX, y: flipped ? rect.minY : rect.maxY)
        path.move(to: start)
        path.addQuadCurve(to: end, control: control)
        return path
    }
}
