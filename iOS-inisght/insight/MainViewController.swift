//
//  MainViewController.swift
//  insight
//
//  Created by Nikolay Andonov on 2.06.21.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var containmentView: UIView!
    @IBOutlet private weak var instructionsTitleLabel: UILabel!
    @IBOutlet private weak var instructionsSubtitleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureContainment()
        startOnboarding()

        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(onDoubleTapGesture))
        gesture.numberOfTapsRequired = 2
        gesture.numberOfTouchesRequired = 2
        view.addGestureRecognizer(gesture)
    }

    deinit {
        view.gestureRecognizers?.forEach { [weak view] in
            view?.removeGestureRecognizer($0)
        }
    }

    private func startOnboarding() {
        let configurations: [PageViewController.Configuration] = [
            // TODO: Instruction for usage -> Introduction
            .init(videoFileName: "one_tap_one_finger",
                  text: "Докоснете екрана веднъж с един пръст, за дa потвърдите вашия избор"),
            .init(videoFileName: "one_tap_one_finger_destination",
                  text: "Докоснете екрана веднъж с един пръст, за да започнете гласовото въвеждане на вашата дестинация"),
            .init(videoFileName: "one_finger_double_tap",
                  text: "Докоснете екрана два пъти с един пръст за анулиране на зададения маршрут"),
            .init(videoFileName: "double_tap_one_finger",
                  text: "Докоснете екрана два пъти с един пръст за отказ"),
            .init(videoFileName: "swipe",
                  text: "Плъзнете вашия пръст от дясно наляво за да повторите гласовото въвеждане")
            // TODO: Double tap with two fingers
        ]

        let pages = PagesFactory.makeCarouselPages(from: configurations)
        if let controller = CarouselViewController.instantiate(pages: pages) {
            controller.completionHandler = { [weak self] in
                self?.navigationController?.dismiss(animated: true, completion: {})
            }
            navigationController?.present(controller,
                                          animated: true,
                                          completion: nil)
        }
    }

    @objc private func onDoubleTapGesture() {
        startOnboarding()
    }

    private func configureUI() {
        view.backgroundColor = .secondaryGray
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        navigationController?.navigationBar.barTintColor = .secondaryGray
        navigationItem.title = "insight"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray]

        containerView.layer.cornerRadius = 30
        containerView.layer.masksToBounds = true
        containerView.backgroundColor = UIColor.white
        containerView.layer.shadowColor = UIColor.lightGray.cgColor
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowOffset = CGSize(width: 0.0, height: 10.0)
        containerView.layer.shadowRadius = 10.0
        containerView.layer.masksToBounds = false
        containerView.backgroundColor = .ternaryBlue

        containmentView.layer.cornerRadius = 30
        containmentView.clipsToBounds = true

        instructionsTitleLabel.font = .primaryTitleFont
        instructionsTitleLabel.textColor = .textColor
        instructionsTitleLabel.text = "Инструкции за употреба"

        instructionsSubtitleLabel.font = .secondaryTitleFont
        instructionsSubtitleLabel.textColor = .textColor
        instructionsSubtitleLabel.text = "Докоснете екрана два пъти с два пръста"
    }

    private func configureContainment() {
        let containmentNavigationController: UINavigationController = .containmentNavigationController
        containmentNavigationController.setNavigationBarHidden(true, animated: false)
        add(containmentNavigationController)
    }
}

private extension MainViewController {
    func add(_ child: UIViewController) {
        addChild(child)

        containmentView.addSubview(child.view)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            child.view.leadingAnchor.constraint(equalTo: containmentView.leadingAnchor, constant: 0.0),
            child.view.trailingAnchor.constraint(equalTo: containmentView.trailingAnchor, constant: 0.0),
            child.view.topAnchor.constraint(equalTo: containmentView.topAnchor, constant: 0.0),
            child.view.bottomAnchor.constraint(equalTo: containmentView.bottomAnchor, constant: 0.0)
        ])
        child.didMove(toParent: self)
    }

    func remove() {
        willMove(toParent: nil)
        containmentView.subviews.forEach { $0.removeFromSuperview() }
        removeFromParent()
    }
}
