//
//  DebugOverlayModifier.swift
//  DebugMode
//
//  Created by JunHyeok Lee on 12/30/25.
//

#if DEBUG
import SwiftUI
import UIKit

// MARK: - Touch Tracking Gesture Recognizer

final class TouchTrackingGestureRecognizer: UIGestureRecognizer {

    var onTouchesChanged: (([CGPoint]) -> Void)?

    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        cancelsTouchesInView = false
        delaysTouchesBegan = false
        delaysTouchesEnded = false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        updateTouches(event: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        updateTouches(event: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        updateTouches(event: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        updateTouches(event: event)
    }

    private func updateTouches(event: UIEvent?) {
        guard let allTouches = event?.allTouches else {
            onTouchesChanged?([])
            return
        }

        let activeTouches = allTouches.filter { $0.phase == .began || $0.phase == .moved || $0.phase == .stationary }
        let locations = activeTouches.map { $0.location(in: self.view) }
        onTouchesChanged?(locations)
    }
}

// MARK: - Multi Touch Tracking View

final class MultiTouchTrackingUIView: UIView {

    var onTouchesChanged: (([CGPoint]) -> Void)? {
        didSet {
            gestureRecognizer?.onTouchesChanged = onTouchesChanged
        }
    }

    private var gestureRecognizer: TouchTrackingGestureRecognizer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = true
        backgroundColor = .clear
        isUserInteractionEnabled = true
        setupGestureRecognizer()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupGestureRecognizer() {
        let gesture = TouchTrackingGestureRecognizer(target: nil, action: nil)
        gesture.onTouchesChanged = onTouchesChanged
        gesture.delegate = self
        addGestureRecognizer(gesture)
        gestureRecognizer = gesture
    }
}

extension MultiTouchTrackingUIView: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }
}

// MARK: - Multi Touch Tracking View (SwiftUI)

struct MultiTouchTrackingView: UIViewRepresentable {

    var onTouchesChanged: ([CGPoint]) -> Void

    func makeUIView(context: Context) -> MultiTouchTrackingUIView {
        let view = MultiTouchTrackingUIView()
        view.onTouchesChanged = onTouchesChanged
        return view
    }

    func updateUIView(_ uiView: MultiTouchTrackingUIView, context: Context) {
        uiView.onTouchesChanged = onTouchesChanged
    }
}

// MARK: - Touch Pointer

struct TouchPointer: Identifiable {
    let id: Int
    var location: CGPoint
}

// MARK: - Debug Overlay Modifier

struct DebugOverlayModifier: ViewModifier {

    @State private var isSettingsPresented = false
    @State private var showTouchPointer = true
    @State private var touchPointers: [TouchPointer] = []

    func body(content: Content) -> some View {
        content
            // 멀티 터치 감지 레이어 (터치 통과)
            .overlay {
                if showTouchPointer {
                    MultiTouchTrackingView { locations in
                        updatePointers(locations: locations)
                    }
                    .allowsHitTesting(false)
                }
            }
            // 터치 포인터 표시 (터치 통과)
            .overlay {
                if showTouchPointer {
                    ForEach(touchPointers) { pointer in
                        Circle()
                            .fill(Color.red.opacity(0.5))
                            .frame(width: 30, height: 30)
                            .position(pointer.location)
                    }
                    .allowsHitTesting(false)
                }
            }
            // 플로팅 디버그 버튼 (터치 가능)
            .overlay {
                DebugFloatingButton(isSettingsPresented: $isSettingsPresented)
            }
            .sheet(isPresented: $isSettingsPresented) {
                DebugSettingsView(showTouchPointer: $showTouchPointer)
            }
    }

    private func updatePointers(locations: [CGPoint]) {
        if locations.isEmpty {
            withAnimation(.easeOut(duration: 0.2)) {
                touchPointers.removeAll()
            }
        } else {
            touchPointers = locations.enumerated().map { index, location in
                TouchPointer(id: index, location: location)
            }
        }
    }
}

// MARK: - View Extension

extension View {
    /// 디버그 모드 오버레이를 추가합니다.
    /// - 플로팅 디버그 버튼
    /// - 터치 포인터 (설정에서 on/off 가능)
    func debugOverlay() -> some View {
        modifier(DebugOverlayModifier())
    }
}

#Preview {
    Text("Hello, Debug Mode!")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
        .debugOverlay()
}
#endif
