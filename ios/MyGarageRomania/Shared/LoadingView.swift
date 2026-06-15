import SwiftUI

struct LoadingView: View {
    var title = "Loading"

    var body: some View {
        VStack(spacing: 14) {
            ProgressView()
            Text(title)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
