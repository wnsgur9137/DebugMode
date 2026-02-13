//
//  DebugSettingsView.swift
//  DebugMode
//
//  Created by JunHyeok Lee on 12/30/25.
//

#if DEBUG
import SwiftUI

struct DebugSettingsView: View {

    @Environment(\.dismiss) private var dismiss
    @Binding var showTouchPointer: Bool

    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var alertActions: [AlertAction] = []

    private struct AlertAction: Identifiable {
        let id = UUID()
        let title: String
        let role: ButtonRole?
        let action: () -> Void
    }

    var body: some View {
        NavigationStack {
            List {
                // 옵션 섹션
                Section("옵션") {
                    Toggle("터치 포인터", isOn: $showTouchPointer)
                }

                // 정보 섹션
                Section("정보") {
                    InfoRow(title: "개발환경", subtitle: buildConfiguration) {
                        showEnvironmentInfo()
                    }

                    InfoRow(title: "디바이스 정보", subtitle: deviceModel) {
                        showDeviceInfo()
                    }

                    InfoRow(title: "앱 버전", subtitle: appVersion) {
                        showAppVersionInfo()
                    }
                }

                // 저장공간 섹션
                Section("저장공간") {
                    Button("Clear Image Cache") {
                        showConfirmation(
                            title: "Clear Image Cache",
                            message: "모든 이미지 캐시 데이터를 제거합니다."
                        ) {
                            clearCache()
                        }
                    }
                    .foregroundColor(.red)

                    Button("Clear UserDefaults") {
                        showConfirmation(
                            title: "Clear UserDefaults",
                            message: "저장된 모든 UserDefaults를 제거합니다."
                        ) {
                            clearUserDefaults()
                        }
                    }
                    .foregroundColor(.red)
                }

                // 강제 크래시 섹션
                Section("강제 크래시") {
                    Button("Force Crash (Test)") {
                        showConfirmation(
                            title: "Force Crash",
                            message: "앱을 강제종료합니다."
                        ) {
                            fatalError("Debug force crash")
                        }
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Debug Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                ForEach(alertActions) { action in
                    Button(action.title, role: action.role) {
                        action.action()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Computed Properties

    private var buildConfiguration: String {
        #if DEBUG
        return "Development"
        #else
        return "Production"
        #endif
    }

    private var deviceModel: String {
        #if os(iOS)
        return UIDevice.current.model
        #else
        return "Unknown"
        #endif
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        return "\(version) (\(build))"
    }

    // MARK: - Actions

    private func showEnvironmentInfo() {
        let message = "Build Configuration: \(buildConfiguration)"
        showCopyableAlert(title: "Environment", message: message)
    }

    private func showDeviceInfo() {
        #if os(iOS)
        let device = UIDevice.current
        let message = """
        Device: \(device.model)
        System: \(device.systemName) \(device.systemVersion)
        Identifier: \(device.identifierForVendor?.uuidString ?? "Unknown")
        """
        showCopyableAlert(title: "디바이스 정보", message: message)
        #endif
    }

    private func showAppVersionInfo() {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        let bundleId = Bundle.main.bundleIdentifier ?? "Unknown"

        let message = """
        Version: \(version)
        Build: \(build)
        Bundle ID: \(bundleId)
        """
        showCopyableAlert(title: "앱 버전", message: message)
    }

    private func clearCache() {
        URLCache.shared.removeAllCachedResponses()
        showSimpleAlert(title: nil, message: "Image Cache 삭제 완료")
    }

    private func clearUserDefaults() {
        if let domain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
        }
        showSimpleAlert(title: nil, message: "UserDefaults 삭제 완료")
    }

    // MARK: - Alert Helpers

    private func showCopyableAlert(title: String?, message: String) {
        alertTitle = title ?? ""
        alertMessage = message
        alertActions = [
            AlertAction(title: "복사", role: nil) {
                #if os(iOS)
                UIPasteboard.general.string = message
                #endif
            },
            AlertAction(title: "확인", role: .cancel) {}
        ]
        showingAlert = true
    }

    private func showConfirmation(title: String?, message: String, action: @escaping () -> Void) {
        alertTitle = title ?? ""
        alertMessage = message
        alertActions = [
            AlertAction(title: "취소", role: .cancel) {},
            AlertAction(title: "진행", role: .destructive, action: action)
        ]
        showingAlert = true
    }

    private func showSimpleAlert(title: String?, message: String) {
        alertTitle = title ?? ""
        alertMessage = message
        alertActions = [
            AlertAction(title: "확인", role: .cancel) {}
        ]
        showingAlert = true
    }
}

// MARK: - InfoRow

private struct InfoRow: View {
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                Text(subtitle)
                    .foregroundColor(.secondary)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    DebugSettingsView(showTouchPointer: .constant(true))
}
#endif
