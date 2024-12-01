import UIKit

final class UIAnimationImageView: UIImageView {
    func startAnimating(with delay: TimeInterval) {
        guard let animationImages
        else { return }
        
        let repeatCount = (animationRepeatCount == 0)
        ? Float.greatestFiniteMagnitude
        : Float(animationRepeatCount)
        
        let animationGroup = CAAnimationGroup()
        animationGroup.repeatCount = repeatCount
        animationGroup.duration = animationDuration + delay
        
        let keyPath = #keyPath(CALayer.contents)
        let animation = CAKeyframeAnimation(keyPath: keyPath)
        animation.values = animationImages.map { $0.cgImage as AnyObject }
        animation.duration = animationDuration
        animation.calculationMode = .linear
        
        animationGroup.animations = [animation]
        layer.contents = animationImages.last?.cgImage
        layer.add(animationGroup, forKey: keyPath)
    }
    
    func stopAllAnimating() {
        let keyPath = #keyPath(CALayer.contents)
        layer.removeAnimation(forKey: keyPath)
        
        stopAnimating()
    }
}
