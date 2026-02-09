//
//  DebugFloatingButton.swift
//  DebugMode
//
//  Created by JunHyeok Lee on 12/30/25.
//

#if DEBUG
import SwiftUI

struct DebugFloatingButton: View {

    private enum Constants {
        static let buttonSize: CGFloat = 48
        static let buttonCornerRadius: CGFloat = 24
        static let edgePadding: CGFloat = 16
    }

    @State private var position: CGPoint = .zero
    @State private var isDragging = false
    @Binding var isSettingsPresented: Bool

    var body: some View {
        GeometryReader { geometry in
            Button {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isSettingsPresented = true
                }
            } label: {
                Text("🔨")
                    .font(.system(size: 24))
                    .frame(width: Constants.buttonSize, height: Constants.buttonSize)
                    .background(Color.orange.opacity(0.8))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            .scaleEffect(isDragging ? 1.1 : 1.0)
            .position(position)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        var newPosition = value.location

                        // 화면 경계 제한
                        let halfSize = Constants.buttonSize / 2
                        newPosition.x = max(
                            halfSize + Constants.edgePadding,
                            min(geometry.size.width - halfSize - Constants.edgePadding, newPosition.x)
                        )
                        newPosition.y = max(
                            halfSize + Constants.edgePadding,
                            min(geometry.size.height - halfSize - Constants.edgePadding, newPosition.y)
                        )

                        position = newPosition
                    }
                    .onEnded { value in
                        isDragging = false
                        snapToEdge(in: geometry.size)
                    }
            )
            .onAppear {
                // 초기 위치 설정 (오른쪽 하단)
                position = CGPoint(
                    x: geometry.size.width - Constants.buttonSize - Constants.edgePadding,
                    y: geometry.size.height - Constants.buttonSize - 100
                )
            }
        }
    }

    private func snapToEdge(in size: CGSize) {
        let finalX: CGFloat
        if position.x < size.width / 2 {
            finalX = Constants.buttonSize / 2 + Constants.edgePadding
        } else {
            finalX = size.width - Constants.buttonSize / 2 - Constants.edgePadding
        }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            position.x = finalX
        }
    }
}

#Preview {
    DebugFloatingButton(isSettingsPresented: .constant(false))
}
#endif
