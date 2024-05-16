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
