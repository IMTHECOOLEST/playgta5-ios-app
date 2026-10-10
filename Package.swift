import SwiftUI

struct TouchControlsView: View {
    @Binding var controlState: GameControlState

    private let padRadius: CGFloat = 72
    private let buttonSize: CGFloat = 62

    var body: some View {
        VStack {
            Spacer()
            HStack {
                VStack(spacing: 16) {
                    AnalogStickView(radius: padRadius, value: $controlState.moveX, secondValue: $controlState.moveY)
                    Spacer(minLength: 0)
                }

                Spacer()

                VStack(spacing: 18) {
                    actionButton(title: "A", isPressed: $controlState.actionA)
                    actionButton(title: "B", isPressed: $controlState.actionB)
                    actionButton(title: "S", isPressed: $controlState.sprint)
                    actionButton(title: "J", isPressed: $controlState.jump)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .allowsHitTesting(true)
    }

    private func actionButton(title: String, isPressed: Binding<Bool>) -> some View {
        Button {
            isPressed.wrappedValue.toggle()
        } label: {
            ZStack {
                Circle()
                    .fill(isPressed.wrappedValue ? Color.orange : Color.gray.opacity(0.7))
                    .frame(width: buttonSize, height: buttonSize)

                Text(title)
                    .font(.title3).bold()
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
    }
}

struct AnalogStickView: View {
    let radius: CGFloat
    @Binding var value: Double
    @Binding var secondValue: Double

    @State private var dragOffset: CGSize = .zero

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.45))
                .frame(width: radius * 2, height: radius * 2)

            Circle()
                .fill(Color.white.opacity(0.65))
                .frame(width: radius * 0.75, height: radius * 0.75)
                .offset(dragOffset)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            let dx = gesture.translation.width
                            let dy = gesture.translation.height
                            let clampedX = max(-1, min(1, Double(dx / radius)))
                            let clampedY = max(-1, min(1, Double(dy / radius)))

                            let distance = sqrt(dx * dx + dy * dy)
                            if distance > radius {
                                let scale = radius / distance
                                let safeX = dx * scale
                                let safeY = dy * scale
                                dragOffset = CGSize(width: safeX, height: safeY)
                                value = Double(safeX / radius)
                                secondValue = Double(safeY / radius)
                            } else {
                                dragOffset = CGSize(width: dx, height: dy)
                                value = clampedX
                                secondValue = clampedY
                            }
                        }
                        .onEnded { _ in
                            dragOffset = .zero
                            value = 0
                            secondValue = 0
                        }
                )
        }
    }
}

#Preview {
    TouchControlsView(controlState: .constant(GameControlState()))
}































































































































































































































































































































