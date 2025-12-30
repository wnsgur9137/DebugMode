//
//  DebugFloatingButton.swift
//  DebugMode
//
//  Created by JunHyeok Lee on 12/30/25.
//

#if DEBUG
import UIKit
import Combine

final class DebugFloatingButton: UIView {
    
    struct Constants {
        static let buttonSize: CGFloat = 40
        static let buttonCornerRadius: CGFloat = 24
    }
    
    private let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemOrange.withAlphaComponent(0.8)
        button.setTitle("🔨", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24)
        button.layer.cornerRadius = Constants.buttonCornerRadius
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.3
        return button
    }()
    
    var onTap: (() -> Void)?
    
    private var panGesture: UIPanGestureRecognizer?
    private var initialCenter: CGPoint = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setupLayoutConstraints()
        setupGestures()
        addButtonAction()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupGestures() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        guard let panGesture = panGesture else { return }
        addGestureRecognizer(panGesture)
    }
    
    private func addButtonAction() {
        button.addAction(
            UIAction { [weak self] _ in
                UIView.animate(
                    withDuration: 0.1,
                    animations: { [weak self] in
                        self?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                    },
                    completion: { [weak self] _ in
                        self?.transform = .identity
                    }
                )
                self?.onTap?()
            },
            for: .touchUpInside
        )
    }
    
    @objc
    private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let superview = superview else { return }
        
        switch gesture.state {
        case .began:
            initialCenter = center
            
        case .changed:
            let translation = gesture.translation(in: superview)
            var newCenter = CGPoint(
                x: initialCenter.x + translation.x,
                y: initialCenter.y + translation.y
            )
            
            // 화면 경계 제한
            let buttonRadius: CGFloat = Constants.buttonCornerRadius
            let padding: CGFloat = 16
            
            newCenter.x = max(
                buttonRadius + padding,
                min(
                    superview.bounds.width - buttonRadius - padding,
                    newCenter.x
                )
            )
            newCenter.y = max(
                buttonRadius + padding,
                min(
                    superview.bounds.height - buttonRadius - padding,
                    newCenter.y
                )
            )
            
            center = newCenter
            
        case .ended:
            // 화면 가장자리로 스냅
            snapToEdge(in: superview)
            
        default:
            break
        }
    }
    
    private func snapToEdge(in superview: UIView) {
        let screenWidth = superview.bounds.width
        let finalX: CGFloat
        
        if center.x < screenWidth / 2 {
            finalX = 40 // 왼쪽 가장자리
        } else {
            finalX = screenWidth - 40 // 오른쪽 가장자리
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.center.x = finalX
        }
    }
    
    private func addSubviews() {
        addSubview(button)
    }
    
    private func setupLayoutConstraints() {
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
            button.widthAnchor.constraint(equalToConstant: Constants.buttonSize),
            button.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            button.topAnchor.constraint(equalTo: self.topAnchor),
            button.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
}
#endif
