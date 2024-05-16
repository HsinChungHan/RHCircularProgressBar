// The Swift Programming Language
// https://docs.swift.org/swift-book
public protocol RHCircularProgressBarDelegate: AnyObject {
    func progressBar(_ progressBar: RHCircularProgressBar, completionRateWillUpdate rate: Int, currentBarProgress value: Float)
    func progressBar(_ progressBar: RHCircularProgressBar, isDonetoValue: Bool, currentBarProgress value: Float)
}
