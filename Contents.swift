import UIKit
import PlaygroundSupport

extension UIColor {
    convenience init(rgba: Int) {
        self.init(
            red: CGFloat(rgba >> 24) / 255,
            green: CGFloat(rgba >> 16) / 255,
            blue: CGFloat(rgba >> 8) / 255,
            alpha: CGFloat(rgba) / 255
        )
    }
}

class CustomView: UIView {
    var emitterLayer : CAEmitterLayer!;
    var kFSConfettiCellLifetime : Double = 6.0;
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    func setupConfettiAnimation() {
        emitterLayer = CAEmitterLayer();
        emitterLayer.emitterPosition = CGPoint(x: 180, y: -20);
        emitterLayer.emitterShape = kCAEmitterLayerLine;
        emitterLayer.emitterSize = CGSize(width: 360, height: 1);
        emitterLayer.birthRate = 0;
    }
    
    func createCells() -> Array<CAEmitterCell> {
        return [createEmitterCell(color: UIColor.red), createEmitterCell(color: UIColor.orange), createEmitterCell(color: UIColor.blue), createEmitterCell(color: UIColor.green)];
    }
    
    func createEmitterCell(color: UIColor) -> CAEmitterCell {
        let squareView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 8));
        squareView.backgroundColor = color;
        squareView.alpha = 0.75;
        UIGraphicsBeginImageContextWithOptions(squareView.frame.size, false, 0);
        let context = UIGraphicsGetCurrentContext();
        squareView.layer.render(in: context!);
        let squareImage : UIImage! = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        let squareCGImage = squareImage?.cgImage;
        
        
        let squareCell : CAEmitterCell! = CAEmitterCell();
        squareCell.birthRate = 80;
        squareCell.lifetime = Float(kFSConfettiCellLifetime);
        squareCell.color = color.cgColor;
        squareCell.alphaRange = 1.5;
        squareCell.spin = 10;
        squareCell.spinRange = 3;
        squareCell.velocity = 200;
        squareCell.yAcceleration = 500;
        squareCell.emissionLongitude = -CGFloat.pi;
        squareCell.emissionRange = CGFloat.pi;
        squareCell.scaleRange = -0.7;
        squareCell.contents = squareCGImage
        
        
        return squareCell;
    }
    
    func start() {
        emitterLayer.emitterCells = createCells()
        emitterLayer.beginTime = CACurrentMediaTime();
        self.layer.addSublayer(emitterLayer)
        
        let timingFunction : CAMediaTimingFunction! = CAMediaTimingFunction(controlPoints: 0.30, 0, 0, 1.0);
        let initialEmitterWidth : CABasicAnimation! = CABasicAnimation(keyPath: "emitterSize.width");
        initialEmitterWidth.fromValue = 0.1 * emitterLayer.emitterSize.width;
        initialEmitterWidth.toValue   = 1.0 * emitterLayer.emitterSize.width;
        
        let initialBirthRateAnimation : CABasicAnimation! = CABasicAnimation(keyPath: "birthRate");
        initialBirthRateAnimation.fromValue = 0.1;
        initialBirthRateAnimation.toValue   = 1.0;
        
        let initialVelocityRateAnimation : CABasicAnimation! = CABasicAnimation(keyPath: "velocity");
        initialVelocityRateAnimation.fromValue = 0.1;
        initialVelocityRateAnimation.toValue   = 1.0;
        
        let startAnimationGroup : CAAnimationGroup! = CAAnimationGroup();
        startAnimationGroup.duration = kFSConfettiCellLifetime * 70.0 / 100.0;
        startAnimationGroup.timingFunction = timingFunction;
        startAnimationGroup.animations = [initialBirthRateAnimation, initialVelocityRateAnimation, initialEmitterWidth];
        emitterLayer.add(startAnimationGroup, forKey: "startAnimationGroup");
        
        let endBirthRateAnimation : CABasicAnimation! = CABasicAnimation(keyPath: "birthRate");
        endBirthRateAnimation.fromValue = 1.0;
        endBirthRateAnimation.toValue   = 0.0;
        
        let endAnimationGroup : CAAnimationGroup! = CAAnimationGroup();
        endAnimationGroup.beginTime = kFSConfettiCellLifetime * 70.0 / 100.0;
        endAnimationGroup.duration = kFSConfettiCellLifetime * 30.0 / 100.0;
        endAnimationGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear);
        endAnimationGroup.animations = [endBirthRateAnimation];
        emitterLayer.add(startAnimationGroup, forKey: "endAnimationGroup");
        
        perform(#selector(stop), with: self, afterDelay: 2 * kFSConfettiCellLifetime);
    }
    
    func stop() {
        emitterLayer!.removeFromSuperlayer();
    }
}

let containerView = CustomView(frame: CGRect(x: 0, y: 0, width: 360, height: 640))
containerView.backgroundColor = UIColor.white

PlaygroundPage.current.liveView = containerView
containerView.setupConfettiAnimation();
containerView.start();
