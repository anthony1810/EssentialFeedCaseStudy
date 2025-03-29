//
//  ErrorView.swift
//  EssentialFeed
//
//  Created by Anthony on 27/3/25.
//
import UIKit

public final class ErrorView: UIView {
    @IBOutlet private var button: UIButton!
    
    public var message: String? {
        get { button.title(for: .normal) }
        set { button.setTitle(newValue, for: .normal) }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        button.setTitle(nil, for: .normal)
    }
    
    private var isVisible: Bool {
        alpha > 0
    }
    
    private func setMessageAnimated(_ message: String?) {
        if let message {
            showAnimated(message)
        } else {
            hideMessageAnimated()
        }
    }
    
    private func showAnimated(_ message: String) {
        button.setTitle(message, for: .normal)
        
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }
    
    private func hideMessageAnimated() {
        UIView.animate(
            withDuration: 0.25,
            animations: { self.alpha = 0},
            completion: { completed in
                if !completed { return }
                self.button.setTitle(nil, for: .normal)
            })
    }
}
