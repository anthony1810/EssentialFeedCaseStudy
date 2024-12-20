//
//  ErrorView.swift
//  EssentialFeed
//
//  Created by Anthony on 5/11/24.
//
import Foundation
import UIKit

public final class ErrorView: UIButton {
    public var message: String? {
        get { return isVisible ? configuration?.title : nil }
    }
    
    public var onHide: (() -> Void)?

    private var isVisible: Bool {
        return alpha > 0
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()

        self.setTitle(nil, for: .normal)
        alpha = 0
    }
    
    private func configure() {
        var configuration = Configuration.plain()
        configuration.titlePadding = 0
        configuration.baseForegroundColor = .white
        configuration.background.backgroundColor = .backgroundErrorColor
        configuration.background.cornerRadius = 0
        self.configuration = configuration
        
        addTarget(self, action: #selector(hideMessageAnimation), for: .touchUpInside)
        
        hideMessage()
    }
    
    private func hideMessage() {
        onHide?()
        configuration?.attributedTitle = nil
        configuration?.contentInsets = .zero
        alpha = 0
    }
    
    private var titleAttributes: AttributeContainer {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        
        var attributes = AttributeContainer()
        attributes.paragraphStyle = paragraphStyle
        attributes.font = UIFont.preferredFont(forTextStyle: .body)
        return attributes
    }
    
    
    private func configureLabel() {
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 17)
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center
    }

    func show(message: String) {
        configuration?.attributedTitle = AttributedString(message, attributes: titleAttributes)
        
        configuration?.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }

    @objc func hideMessageAnimation() {
        print("hideMessageAnimation")
        UIView.animate(
            withDuration: 0.25,
            animations: { self.alpha = 0 },
            completion: { completed in
                if completed {
                    self.hideMessage()
                }
            })
    }
}

extension UIColor {
    static var backgroundErrorColor: UIColor {
        UIColor(red: 0.99951404330000004, green: 0.41759261489999999, blue: 0.4154433012, alpha: 1)
    }
}
