//
//  DebugSettingsViewController.swift
//  DebugMode
//
//  Created by JunHyeok Lee on 12/30/25.
//

#if DEBUG
import UIKit

// MARK: - DebugSettingsViewController

final class DebugSettingsViewController: UIViewController {
    
    private enum BuildConfiguration: String {
        case debug
        case release
        
        init() {
#if DEBUG
        self = .debug
#else
        self = .release
#endif
        }
    }
    
    private enum DebugSection: Int, CaseIterable {
        case toggleOptions
        case info
        case storage
        case crash
        
        static func row(indexPath: IndexPath) -> DebugOptionRow? {
            guard let section = Self(rawValue: indexPath.section) else { return nil }
            guard section.sectionRows.count > indexPath.row else { return nil }
            let row = section.sectionRows[indexPath.row]
            return row
        }
        
        var sectionRows: [DebugOptionRow] {
            switch self {
            case .toggleOptions:
                return [.showDebugTouchPointer]
            case .info:
                return [.environment, .deviceInfo, .appVersion]
            case .storage:
                return [.clearCache, .clearUserDefaults]
            case .crash:
                return [.forceCrash]
            }
        }
        
        var headerTitle: String {
            switch self {
            case .toggleOptions:
                return "옵션"
            case .info:
                return "정보"
            case .storage:
                return "저장공간"
            case .crash:
                return "강제 크래시"
            }
        }
    }
    
    private enum DebugOptionRow: CaseIterable {
        
        case showDebugTouchPointer
        
        case environment
        case deviceInfo
        case appVersion
        
        case clearCache
        case clearUserDefaults
        
        case forceCrash
        
        var title: String {
            switch self {
            case .showDebugTouchPointer:
                return "터치 포인터"
            case .environment:
                return "개발환경"
            case .deviceInfo:
                return "디바이스 정보"
            case .appVersion:
                return "앱 버전"
            case .clearCache:
                return "Clear Image Cache"
            case .clearUserDefaults:
                return "Clear UserDefaults"
            case .forceCrash:
                return "Force Crash (Test)"
            }
        }
        
        var subtitle: String? {
            switch self {
            case .environment:
#if DEBUG
                return "Development"
#else
                return "Production"
#endif
            case .appVersion:
                let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
                let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
                return "\(version) (\(build))"
            case .deviceInfo:
                return UIDevice.current.model
            case .showDebugTouchPointer,
                    .clearCache,
                    .clearUserDefaults,
                    .forceCrash:
                return nil
            }
        }
        
        var isDestructive: Bool {
            switch self {
            case .clearCache, .clearUserDefaults, .forceCrash:
                return true
            default:
                return false
            }
        }
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView(
            frame: .zero,
            style: .insetGrouped
        )
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "Cell"
        )
        tableView.register(
            DebugToggleTableViewCell.self,
            forCellReuseIdentifier: "DebugToggleTableViewCell"
        )
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addSubviews()
        setupLayoutConstraints()
    }
    
    private func setupUI() {
        title = "Debug Settings"
        view.backgroundColor = .systemGroupedBackground
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func handleOption(_ option: DebugOptionRow) {
        switch option {
        case .showDebugTouchPointer:
            break
            
        case .environment:
            showEnvironmentInfo()
            
        case .clearCache:
            showConfirmationAlert(
                title: "Clear Image Cache",
                message: "모든 이미지 캐시 데이터를 제거합니다."
            ) { [weak self] in
                self?.clearCache()
            }
            
        case .clearUserDefaults:
            showConfirmationAlert(
                title: "Clear UserDefaults",
                message: "저장된 모든 UserDefaults를 제거합니다."
            ) { [weak self] in
                self?.clearUserDefaults()
            }
            
        case .deviceInfo:
            showDeviceInfo()
            
        case .appVersion:
            showAppVersionInfo()
            
        case .forceCrash:
            showConfirmationAlert(
                title: "Force Crash",
                message: "앱을 강제종료합니다."
            ) {
                fatalError("Debug force crash")
            }
        }
    }
    
    private func clearCache() {
        URLCache.shared.removeAllCachedResponses()
        showAlert(title: nil, message: "Image Cache 삭제 완료")
    }
    
    private func clearUserDefaults() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        showAlert(title: nil, message: "UserDefaults 삭제 완료")
    }
    
    private func showEnvironmentInfo() {
    
        let buildConfiguration = BuildConfiguration()
        let message = """
        Build Configuration: \(buildConfiguration.rawValue)
        """
        
        showCopyableAlert(title: "Environment", message: message)
    }
    
    private func showDeviceInfo() {
        let device = UIDevice.current
        let message = """
        Device: \(device.model)
        System: \(device.systemName) \(device.systemVersion)
        Identifier: \(device.identifierForVendor?.uuidString ?? "Unknown")
        """
        
        showCopyableAlert(title: "디바이스 정보", message: message)
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
    
    
    /// 복사가능 Alert
    private func showCopyableAlert(
        title: String?,
        message: String
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "복사", style: .default) { _ in
            UIPasteboard.general.string = message
        })
        
        alert.addAction(UIAlertAction(title: "확인", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // 확인 취소 Alert
    private func showConfirmationAlert(
        title: String?,
        message: String,
        action: @escaping () -> Void
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "취소",
            style: .cancel
        ))
        alert.addAction(UIAlertAction(
            title: "진행",
            style: .destructive
        ) { _ in
            action()
        })
        present(alert, animated: true)
    }
    
    // 확인 Alert
    private func showAlert(
        title: String?,
        message: String
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: "확인",
            style: .default
        ))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension DebugSettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return DebugSection.allCases.count
    }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return DebugSection(rawValue: section)?.sectionRows.count ?? 0
    }
    
    func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        return DebugSection(rawValue: section)?.headerTitle
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        guard let section = DebugSection(rawValue: indexPath.section) else {
            return tableView.dequeueReusableCell(
                withIdentifier: "Cell",
                for: indexPath
            )
        }
        guard let option = DebugSection.row(indexPath: indexPath) else {
            return tableView.dequeueReusableCell(
                withIdentifier: "Cell",
                for: indexPath
            )
        }
        
        if case .toggleOptions = section {
            // 토글버튼 Cell
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "DebugToggleTableViewCell",
                for: indexPath
            ) as? DebugToggleTableViewCell else {
                return UITableViewCell()
            }
//            let isOn = { UserDefaults 등에 저장한 디버그 포인터 노출 여부 }
            let isOn = true
            cell.configure(
                title: option.title,
                isOn: isOn
            ) { isOn in
                // { UserDefaults 등 디버그 포인터 값 toggle
            }
            return cell
        }
        
        // 기본 Cell
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "Cell",
            for: indexPath
        )
        
        var configuration = cell.defaultContentConfiguration()
        configuration.text = option.title
        configuration.secondaryText = option.subtitle
        
        if option.isDestructive {
            configuration.textProperties.color = .systemRed
        }
        
        cell.contentConfiguration = configuration
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension DebugSettingsViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let option = DebugSection.row(indexPath: indexPath) else { return }
        handleOption(option)
    }
}


// MARK: - Layout
extension DebugSettingsViewController {
    private func addSubviews() {
        view.addSubview(tableView)
    }
    
    private func setupLayoutConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

#endif

