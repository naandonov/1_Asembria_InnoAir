//
//  PageViewController.swift
//
//  Created by Stoyan Kostov on 2.06.21.
//

import UIKit

final class CarouselViewController: UIPageViewController {
    var pages: [CarouselPage] = [] {
        didSet {
            pageViewControllers = pages.map { $0.viewController }
            pages.forEach { $0.delegate = self }
        }
    }

    var pageViewControllers: [UIViewController] = []

    private let pageControl = UIPageControl()

    var completionHandler: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self

        pageControl.numberOfPages = pages.count
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.tintColor = .blue
        pageControl.pageIndicatorTintColor = .gray
        pageControl.currentPageIndicatorTintColor = .blue
        view.addSubview(pageControl)
        view.isUserInteractionEnabled = false

        let bottomConstant: CGFloat = view.bounds.height * 0.30

        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottomConstant)
        ])

        view.bringSubviewToFront(pageControl)

        if let firstViewController = pageViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: { [weak self] finished in
                                   if finished {
                                       self?.pages.first?.start()
                                   }
                               })
        }
    }

    private func goToNextPage() -> Bool {
        guard
            let currentViewController = viewControllers?.first,
            let nextViewController = dataSource?.pageViewController(self, viewControllerAfter: currentViewController)
        else {
            return false
        }

        setViewControllers([nextViewController],
                           direction: .forward,
                           animated: true,
                           completion: nil)
        (nextViewController as? CarouselPage)?.start()
        return true
    }

    private func goToFirstPage() {
        guard
            let currentViewController = pageViewControllers.first
        else {
            return
        }
        setViewControllers([currentViewController],
                           direction: .reverse,
                           animated: false,
                           completion: nil)
        (currentViewController as? CarouselPage)?.start()
    }

    private func updateCurrentIndex() {
        if let currentPage = viewControllers?.first as? CarouselPage {
            pageControl.currentPage = pageViewControllers
                .firstIndex(of: currentPage.viewController) ?? 0
        }
    }
}

// MARK: -

extension CarouselViewController: CarouselPageDelegate {
    func didFinish(_ page: CarouselPage) {
        page.delegate = nil
        page.stop()
        if !goToNextPage() {
            completionHandler?()
        }

        updateCurrentIndex()
    }
}

// MARK: - UIPageViewControllerDelegate

extension CarouselViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard completed else { return }

        previousViewControllers
            .compactMap { $0 as? CarouselPage }
            .forEach { $0.stop() }

        updateCurrentIndex()
    }
}

// MARK: - UIPageViewControllerDataSource

extension CarouselViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pageViewControllers.firstIndex(of: viewController) else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else {
            return nil
        }

        guard pageViewControllers.count > previousIndex else {
            return nil
        }

        return pageViewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pageViewControllers.firstIndex(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = pageViewControllers.count

        guard orderedViewControllersCount != nextIndex else {
            return nil
        }

        guard orderedViewControllersCount > nextIndex else {
            return nil
        }

        return pageViewControllers[nextIndex]
    }
}

extension CarouselViewController {
    static func instantiate(pages: [CarouselPage]) -> CarouselViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "CarouselViewController") as? CarouselViewController
        viewController?.pages = pages
        return viewController
    }
}
