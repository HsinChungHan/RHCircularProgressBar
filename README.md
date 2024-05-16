# RHCircularProgressBar

This repository contains the implementation of a circular progress bar for iOS, which can be customized and used in various projects.

## Features
- Customizable start angle
- Configurable rounds, colors, and stroke width
- Delegate methods for progress update notifications
- Smooth animations for progress updates

## Files
1. `RHCircularProgressBar.swift`
2. `RHCircularProgressBarViewModel.swift`
3. `Package.swift`

## RHCircularProgressBar.swift

### Description
`RHCircularProgressBar` is a UIView subclass that displays a circular progress bar. It uses a combination of shape layers and animation to visualize progress.

### Key Components
- **StartAngleType**: Enum to define the start angle of the progress bar.
- **RHCircularProgressBarDelegate**: Protocol to handle progress updates.
- **RHCircularProgressBar**: Main class implementing the progress bar.

### Usage
```swift
let progressBar = RHCircularProgressBar(atStartAngle: .threeClock, forRounds: 2.0, progressLayerColor: .blue, strokeWidth: 8.0)
progressBar.delegate = self
view.addSubview(progressBar)
progressBar.setProgress(to: 0.75, withDuration: 2.0)
```

## Key Components

### RHCircularProgressBarViewModel

`RHCircularProgressBarViewModel` handles the business logic and state for `RHCircularProgressBar`. It manages progress values, colors, and angles.

#### Computed Properties

- `startAngle`
- `endAngle`
- `trackLayerCGColor`
- `progressLayerCGColor`

#### Methods

- `get current progress`
- `get completion rate`
- `update values`

## Package.swift

This file defines the Swift Package Manager configuration for the RHCircularProgressBar project.

### Key Components

- **Name:** RHCircularProgressBar
- **Platforms:** iOS 13 and above
- **Products:** Library `RHCircularProgressBar`
- **Dependencies:**
  - `RHUIComponent` from [https://github.com/HsinChungHan/RHUIComponent.git](https://github.com/HsinChungHan/RHUIComponent.git)
  - `SnapKit` from [https://github.com/SnapKit/SnapKit](https://github.com/SnapKit/SnapKit)
- **Targets:**
  - `RHCircularProgressBar`: The main target depending on RHUIComponent and SnapKit.
  - `RHCircularProgressBarTests`: Test target for the library.

## Installation

Add the following to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/your-repo/RHCircularProgressBar.git", from: "1.0.0")
]
```

## Usage Example
```swift
import RHCircularProgressBar

class ViewController: UIViewController, RHCircularProgressBarDelegate {
    private let progressBar = RHCircularProgressBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        progressBar.delegate = self
        view.addSubview(progressBar)
        progressBar.setProgress(to: 0.5, withDuration: 1.0)
    }

    func progressBar(_ progressBar: RHCircularProgressBar, completionRateWillUpdate rate: Int, currentBarProgress value: Float) {
        print("Progress: \(value), Rate: \(rate)%")
    }

    func progressBar(_ progressBar: RHCircularProgressBar, isDonetoValue: Bool, currentBarProgress value: Float) {
        print("Progress completed: \(value)")
    }
}
```

## Demo App

You can click [here](https://github.com/HsinChungHan/RHCircularProgressBarDemoApp.git) to refer to the Demo App 🙌 🙌 🙌

I demonstrated how to use `RHCircularProgressBar` in a `UICollectionView` to pause and resume animations.

Please refer to the above steps for the basic setup and customize and extend according to your specific needs.

Wishing you a smooth development process with RHStackCard 🥳 🥳 🥳



