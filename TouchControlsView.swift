import SwiftUI
import GameController
import CoreHaptics

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
                    // Sprint button (top)
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

                    // Jump button (bottom)
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
                    // Action A button (top)
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

                    // Action B button (bottom)
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
            controllerManager.setupControllers()
        }
        .onReceive(controllerManager.$currentController) { controller in
            isControllerConnected = controller != nil
            if let controller = controller {
                updateStateFromController(controller, &controlState)
            }
        }
    }

    private func updateStateFromController(_ controller: GCController, _ state: inout GameControlState) {
        if let gamepad = controller.gamepad {
            // D-Pad for movement
            if gamepad.dpad.right.isPressed {
                state.moveX = 1.0
            } else if gamepad.dpad.left.isPressed {
                state.moveX = -1.0
            } else {
                state.moveX = 0.0
            }

            if gamepad.dpad.up.isPressed {
                state.moveY = 1.0
            } else if gamepad.dpad.down.isPressed {
                state.moveY = -1.0
            } else {
                state.moveY = 0.0
            }

            // Buttons
            state.actionA = gamepad.buttonA.isPressed
            state.actionB = gamepad.buttonB.isPressed
            state.sprint = gamepad.leftShoulder.isPressed
            state.jump = gamepad.rightShoulder.isPressed
        } else if let extendedGamepad = controller.extendedGamepad {
            // Extended gamepad with analog sticks
            let leftStick = extendedGamepad.leftThumbstick
            state.moveX = Double(leftStick.xAxis.value)
            state.moveY = Double(leftStick.yAxis.value)

            state.actionA = extendedGamepad.buttonA.isPressed
            state.actionB = extendedGamepad.buttonB.isPressed
            state.sprint = extendedGamepad.leftShoulder.isPressed
            state.jump = extendedGamepad.rightShoulder.isPressed
        }
    }
}

class GameControllerManager: NSObject, ObservableObject {
    @Published var currentController: GCController?

    override init() {
        super.init()
    }

    func setupControllers() {
        // Listen for controller connections
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

        // Check if a controller is already connected
        if let controller = GCController.controllers().first {
            self.currentController = controller
            print("[Controller] Controller already connected: \(controller.vendorName ?? "Unknown")")
        }
    }

    @objc func controllerDidConnect(_ notification: Notification) {
        if let controller = notification.object as? GCController {
            DispatchQueue.main.async {
                self.currentController = controller
                print("[Controller] ✅ Controller connected: \(controller.vendorName ?? "Unknown")")
            }
        }
    }

    @objc func controllerDidDisconnect(_ notification: Notification) {
        DispatchQueue.main.async {
            self.currentController = nil
            print("[Controller] ❌ Controller disconnected")
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// Analog Stick View for Touch Input
struct AnalogStickView: View {
    @Binding var moveX: Double
    @Binding var moveY: Double
    
    @State private var isDragging = false
    @State private var dragOffset: CGSize = .zero
    
    let radius: CGFloat = 50

    var body: some View {
        ZStack {
            // Outer circle (background)
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                .frame(width: 120, height: 120)

            // Inner circle (indicator)
            Circle()
                .fill(Color.orange.opacity(0.7))
                .frame(width: 35, height: 35)
                .offset(dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            isDragging = true
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
                            isDragging = false
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
