import SwiftUI
import GameController

struct TouchControlsView: View {
    @Binding var controlState: GameControlState
    @State private var isControllerConnected = false
    @StateObject private var controllerManager = GameControllerManager()

    var body: some View {
        ZStack(alignment: .bottomLeft) {
            // Analog stick (left side)
            VStack(alignment: .leading, spacing: 20) {
                Text(isControllerConnected ? "🎮 Controller" : "📱 Touch")
                    .font(.caption2)
                    .foregroundStyle(.white)
                    .padding(.leading, 12)
                
                AnalogStickView(
                    moveX: $controlState.moveX,
                    moveY: $controlState.moveY
                )
                .frame(width: 120, height: 120)
                .padding(.leading, 12)
                .padding(.bottom, 20)
            }

            // Action buttons (right side)
            HStack(spacing: 12) {
                VStack(spacing: 12) {
                    // Sprint button
                    Button(action: {}) {
                        Text("SPRINT")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .frame(width: 60, height: 40)
                            .background(controlState.sprint ? Color.orange : Color.gray)
                            .foregroundColor(.black)
                            .cornerRadius(4)
                    }
                    .onLongPressGesture(minimumDuration: 0.01, perform: {}) { pressing in
                        controlState.sprint = pressing
                    }

                    // Jump button
                    Button(action: {}) {
                        Text("JUMP")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .frame(width: 60, height: 40)
                            .background(controlState.jump ? Color.orange : Color.gray)
                            .foregroundColor(.black)
                            .cornerRadius(4)
                    }
                    .onLongPressGesture(minimumDuration: 0.01, perform: {}) { pressing in
                        controlState.jump = pressing
                    }
                }

                VStack(spacing: 12) {
                    // Action A button
                    Button(action: {}) {
                        Text("A")
                            .font(.headline)
                            .fontWeight(.bold)
                            .frame(width: 50, height: 50)
                            .background(controlState.actionA ? Color.orange : Color.gray)
                            .foregroundColor(.black)
                            .cornerRadius(25)
                    }
                    .onLongPressGesture(minimumDuration: 0.01, perform: {}) { pressing in
                        controlState.actionA = pressing
                    }

                    // Action B button
                    Button(action: {}) {
                        Text("B")
                            .font(.headline)
                            .fontWeight(.bold)
                            .frame(width: 50, height: 50)
                            .background(controlState.actionB ? Color.orange : Color.gray)
                            .foregroundColor(.black)
                            .cornerRadius(25)
                    }
                    .onLongPressGesture(minimumDuration: 0.01, perform: {}) { pressing in
                        controlState.actionB = pressing
                    }
                }
            }
            .padding(.trailing, 12)
            .padding(.bottom, 20)
        }
        .onAppear {
            controllerManager.setupControllers(controlState: $controlState)
        }
        .onReceive(controllerManager.$isConnected) { connected in
            isControllerConnected = connected
        }
    }
}

class GameControllerManager: NSObject, ObservableObject {
    @Published var isConnected = false
    private var controlStateBinding: Binding<GameControlState>?
    private var displayLink: CADisplayLink?

    override init() {
        super.init()
    }

    func setupControllers(controlState: Binding<GameControlState>) {
        self.controlStateBinding = controlState
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(controllerDidConnect),
            name: NSNotification.Name.GCControllerDidConnect,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(controllerDidDisconnect),
            name: NSNotification.Name.GCControllerDidDisconnect,
            object: nil
        )

        if let controller = GCController.controllers().first {
            DispatchQueue.main.async {
                self.isConnected = true
                print("[GameController] Already connected: \(controller.vendorName ?? "Unknown")")
            }
            startPollingController(controller)
        }
    }

    @objc func controllerDidConnect(_ notification: Notification) {
        if let controller = notification.object as? GCController {
            DispatchQueue.main.async {
                self.isConnected = true
                print("[GameController] ✅ Connected: \(controller.vendorName ?? "Unknown")")
            }
            startPollingController(controller)
        }
    }

    @objc func controllerDidDisconnect(_ notification: Notification) {
        DispatchQueue.main.async {
            self.isConnected = false
            print("[GameController] ❌ Disconnected")
        }
        displayLink?.invalidate()
        displayLink = nil
    }

    private func startPollingController(_ controller: GCController) {
        // Use CADisplayLink for smooth polling at screen refresh rate
        displayLink = CADisplayLink(
            target: self,
            selector: #selector(updateControllerState)
        )
        displayLink?.preferredFramesPerSecond = 60
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc func updateControllerState() {
        guard let controller = GCController.controllers().first,
              let stateBinding = controlStateBinding else { return }

        var state = stateBinding.wrappedValue

        if let gamepad = controller.gamepad {
            // D-Pad
            state.moveX = gamepad.dpad.right.isPressed ? 1.0 : (gamepad.dpad.left.isPressed ? -1.0 : 0.0)
            state.moveY = gamepad.dpad.up.isPressed ? 1.0 : (gamepad.dpad.down.isPressed ? -1.0 : 0.0)
            
            // Buttons
            state.actionA = gamepad.buttonA.isPressed
            state.actionB = gamepad.buttonB.isPressed
            state.sprint = gamepad.leftShoulder.isPressed
            state.jump = gamepad.rightShoulder.isPressed
        } else if let extendedGamepad = controller.extendedGamepad {
            // Analog sticks
            let leftStick = extendedGamepad.leftThumbstick
            state.moveX = Double(leftStick.xAxis.value)
            state.moveY = Double(leftStick.yAxis.value)
            
            // Buttons
            state.actionA = extendedGamepad.buttonA.isPressed
            state.actionB = extendedGamepad.buttonB.isPressed
            state.sprint = extendedGamepad.leftShoulder.isPressed
            state.jump = extendedGamepad.rightShoulder.isPressed
        }

        DispatchQueue.main.async {
            stateBinding.wrappedValue = state
        }
    }

    deinit {
        displayLink?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
}

// Analog Stick View for Touch Input
struct AnalogStickView: View {
    @Binding var moveX: Double
    @Binding var moveY: Double
    
    @State private var dragOffset: CGSize = .zero
    let radius: CGFloat = 50

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                .frame(width: 120, height: 120)

            Circle()
                .fill(Color.orange.opacity(0.7))
                .frame(width: 35, height: 35)
                .offset(dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let offset = value.translation
                            let distance = sqrt(offset.width * offset.width + offset.height * offset.height)

                            if distance <= radius {
                                dragOffset = offset
                            } else {
                                let angle = atan2(offset.height, offset.width)
                                dragOffset = CGSize(
                                    width: cos(angle) * radius,
                                    height: sin(angle) * radius
                                )
                            }

                            moveX = Double(dragOffset.width / radius)
                            moveY = -Double(dragOffset.height / radius)
                        }
                        .onEnded { _ in
                            dragOffset = .zero
                            moveX = 0
                            moveY = 0
                        }
                )
        }
        .frame(width: 120, height: 120)
        .background(Color.black.opacity(0.5))
        .cornerRadius(60)
    }
}
