//
//  PageViewController.swift
//
//  Created by Stoyan Kostov on 2.06.21.
//

import AVKit
import UIKit

protocol CarouselPage: AnyObject {
    func start()
    func stop()
    var viewController: UIViewController { get }
    var delegate: CarouselPageDelegate? { get set }
}

protocol CarouselPageDelegate: AnyObject {
    func didFinish(_ page: CarouselPage)
}

final class PageViewController: UIViewController {
    @IBOutlet private var playerView: UIView!
    @IBOutlet private var label: UILabel!

    struct Configuration {
        let videoFileName: String
        let text: String

        var videoURL: URL {
            guard let path = Bundle.main.path(forResource: videoFileName, ofType: "mp4") else {
                fatalError("Missing path to resource file named: \(videoFileName)")
            }
            return URL(fileURLWithPath: path)
        }
    }

    private var configuration: Configuration?

    private var player: AVPlayer?

    weak var delegate: CarouselPageDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        playerView.backgroundColor = .clear
        label.text = configuration?.text
    }

    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                  object: nil)
    }

    func configure(configuration: Configuration) {
        self.configuration = configuration
    }
}

extension PageViewController: CarouselPage {
    var viewController: UIViewController {
        return self
    }

    func start() {
        guard let url = configuration?.videoURL else {
            fatalError("Video URL address is missing")
        }
        view.setNeedsLayout()
        view.layoutIfNeeded()
        let item = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: item)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: item)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = playerView.bounds
        playerLayer.videoGravity = .resize
        playerView.layer.addSublayer(playerLayer)
        player.play()
    }

    func stop() {
        player?.pause()
        player = nil
    }

    @objc private func playerDidFinishPlaying(notification: Notification) {
        delegate?.didFinish(self)
    }
}

final class PagesFactory {
    class func makeCarouselPages(from configurations: [PageViewController.Configuration]) -> [CarouselPage] {
        configurations.map {
            PageViewController.instantiate(configuration: $0)
        }
    }
}

private extension PageViewController {
    static func instantiate(configuration: Configuration) -> CarouselPage {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let pageController = storyboard.instantiateViewController(identifier: "PageViewController") as? PageViewController else {
            fatalError("Couldn't find PageViewController in Main storyboard")
        }
        pageController.configure(configuration: configuration)
        return pageController
    }
}
