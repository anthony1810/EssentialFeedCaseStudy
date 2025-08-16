//
//  ErrorView.swift
//  EssentialFeed
//
//  Created by Anthony on 27/3/25.
//
import UIKit

public final class ErrorView: UIButton {
    public var message: String? {
        get { return isVisible ? title(for: .normal) : nil }
        set { setMessageAnimated(newValue) }
    }
    
    public var onHide: (() -> Void)?
    
    private let backgroundView = UIView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
        
    private func configure() {
        setupBackgroundView()
        addTarget(self, action: #selector(hideMessageAnimated), for: .touchUpInside)
        configureLabel()
        hideMessage()
    }
    
    private func setupBackgroundView() {
        backgroundView.backgroundColor = .errorBackgroundColor
        backgroundView.layer.cornerRadius = 0
        backgroundView.isUserInteractionEnabled = false
        
        addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func configureLabel() {
        // Clear button's default styling
        backgroundColor = .clear
        
        // Configure title label directly
        titleLabel?.numberOfLines = 0
        titleLabel?.font = .preferredFont(forTextStyle: .body)
        titleLabel?.adjustsFontForContentSizeCategory = true
        titleLabel?.textAlignment = .center
        titleLabel?.lineBreakMode = .byWordWrapping
        
        // Set title color
        setTitleColor(.secondaryLabel, for: .normal)
        setTitleColor(.secondaryLabel, for: .highlighted)
    }
        
    private var isVisible: Bool {
        return alpha > 0
    }
    
    private func setMessageAnimated(_ message: String?) {
        if let message = message {
            showAnimated(message)
        } else {
            hideMessageAnimated()
        }
    }

    private func showAnimated(_ message: String) {
        setTitle(message, for: .normal)
        contentEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)

        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
    
    @objc private func hideMessageAnimated() {
        UIView.animate(
            withDuration: 0.25,
            animations: { self.alpha = 0 },
            completion: { completed in
                if completed { self.hideMessage() }
            })
    }
    
    private func hideMessage() {
        setTitle(nil, for: .normal)
        alpha = 0
        contentEdgeInsets = .init(top: -2.5, left: 0, bottom: -2.5, right: 0)
        onHide?()
    }
}

extension UIColor {
    static var errorBackgroundColor: UIColor {
        UIColor(red: 0.99951404330000004, green: 0.41759261489999999, blue: 0.4154433012, alpha: 1)
    }
}