//
//  DestinationViewController.swift
//  insight
//
//  Created by Nikolay Andonov on 2.06.21.
//

import Lottie

final class DestinationViewController: UIViewController {
    enum Configuration {
        case listening
        case ready
        case inProgress
        case destination(String)
    }

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var lottieView: AnimationView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLottieView()
        configureLabels()
        updateViewConfiguration()
    }

    var configuration: Configuration = .ready {
        didSet {
            updateViewConfiguration()
        }
    }

    private func configureLabels() {
        titleLabel.font = .primaryTitleFont
        subtitleLabel.font = .secondaryTitleFont
        titleLabel.textColor = .textColor
        subtitleLabel.textColor = .textColor
    }

    private func updateViewConfiguration() {
        subtitleLabel.isHidden = false

        switch configuration {
        case .listening:
            let text = "Слушане"
            lottieView.play()
            titleLabel.text = text
            subtitleLabel.isHidden = true
        case .ready:
            lottieView.stop()
            titleLabel.text = "В очакване на дестинация"
            subtitleLabel.isHidden = true
        case .destination(let destination):
            lottieView.stop()
            titleLabel.text = destination
            subtitleLabel.text = "Очакване на потвръждение..."
        case .inProgress:
            lottieView.stop()
            titleLabel.text = "Зареждане моля изчакайте..."
        }
    }
    
    private func configureLottieView() {
        lottieView!.loopMode = .loop
        lottieView!.animationSpeed = 0.75
        
        guard let color = UIColor.primaryBlue else {
            return
        }
        let colorValue = Color(r: Double(color.redValue), g: Double(color.greenValue), b: Double(color.blueValue), a: Double(color.alphaValue))
        let colorValueProvider = ColorValueProvider(colorValue)
        var keyPath = AnimationKeypath(keypath: "Base Layer 3.Ellipse 1.Stroke 1.Color")
        lottieView.setValueProvider(colorValueProvider, keypath: keyPath)
        
        keyPath = AnimationKeypath(keypath: "Base Layer 3.Ellipse 1.Fill 1.Color")
        lottieView.setValueProvider(colorValueProvider, keypath: keyPath)
        
        keyPath = AnimationKeypath(keypath: "Base Layer 4.Ellipse 1.Stroke 1.Color")
        lottieView.setValueProvider(colorValueProvider, keypath: keyPath)
        
        keyPath = AnimationKeypath(keypath: "Base Layer 4.Ellipse 1.Fill 1.Color")
        lottieView.setValueProvider(colorValueProvider, keypath: keyPath)
        
        keyPath = AnimationKeypath(keypath: "base.Ellipse 1.Stroke 1.Color")
        lottieView.setValueProvider(colorValueProvider, keypath: keyPath)
        
        keyPath = AnimationKeypath(keypath: "base.Ellipse 1.Fill 1.Color")
        lottieView.setValueProvider(colorValueProvider, keypath: keyPath)
    }
}
