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
        get { return isVisible ? self.title(for: .normal) : nil }
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
        backgroundColor = .red
        addTarget(self, action: #selector(hideMessageAnimation), for: .touchUpInside)
        configureLabel()
        hideMessage()
    }
    
    private func hideMessage() {
        onHide?()
        setTitle(nil, for: .normal)
        alpha = 0
    }
    
    
    private func configureLabel() {
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 17)
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center
    }

    func show(message: String) {
        self.setTitle(message, for: .normal)

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
                    self.self.setTitle(nil, for: .normal)
                }
            })
    }
}

extension UIColor {
    static var backgroundErrorColor: UIColor {
        UIColor(red: 0.99951404330000004, green: 0.41759261489999999, blue: 0.4154433012, alpha: 1)
    }
}
