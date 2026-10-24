import SwiftUI

/// Warm cream speech bubble from the artwork handoff. The tail is part of
/// the same outline, so it stays clean on any desktop wallpaper.
struct CountdownBadgeView: View {
    let countdownText: String
    let dailyMessage: String
    var showsMessage = false

    var body: some View {
        VStack(spacing: 3) {
            if showsMessage {
                Text(dailyMessage)
                    .foregroundStyle(Color(red: 0.66, green: 0.29, blue: 0.27))
            } else {
                Text(countdownText.replacingOccurrences(of: " ♡", with: ""))
                if countdownText.hasSuffix(" ♡") {
                    HStack(spacing: 4) {
                        Text("until Philly!")
                        Text("♥").foregroundStyle(Color(red: 0.98, green: 0.46, blue: 0.53))
                    }
                }
            }
        }
        .font(.system(size: showsMessage ? 12 : 15, weight: .semibold, design: .rounded))
        .foregroundStyle(Color(red: 0.34, green: 0.17, blue: 0.13))
        .multilineTextAlignment(.center)
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 20)
        .background(SpeechBubble().fill(Color(red: 1, green: 0.96, blue: 0.90)))
        .overlay(SpeechBubble().stroke(Color(red: 0.69, green: 0.43, blue: 0.36), lineWidth: 1.5))
        .shadow(color: .black.opacity(0.12), radius: 2, y: 2)
        .fixedSize(horizontal: false, vertical: true)
        .help(dailyMessage)
        .accessibilityElement(children: .combine)
    }
}

private struct SpeechBubble: Shape {
    func path(in rect: CGRect) -> Path {
        let r: CGFloat = 15
        let bottom = rect.maxY - 10
        let tail = rect.width * 0.72
        var path = Path()
        path.move(to: CGPoint(x: r, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX - r, y: 0))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: r), control: CGPoint(x: rect.maxX, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: bottom - r))
        path.addQuadCurve(to: CGPoint(x: rect.maxX - r, y: bottom), control: CGPoint(x: rect.maxX, y: bottom))
        path.addLine(to: CGPoint(x: tail + 15, y: bottom))
        path.addLine(to: CGPoint(x: tail, y: rect.maxY))
        path.addLine(to: CGPoint(x: tail + 2, y: bottom))
        path.addLine(to: CGPoint(x: r, y: bottom))
        path.addQuadCurve(to: CGPoint(x: 0, y: bottom - r), control: CGPoint(x: 0, y: bottom))
        path.addLine(to: CGPoint(x: 0, y: r))
        path.addQuadCurve(to: CGPoint(x: r, y: 0), control: .zero)
        path.closeSubpath()
        return path
    }
}
