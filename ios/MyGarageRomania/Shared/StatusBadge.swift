import SwiftUI

struct StatusBadge: View {
    let title: String
    let status: String

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(title)
                .font(.caption.weight(.semibold))
            Text(status.replacingOccurrences(of: "_", with: " ").capitalized)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(color.opacity(0.13), in: Capsule())
        .foregroundStyle(color)
        .lineLimit(1)
    }

    private var color: Color {
        switch status {
        case "OK", "VALID":
            .green
        case "SOON", "EXPIRING_SOON", "UNKNOWN":
            .orange
        case "OVERDUE", "EXPIRED", "URGENT":
            .red
        default:
            .secondary
        }
    }
}
