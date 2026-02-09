//
//  DebugOverlayModifier.swift
//  DebugMode
//
//  Created by JunHyeok Lee on 12/30/25.
//

#if DEBUG
import SwiftUI

// MARK: - Touch Pointer

struct TouchPointer: Identifiable {
    let id = UUID()
    var location: CGPoint
}

// MARK: - Debug Overlay Modifier

struct DebugOverlayModifier: ViewModifier {

    @State private var isSettingsPresented = false
    @State private var showTouchPointer = true
    @State private var touchPointers: [TouchPointer] = []

    func body(content: Content) -> some View {
        content
            .overlay {
                // 터치 포인터 표시
                if showTouchPointer {
                    ForEach(touchPointers) { pointer in
                        Circle()
                            .fill(Color.red.opacity(0.5))
                            .frame(width: 30, height: 30)
                            .position(pointer.location)
                            .allowsHitTesting(false)
                    }
                }

                // 플로팅 디버그 버튼
                DebugFloatingButton(isSettingsPresented: $isSettingsPresented)
            }
            .simultaneousGesture(
                showTouchPointer ? createTouchGesture() : nil
            )
            .sheet(isPresented: $isSettingsPresented) {
                DebugSettingsView(showTouchPointer: $showTouchPointer)
            }
    }

    private func createTouchGesture() -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let newPointer = TouchPointer(location: value.location)
                if touchPointers.isEmpty {
                    touchPointers.append(newPointer)
                } else {
                    touchPointers[0].location = value.location
                }
            }
            .onEnded { _ in
                withAnimation(.easeOut(duration: 0.2)) {
                    touchPointers.removeAll()
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
