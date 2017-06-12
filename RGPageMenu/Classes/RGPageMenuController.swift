//
//  PageMenuController.swift
//  paging
//
//  Created by realgreys on 2016. 5. 10..
//  Copyright © 2016 realgreys. All rights reserved.
//

import UIKit

@objc
public protocol RGPageMenuControllerDelegate: class {
    @objc optional func willMoveToPageMenuController(_ viewController: UIViewController, nextViewController: UIViewController)
    @objc optional func didMoveToPageMenuController(_ viewController: UIViewController)
}


open class RGPageMenuController: UIViewController, UIScrollViewDelegate {
    
    weak open var delegate: RGPageMenuControllerDelegate?
    
    fileprivate var menuView: MenuView!
    fileprivate var options: RGPageMenuOptions!
    fileprivate var menuTitles: [String] {
        return viewControllers.map {
            return $0.title ?? "Menu"
        }
    }
    
    fileprivate var pageViewController: UIPageViewController!
    
    fileprivate(set) var currentPage = 0
    fileprivate var viewControllers: [UIViewController]!
    
    
    
    // MARK: - Lifecycle
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public init(viewControllers: [UIViewController], options: RGPageMenuOptions) {
        super.init(nibName: nil, bundle: nil)
        
        configure(viewControllers, options: options)
    }
    
    public convenience init(viewControllers: [UIViewController]) {
        self.init(viewControllers: viewControllers, options: RGPageMenuOptions())
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        menuView.moveToMenu(currentPage, animated: false)
    }
    
    
    // MARK: - Layout
    
    fileprivate func setupMenuView() {
        menuView = MenuView(menuTitles: menuTitles, options: options)
        menuView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(menuView)
        
        addTapGestureHandlers()
    }
    
    fileprivate func layoutMenuView() {
        // cleanup
        //        NSLayoutConstraint.deactivateConstraints(menuView.constraints)
        
        let viewsDictionary = ["menuView": menuView]
        let metrics = ["height": options.menuHeight]
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[menuView]|",
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: viewsDictionary)
        let verticalConstraints: [NSLayoutConstraint]
        switch options.menuPosition {
        case .top:
            verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[menuView(height)]",
                                                                 options: [],
                                                                 metrics: metrics,
                                                                 views: viewsDictionary)
        case .bottom:
            verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[menuView(height)]|",
                                                                 options: [],
                                                                 metrics: metrics,
                                                                 views: viewsDictionary)
        }
        
        NSLayoutConstraint.activate(horizontalConstraints + verticalConstraints)
        
        menuView.setNeedsLayout()
        menuView.layoutIfNeeded()
    }
    
    fileprivate func setupPageView() {
        pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                  navigationOrientation: .horizontal,
                                                  options: nil)
        pageViewController.delegate = self
        pageViewController.dataSource = self
        
        let childViewControllers = [ viewControllers[currentPage] ]
        pageViewController.setViewControllers(childViewControllers,
                                              direction: .forward,
                                              animated: false,
                                              completion: nil)
        
        addChildViewController(pageViewController)
        pageViewController.view.frame = .zero
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageViewController.view)
        
        pageViewController.didMove(toParentViewController: self)
        
        // testing
        for view in self.pageViewController.view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.delegate = self
            }
        }
    }
    
    fileprivate func layoutPageView() {
        let viewsDictionary = ["pageView": pageViewController.view, "menuView": menuView]
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[pageView]|",
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: viewsDictionary)
        let verticalConstraints: [NSLayoutConstraint]
        switch options.menuPosition {
        case .top:
            verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[menuView][pageView]|",
                                                                 options: [],
                                                                 metrics: nil,
                                                                 views: viewsDictionary)
        case .bottom:
            verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[pageView][menuView]",
                                                                 options: [],
                                                                 metrics: nil,
                                                                 views: viewsDictionary)
        }
        
        NSLayoutConstraint.activate(horizontalConstraints + verticalConstraints)
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    fileprivate func validateDefaultPage() {
        guard options.defaultPage >= 0 && options.defaultPage < options.menuItemCount else {
            NSException(name: NSExceptionName(rawValue: "PageMenuException"), reason: "default page is not valid!", userInfo: nil).raise()
            return
        }
    }
    
    fileprivate func indexOfViewController(_ viewController: UIViewController) -> Int {
        return viewControllers.index(of: viewController) ?? NSNotFound
    }
    
    // MARK: - Gesture handler
    
    fileprivate func addTapGestureHandlers() {
        menuView.menuItemViews.forEach {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
            gestureRecognizer.numberOfTapsRequired = 1
            $0.addGestureRecognizer(gestureRecognizer)
        }
    }
    
    func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        guard let menuItemView = recognizer.view as? MenuItemView else { return }
        guard let page = menuView.menuItemViews.index(of: menuItemView), page != menuView.currentPage else { return }
        
        moveToPage(page)
    }
    
    
    // MARK: - public
    
    open func configure(_ viewControllers: [UIViewController], options: RGPageMenuOptions) {
        let menuItemCount = viewControllers.count
        guard menuItemCount > 0 else {
            NSException(name: NSExceptionName(rawValue: "PageMenuException"), reason: "child view controller is empty!", userInfo: nil).raise()
            return
        }
        
        self.viewControllers = viewControllers
        self.options = options
        self.options.menuItemCount = menuItemCount
        
        var counter = 0
        for page in self.viewControllers {
            page.view.tag = counter
            counter = counter+1
        }
        
        validateDefaultPage()
        currentPage = options.defaultPage
        
        setupMenuView()
        layoutMenuView()
        setupPageView()
        layoutPageView()
    }
    
    open func moveToPage(_ page: Int, animated: Bool = true) {
        guard page < options.menuItemCount && page != currentPage else { return }
        
        let direction: UIPageViewControllerNavigationDirection = page < currentPage ? .reverse : .forward
        
        // page 이동
        currentPage = page % viewControllers.count // for infinite loop
        
        // menu 이동
        menuView.moveToMenu(currentPage, animated: animated)
        
        let childViewControllers = [ viewControllers[currentPage] ]
        pageViewController.setViewControllers(childViewControllers,
                                              direction: direction,
                                              animated: animated,
                                              completion: nil)
    }
    
}


extension RGPageMenuController: UIPageViewControllerDelegate {
    
    // MARK: - UIPageViewControllerDelegate
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else { return }
        
        if let index = pageViewController.viewControllers!.last?.view.tag {
            currentPage = index
            menuView.moveToMenu(currentPage, animated: true)
            
            if let nextViewController = pageViewController.viewControllers!.last {
                delegate?.didMoveToPageMenuController?(nextViewController)
            }
        }
    }
    
}


extension RGPageMenuController: UIPageViewControllerDataSource {
    
    // MARK: - UIPageViewControllerDataSource
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = indexOfViewController(viewController)
        guard index != 0 && index != NSNotFound else {
            return nil
        }
        
        return viewControllers[index - 1]
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = indexOfViewController(viewController)
        guard index < viewControllers.count - 1 && index != NSNotFound else {
            return nil
        }
        
        return viewControllers[index + 1]
    }
}




