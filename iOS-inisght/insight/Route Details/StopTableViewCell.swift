//
//  StopTableViewCell.swift
//  insight
//
//  Created by Nikolay Andonov on 2.06.21.
//

import UIKit

class StopTableViewCell: UITableViewCell {
    enum Progress {
        case passed
        case current
        case upcoming
    }
    enum Configuration {
        enum Location {
            case top
            case middle
            case bottom
        }
        case disabled(location: Location)
        case inactive(location: Location)
        case inactiveStart(location: Location)
        case inactiveEnd(location: Location)
        case active(location: Location)
        case activeStart(location: Location)
        case activeEnd(location: Location)
    }
    
    @IBOutlet private weak var topLine: UIView!
    @IBOutlet private weak var bottomLine: UIView!
    @IBOutlet private weak var indicatorImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(_ configuration: Configuration, name: String, progress: Progress) {
        nameLabel.text = name
        let locationHandler: ((Configuration.Location) -> Void) = { [weak self] location in
            switch location {
            case .top:
                self?.topLine.isHidden = true
                self?.bottomLine.isHidden = false
            case .middle:
                self?.topLine.isHidden = false
                self?.bottomLine.isHidden = false
            case .bottom:
                self?.topLine.isHidden = false
                self?.bottomLine.isHidden = true
            }
        }
        switch progress {
        case .passed:
            nameLabel.textColor = .ternaryGray
            nameLabel.font = .secondaryTitleFont
        case .current:
            nameLabel.textColor = .primaryBlue
            nameLabel.font = .secondaryHighlightedTitleFont
        case .upcoming:
            nameLabel.textColor = .secondaryBlue
            nameLabel.font = .secondaryTitleFont
        }
        
        switch configuration {
        case .disabled(location: let location):
            locationHandler(location)
            topLine.backgroundColor = .ternaryGray
            bottomLine.backgroundColor = .ternaryGray
            indicatorImageView.image = UIImage(named: "excludedStep")
        case .inactive(location: let location):
            locationHandler(location)
            topLine.backgroundColor = .secondaryBlue
            bottomLine.backgroundColor = .secondaryBlue
            indicatorImageView.image = UIImage(named: "inactiveStep")
        case .inactiveStart(location: let location):
            locationHandler(location)
            topLine.backgroundColor = .secondaryBlue
            bottomLine.backgroundColor = .secondaryBlue
            indicatorImageView.image = UIImage(named: "inactiveStepStart")
        case .inactiveEnd(location: let location):
            locationHandler(location)
            topLine.backgroundColor = .secondaryBlue
            bottomLine.backgroundColor = .secondaryBlue
            indicatorImageView.image = UIImage(named: "inactiveStepEnd")
        case .active(location: let location):
            locationHandler(location)
            topLine.backgroundColor = .primaryBlue
            bottomLine.backgroundColor = .primaryBlue
            indicatorImageView.image = UIImage(named: "activeStep")
        case .activeStart(location: let location):
            locationHandler(location)
            topLine.backgroundColor = .primaryBlue
            bottomLine.backgroundColor = .primaryBlue
            indicatorImageView.image = UIImage(named: "activeStepStart")
        case .activeEnd(location: let location):
            locationHandler(location)
            topLine.backgroundColor = .primaryBlue
            bottomLine.backgroundColor = .primaryBlue
            indicatorImageView.image = UIImage(named: "activeStepEnd")
        }
    }

}
