//
//  MainWindow.swift
//  DebugMode
//
//  Created by JunHyeok Lee on 12/30/25.
//

import UIKit

final class MainWindow: UIWindow {
    
    private var touchViews: [UITouch: UIView] = [:]
    
    #if DEBUG
    private var debugFloatingButton: DebugFloatingButton?
    #endif
    
    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        #if DEBUG
        setupDebugButton()
        #endif
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        #if DEBUG
        if let debugButton = debugFloatingButton {
            bringSubviewToFront(debugButton)
        }
        #endif
    }
    
    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        handleDebugTouches(event)
    }
    
    #if DEBUG
    private func setupDebugButton() {
        let buttonSize: CGFloat = 48
        let initialX = bounds.width - buttonSize - 16
        let initialY = bounds.height - buttonSize - 100
        let button = DebugFloatingButton(frame: CGRect(x: initialX, y: initialY, width: buttonSize, height: buttonSize))
        addSubview(button)
        
        button.onTap = { [weak self] in
            self?.showDebugSettings()
        }
        
        self.debugFloatingButton = button
    }
    #endif
    
    #if DEBUG
    private func showDebugSettings() {
        guard let rootViewController = self.rootViewController else { return }
        
        let settingsViewController = DebugSettingsViewController()
        let navigationController = UINavigationController(rootViewController: settingsViewController)
        
        rootViewController.present(navigationController, animated: true)
    }
    #endif
    
    private func handleDebugTouches(_ event: UIEvent) {
    #if DEBUG
        guard let touches = event.allTouches else { return }
        // guard let { UserDefaults 등에 저장한 디버그 포인터 노출 여부 } else { return }
        
        for touch in touches {
            let point = touch.location(in: self)
            switch touch.phase {
            case .began:
                let dot = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                dot.backgroundColor = UIColor.red.withAlphaComponent(0.5)
                dot.layer.cornerRadius = 15
                dot.isUserInteractionEnabled = false
                dot.center = point
                self.addSubview(dot)
                touchViews[touch] = dot
                
            case .moved:
                UIView.animate(withDuration: 0.05) {
                    self.touchViews[touch]?.center = point
                }
                
            case .ended, .cancelled:
                if let view = touchViews[touch] {
                    UIView.animate(
                        withDuration: 0.2,
                        animations: {
                            view.alpha = 0
                        },
                        completion: { _ in
                            view.removeFromSuperview()
                        }
                    )
                    touchViews.removeValue(forKey: touch)
                }
            default:
                break
            }
        }
    #endif
    }
}
