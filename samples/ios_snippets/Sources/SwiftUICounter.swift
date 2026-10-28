import SwiftUI

// [snippet:ui-state]
struct Counter: View {
    // @State 相當於 remember { mutableStateOf(0) }
    @State private var count = 0

    var body: some View {
        // VStack / HStack 相當於 Column / Row
        VStack(spacing: 16) {
            Text("\(count)").font(.largeTitle)
            HStack(spacing: 8) {
                Button("−1") { count -= 1 }.buttonStyle(.bordered)
                Button("+1") { count += 1 }.buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity) // 相當於 Modifier.fillMaxWidth()
        .padding(16)
    }
}
// [/snippet]
