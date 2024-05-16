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
