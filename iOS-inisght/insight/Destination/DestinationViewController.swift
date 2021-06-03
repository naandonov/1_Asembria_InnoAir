//
//  DestinationViewController.swift
//  insight
//
//  Created by Nikolay Andonov on 2.06.21.
//

import Lottie

class DestinationViewController: UIViewController {

    @IBOutlet private weak var lottieView: AnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLottieView()
    }
    
    private func configureLottieView() {
        lottieView!.loopMode = .loop
        lottieView!.animationSpeed = 0.75
        lottieView.play()
        
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
