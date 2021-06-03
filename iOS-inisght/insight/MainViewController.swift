//
//  MainViewController.swift
//  insight
//
//  Created by Nikolay Andonov on 2.06.21.
//

import UIKit

private enum Constants {
    static let initialOnboardingShown = "initialOnboardingShown"
}

final class MainViewController: UIViewController {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var containmentView: UIView!
    @IBOutlet private weak var instructionsTitleLabel: UILabel!
    @IBOutlet private weak var instructionsSubtitleLabel: UILabel!

    private weak var containmentNavigationController: UINavigationController?

    private lazy var voiceRecorder: VoiceRecorderInputProtocol = VoiceRecorder(output: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureContainment()
        startInitialOnboarding()
        configureGestures()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        voiceRecorder.requestPermission()
    }

    deinit {
        view.gestureRecognizers?.forEach { [weak view] in
            view?.removeGestureRecognizer($0)
        }
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
        self.containmentNavigationController = containmentNavigationController
    }
}

// MARK: - Child View Controllers

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

// MARK: - Onboarding

private extension MainViewController {
    func startOnboarding() {
        let configurations: [PageViewController.Configuration] = [
            // TODO: Instruction for usage -> Introduction
            .init(videoFileName: "one_tap_one_finger_destination",
                  text: "Докоснете екрана веднъж с един пръст, за да започнете гласовото въвеждане на вашата дестинация"),
            .init(videoFileName: "one_tap_one_finger",
                  text: "Докоснете екрана веднъж с един пръст, за дa потвърдите вашия избор"),
            .init(videoFileName: "one_finger_double_tap",
                  text: "Докоснете екрана два пъти с един пръст за анулиране на зададения маршрут"),
            .init(videoFileName: "double_tap_one_finger",
                  text: "Докоснете екрана два пъти с един пръст за отказ"),
            .init(videoFileName: "swipe",
                  text: "Плъзнете вашия пръст от дясно наляво за да повторите гласовото въвеждане"),
            .init(videoFileName: "double_finger_double_tap", text: "За да чуете инструкциите за употреба, докоснете екрана два пъти с два пръста.")
        ]

        showOnboarding(configurations: configurations)
    }

    func startInitialOnboarding() {
        guard UserDefaults.standard.bool(forKey: Constants.initialOnboardingShown) == false else {
            return
        }
        UserDefaults.standard.set(true, forKey: Constants.initialOnboardingShown)
        showOnboarding(configurations: [.init(videoFileName: "record_info", text: "Докоснете екрана веднъж с един пръст за да започнете гласовото въвеждане на вашата дестинация и докоснете екрана още веднъж, за да приключите.")])
    }

    func showOnboarding(configurations: [PageViewController.Configuration]) {
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
}

// MARK: - VoiceRecorderOutput

extension MainViewController: VoiceRecorderOutputProtocol {
    func didRequestPermission(allowed: Bool) {
        print(#function + " \(allowed)")
    }

    func didStartRecording() {
        print(#function)
    }

    func didFinishRecording(success: Bool) {
        print(#function)
        if success,
           let voiceData = voiceRecorder.voiceData {
            SpeechService.shared.text(voiceData: voiceData) { [weak containmentNavigationController] result in
                guard let navigation = containmentNavigationController,
                      let destination = navigation.topViewController as? DestinationViewController else {
                    return
                }

                guard let resultText = result?.alternatives?.first?.transcript else {
                    destination.configuration = .destination("Оппс, грешка!")
                    return
                }

                destination.configuration = .destination(resultText)

                SpeechService.shared.speak(text: """
                        Вие избрахте дестинация - \(resultText).
                        За да потвърдите избора си, моля докоснете веднъж екрана.
                        Докоснете екрана два пъти с един пръст за отказ.
                        Плъзнете вашия пръст от дясно наляво за да повторите гласовото въвеждане.
                        """,
                                           completion: { data in
                                            // TODO: Notification
                                           })
            }
        }
    }
}

// MARK: - Utils (private)

private extension MainViewController {
    enum GestureName: String {
        case oneFingerOneTap
        case twoFingersDoubleTap
    }

    func configureGestures() {
        let oneFingerOneTap = UITapGestureRecognizer(target: self,
                                                     action: #selector(onGestureRecogniserAction(_:)))
        oneFingerOneTap.numberOfTapsRequired = 1
        oneFingerOneTap.numberOfTouchesRequired = 1
        oneFingerOneTap.name = GestureName.oneFingerOneTap.rawValue

        let twoFingersDoubleTap = UITapGestureRecognizer(target: self,
                                                         action: #selector(onGestureRecogniserAction(_:)))
        twoFingersDoubleTap.numberOfTapsRequired = 2
        twoFingersDoubleTap.numberOfTouchesRequired = 2
        twoFingersDoubleTap.name = GestureName.twoFingersDoubleTap.rawValue

        let gestures = [oneFingerOneTap, twoFingersDoubleTap]

        gestures.forEach {
            view.addGestureRecognizer($0)
        }
    }

    @objc func onGestureRecogniserAction(_ gesture: UIGestureRecognizer) {
        guard
            let name = gesture.name,
            let tag = GestureName(rawValue: name)
        else {
            assertionFailure("Missing gesture recognizer tag \(gesture)")
            return
        }

        switch tag {
        case .oneFingerOneTap:
            guard let navigation = containmentNavigationController,
                  let destination = navigation.topViewController as? DestinationViewController else {
                return
            }
            if voiceRecorder.isRecording {
                destination.configuration = .ready
                voiceRecorder.stopRecording()
            } else {
                destination.configuration = .listening
                voiceRecorder.startRecording()
            }
        case .twoFingersDoubleTap:
            startOnboarding()
        }
    }
}
