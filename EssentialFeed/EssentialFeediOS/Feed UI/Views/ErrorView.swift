//
//  ErrorView.swift
//  EssentialFeed
//
//  Created by Anthony on 27/3/25.
//
import UIKit

public final class ErrorView: UIView {
    @IBOutlet public private(set) var button: UIButton!
    
    public var message: String? {
        isVisible ? button.title(for: .normal) : nil
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        button.setTitle(nil, for: .normal)
    }
    
    @IBAction private func didTapButton() {
        hideMessageAnimated()
    }
    
    var isVisible: Bool {
        isHidden == false
    }
    
    func setMessageAnimated(_ message: String?) {
        if let message {
            showAnimated(message)
        } else {
            hideMessageAnimated()
        }
    }
    
    private func showAnimated(_ message: String) {
        isHidden = false
        button.setTitle(message, for: .normal)
        
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }
    
    private func hideMessageAnimated() {
        isHidden = true
        UIView.animate(
            withDuration: 0.25,
            animations: { self.alpha = 0},
            completion: { completed in
                if !completed { return }
                self.button.setTitle(nil, for: .normal)
            })
    }
}
