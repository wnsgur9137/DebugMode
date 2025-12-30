//
//  DebugToggleTableViewCell.swift
//  DebugMode
//
//  Created by JunHyeok Lee on 12/30/25.
//

#if DEBUG
import UIKit

final class DebugToggleTableViewCell: UITableViewCell {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let toggle: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    var onToggleChanged: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        addSubviews()
        setupLayoutConstraints()
        addToggleAction()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(
        title: String,
        isOn: Bool,
        onToggleChanged: @escaping (Bool) -> Void
    ) {
        titleLabel.text = title
        toggle.isOn = isOn
        self.onToggleChanged = onToggleChanged
    }
    
    private func addToggleAction() {
        toggle.addTarget(self, action: #selector(toggleValueChanged), for: .valueChanged)
    }
    
    @objc
    private func toggleValueChanged() {
        onToggleChanged?(toggle.isOn)
    }
    
    private func addSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(toggle)
    }
    
    private func setupLayoutConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: toggle.leadingAnchor, constant: -16),
            
            toggle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            toggle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
}
#endif

