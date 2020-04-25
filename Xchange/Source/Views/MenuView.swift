//
//  Menu.swift
//  Xchange
//
//  Created by Yehor Sorokin on 19.02.2020.
//  Copyright © 2020 Yehor Sorokin. All rights reserved.
//

import UIKit
import Foundation


///--------------------------------
/// TODO:
///
///   - Implement navigation actions on reciever and connect them with menu buttons
///   - Consider replacing labels with buttons ( !!! )
///
///--------------------------------

final class MenuView: UIView {
    
    var isExpanded: Bool = false
    
    // MARK: - Subviews
    
    internal lazy var visualView: UIVisualEffectView = {
        let visual = UIVisualEffectView()
        visual.translatesAutoresizingMaskIntoConstraints = false
        visual.effect = UIBlurEffect(style: .dark)
        return visual
    }()
    
    internal let aboutLabel: UILabel = {
        let label = UILabel()
        label.text = "About"
        label.textColor = UIColor.black
        label.font = Config.menuLabelFont
        return label
    }()
    
    internal let scanQRLabel: UILabel = {
        let label = UILabel()
        label.text = "Scan QR code"
        label.textColor = UIColor.black
        label.font = Config.menuLabelFont
        return label
    }()
    
    internal let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.isLayoutMarginsRelativeArrangement = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.layoutMargins = Config.menuHiddenInsets
        return stack
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    // MARK: - Auxilaries
    
    private func commonInit() -> Void {
        backgroundColor = UIColor.white
        stackView.addArrangedSubview(aboutLabel)
        stackView.addArrangedSubview(scanQRLabel)
        addSubview(stackView)
        addSubview(visualView)
        setupConstraints()
    }
    
    private func setupConstraints() -> Void {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.heightAnchor.constraint(equalToConstant: Config.stackHeight),
            visualView.topAnchor.constraint(equalTo: topAnchor),
            visualView.leadingAnchor.constraint(equalTo: leadingAnchor),
            visualView.trailingAnchor.constraint(equalTo: trailingAnchor),
            visualView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
