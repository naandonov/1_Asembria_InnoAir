//
//  SuccessViewController.swift
//  insight
//
//  Created by Nikolay Andonov on 4.06.21.
//

import UIKit

class SuccessViewController: UIViewController {

    @IBOutlet private weak var textLabel: UILabel!
    
    var content: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.text = content
        textLabel.textColor = .textColor
        textLabel.font = .primaryTitleFont
        
        SpeechService.shared.speak(text: content ?? "",
                                   completion: { data in
                                    guard let data = data else {
                                        return
                                    }
                                    SpeechService.shared.play(data)
                                   })
    }
}
