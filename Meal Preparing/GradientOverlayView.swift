//
//  GradientOverlayView.swift
//  Meal Preparing
//
//  Created by JoshipTy on 11/8/24.
//

import UIKit

class GradientOverlayView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupGradient()
    }
    
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor.clear.cgColor, // Fully transparent
            UIColor.clear.cgColor, // Still transparent
            UIColor.black.withAlphaComponent(0.5).cgColor, // Semi-transparent
            UIColor.black.cgColor // Fully opaque
        ]
        
        gradientLayer.locations = [0.1, 0.6, 0.8, 1.2]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        self.layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update gradient layer frame when the view’s layout changes
        gradientLayer.frame = self.bounds
    }
}
class GradientOverlayView1: UIView {
    
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupGradient()
    }
    
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor.clear.cgColor, // Fully transparent
            UIColor.clear.cgColor, // Still transparent
            UIColor.black.withAlphaComponent(0.5).cgColor, // Semi-transparent
            UIColor.black.cgColor // Fully opaque
        ]
        
        gradientLayer.locations = [0.2, 0.6, 0.8, 1.2]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        self.layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Update gradient layer frame when the view’s layout changes
        gradientLayer.frame = self.bounds
    }
}
