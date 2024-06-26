//
//  RHCircularProgressBar.swift
//  RHCircularProgressBarDemoApp
//
//  Created by Chung Han Hsin on 2024/4/13.
//

import Foundation
import RHUIComponent
import UIKit

public enum StartAngleType {
    case twelveClock
    case threeClock
    case sixClock
    case nineClock
    var angle: CGFloat {
        switch self {
        case .twelveClock:
            return -CGFloat.pi / 2
        case .threeClock:
            return 0
        case .sixClock:
            return CGFloat.pi / 2
        case .nineClock:
            return CGFloat.pi
        }
    }
}

public protocol RHCircularProgressBarDelegate: AnyObject {
    func progressBar(_ progressBar: RHCircularProgressBar, completionRateWillUpdate rate: Int, currentBarProgress value: Float)
    func progressBar(_ progressBar: RHCircularProgressBar, isDonetoValue: Bool, currentBarProgress value: Float)
}

public class RHCircularProgressBar: UIView {
    public weak var delegate: RHCircularProgressBarDelegate?
    
    private lazy var progressLayer = makeProgressLayer()
    private lazy var trackLayer = makeTrackLayer()
    private lazy var gradientLayer = makeGradientLayer()
    private lazy var circularPath = makeCircularPath()
    private var displayLink: CADisplayLink?
    
    private let viewModel: RHCircularProgressBarViewModel
    public init(atStartAngle startAngleType: StartAngleType = .twelveClock, forRounds rounds: CGFloat = 1.0, progressLayerColor: UIColor = Color.Red.v100, strokeWidth: CGFloat = 10.0) {
        self.viewModel = .init(startAngleType: startAngleType, rounds: rounds, progressLayerColor: progressLayerColor, strokeWidth: strokeWidth)
        super.init(frame: .zero)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.addSublayer(trackLayer)
        layer.addSublayer(progressLayer)
        gradientLayer.mask = progressLayer
        layer.addSublayer(gradientLayer)
    }
}

// MARK: - Internal Methods
public extension RHCircularProgressBar {
    func configureProgressBar(with color: UIColor) {
        viewModel.setProgressLayerColor(withColor: color)
        progressLayer.strokeColor = viewModel.progressLayerCGColor
        gradientLayer.colors = makeShadeVariants(of: viewModel.progressLayerColor)
    }
    
    func setProgressWithAnimation(duration: TimeInterval, value: Float) {
        viewModel.setToValue(with: value)
        progressLayer.strokeEnd = CGFloat(viewModel.toValue)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.delegate = self
        animation.duration = duration
        animation.fromValue = 0
        animation.toValue = viewModel.toValue
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        progressLayer.add(animation, forKey: "animateprogress")
    }
    
    func setProgressWithAnimationFromCurrentValue(duration: TimeInterval=0.1, from fromValue: Float? = nil, to toValue: Float) {
        viewModel.setToValue(with: toValue)
        progressLayer.strokeEnd = CGFloat(toValue)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.delegate = self
        animation.duration = duration
        animation.fromValue = fromValue ?? progressLayer.strokeEnd
        animation.toValue = toValue
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        progressLayer.add(animation, forKey: "animateprogress")
    }
    
    func reset() {
        // stop displayLink and animation
        stopDisplayLink()
        progressLayer.removeAllAnimations()
        
        // reset progressLayer
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressLayer.strokeEnd = 0.0
        CATransaction.commit()
        
        // remove progressLayer and gradientLayer
        progressLayer.removeFromSuperlayer()
        gradientLayer.removeFromSuperlayer()
        viewModel.setToValue(with: 0.0)
    }
}

// MARK: - Layout
private extension RHCircularProgressBar {
    func makeCircularPath() -> UIBezierPath {
        // 計算繪製路徑時需要考慮到線寬的內縮距離
        let insetBounds = bounds.insetBy(dx: viewModel.strokeWidth / 2, dy: viewModel.strokeWidth / 2)
        let center = CGPoint(x: insetBounds.midX, y: insetBounds.midY)
        let radius = min(insetBounds.width, insetBounds.height) / 2
        
        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: viewModel.startAngle, endAngle: viewModel.endAngle, clockwise: true)
        return circlePath
    }
}

// MARK: - Factory Methods
private extension RHCircularProgressBar {
    func makeTrackLayer() -> CAShapeLayer {
        let trackLayer = CAShapeLayer()
        trackLayer.path = circularPath.cgPath
        trackLayer.lineCap = .round
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = Color.Neutral.v800.withAlphaComponent(0.7).cgColor
        trackLayer.lineWidth = viewModel.strokeWidth
        trackLayer.strokeEnd = 1.0
        return trackLayer
    }
    
    func makeProgressLayer() -> CAShapeLayer {
        let progressLayer = CAShapeLayer()
        progressLayer.lineCap = .round
        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = viewModel.progressLayerCGColor
        progressLayer.lineWidth = viewModel.strokeWidth
        progressLayer.strokeStart = 0.0
        progressLayer.strokeEnd = CGFloat(viewModel.toValue)
        return progressLayer
    }
    
    func makeProgressLabel() -> UILabel {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 22)
        label.textColor = .white
        return label
    }
    
    func makeGradientLayer() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = makeShadeVariants(of: viewModel.progressLayerColor)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1.0)
        return gradientLayer
    }
    
    func makeShadeVariants(of color: UIColor) -> [CGColor] {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        if color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            let lighterColor = UIColor(hue: hue, saturation: saturation, brightness: min(brightness * 2.0, 1.0), alpha: alpha)
            let originalColor = color
            let darkerColor = UIColor(hue: hue, saturation: saturation, brightness: brightness * 0.2, alpha: alpha)
            return [darkerColor.cgColor, originalColor.cgColor, lighterColor.cgColor]
        }
        return []
    }
}

// MARK: - Helpers
private extension RHCircularProgressBar {
    func startDisplayLink() {
        // invalidate previous displayLink
        displayLink?.invalidate()
        displayLink = CADisplayLink(target: self, selector: #selector(updateProgressLabel))
        displayLink?.add(to: .main, forMode: .default)
    }

    @objc func updateProgressLabel() {
        let currentProgressValue = viewModel.getCurrentProgressLayerValue(withProgressLayer: progressLayer)
        let completionRate = viewModel.getCompletionRate(withProgressLayer: progressLayer)
        delegate?.progressBar(self, completionRateWillUpdate: completionRate, currentBarProgress: currentProgressValue)
    }
    
    func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
        let currentProgressValue = viewModel.getCurrentProgressLayerValue(withProgressLayer: progressLayer)
        delegate?.progressBar(self, isDonetoValue: currentProgressValue == viewModel.toValue, currentBarProgress: currentProgressValue)
    }
}

// MARK: - CAAnimationDelegate
extension RHCircularProgressBar: CAAnimationDelegate {
    public func animationDidStart(_ anim: CAAnimation) {
        startDisplayLink()
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        stopDisplayLink()
    }
}


