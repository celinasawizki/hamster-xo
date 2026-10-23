import SwiftUI

/// Minimal countdown + daily-message label. No background plate — legible
/// on both light and dark wallpaper via a soft drop shadow instead of a
/// rectangle behind the text, per the design brief.
struct CountdownBadgeView: View {
    let countdownText: String
    let dailyMessage: String

    var body: some View {
        VStack(spacing: 2) {
            Text(countdownText)
                .font(.system(size: 15, weight: .bold, design: .rounded))
            Text(dailyMessage)
                .font(.system(size: 12, weight: .medium, design: .rounded))
        }
        .foregroundStyle(.white)
        .shadow(color: .black.opacity(0.55), radius: 2, x: 0, y: 1)
        .multilineTextAlignment(.center)
        .fixedSize()
    }
}
