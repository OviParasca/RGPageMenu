//
//  MenuView.swift
//  paging
//
//  Created by realgreys on 2016. 5. 10..
//  Copyright © 2016 realgreys. All rights reserved.
//

import UIKit

class MenuView: UIScrollView {
    
    var menuItemViews = [MenuItemView]()
    fileprivate var options: RGPageMenuOptions!
    
    var currentPage: Int = 0
    
    fileprivate let contentView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy fileprivate var underlineView: UIView = {
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    fileprivate var contentOffsetX: CGFloat {
        //        return menuItemViews[currentPage].frame.midX - UIApplication.sharedApplication().keyWindow!.bounds.width / 2 // center of screen width
        
        let offset = (contentSize.width - frame.width)
        if offset < 0 {
            switch options.menuAlign {
            case .left: return 0
            case .center: return offset / 2
            case .right: return offset
            case .fit: return 0
            }
        }
        
        let menuItemCount = menuItemViews.count
        let ratio = CGFloat(currentPage) / CGFloat(menuItemCount - 1)
        return offset * ratio
    }
    
    // MARK: - Lifecycle
    
    init(menuTitles: [String], options: RGPageMenuOptions) {
        super.init(frame: .zero)
        
        self.options = options
        
        setupScrollView()
        setupContentView()
        layoutContentView()
        setupMenuItems(menuTitles)
        layoutMenuItemView()
        setupUnderlineViewIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    fileprivate func setupScrollView() {
        backgroundColor = options.backgroundColor
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        bounces = options.menuBounces
        isScrollEnabled = options.menuScrolls
        scrollsToTop = false
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    fileprivate func setupContentView() {
        addSubview(contentView)
    }
    
    fileprivate func layoutContentView() {
        let viewsDictionary = ["contentView": contentView, "scrollView": self]
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|",
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: viewsDictionary)
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[contentView(==scrollView)]|",
                                                                 options: [],
                                                                 metrics: nil,
                                                                 views: viewsDictionary)
        
        NSLayoutConstraint.activate(horizontalConstraints + verticalConstraints)
    }
    
    fileprivate func setupMenuItems(_ titles: [String]) {
        titles.forEach {
            let menuItemView = MenuItemView(title: $0, options: options)
            contentView.addSubview(menuItemView)
            
            menuItemViews.append(menuItemView)
        }
    }
    
    fileprivate func layoutMenuItemView() {
        NSLayoutConstraint.deactivate(contentView.constraints)
        
        for (index, menuItemView) in menuItemViews.enumerated() {
            let visualFormat: String
            var viewsDictionary = ["menuItemView": menuItemView]
            if index == 0 { // first menu
                visualFormat = "H:|[menuItemView]"
            } else  {
                viewsDictionary["previousMenuItemView"] = menuItemViews[index - 1]
                if index == menuItemViews.count - 1 { // last menu
                    visualFormat = "H:[previousMenuItemView][menuItemView]|"
                } else {
                    visualFormat = "H:[previousMenuItemView][menuItemView]"
                }
            }
            let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: visualFormat,
                                                                       options: [],
                                                                       metrics: nil,
                                                                       views: viewsDictionary)
            let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[menuItemView]|",
                                                                     options: [],
                                                                     metrics: nil,
                                                                     views: viewsDictionary)
            
            NSLayoutConstraint.activate(horizontalConstraints + verticalConstraints)
        }
        
        
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    //    private func relayoutMenuItemView() {
    //        layoutMenuItemView()
    //    }
    
    fileprivate func setupUnderlineViewIfNeeded() {
        guard case let .underline(height, color, horizontalPadding, verticalPadding) = options.menuStyle else {
            return
        }
        
        let width = menuItemViews[currentPage].bounds.width - horizontalPadding * 2
        underlineView.frame = CGRect(x: horizontalPadding, y: options.menuHeight - (height + verticalPadding), width: width, height: height)
        underlineView.backgroundColor = color
        contentView.addSubview(underlineView)
    }
    
    fileprivate func animateUnderlineViewIfNeeded() {
        guard case let .underline(_, _, horizontalPadding, _) = options.menuStyle else {
            return
        }
        
        let targetFrame = menuItemViews[currentPage].frame
        underlineView.frame.origin.x = targetFrame.minX + horizontalPadding
        underlineView.frame.size.width = targetFrame.width - horizontalPadding * 2
    }
    
    fileprivate func selectMenuItem() {
        for (index, menuItemView) in menuItemViews.enumerated() {
            menuItemView.selected = (index == currentPage)
        }
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    fileprivate func positionMenuItemViews() {
        contentOffset.x = contentOffsetX
        animateUnderlineViewIfNeeded()
    }
    
    // MARK: -
    
    func moveToMenu(_ page: Int, animated: Bool) {
        let duration = animated ? options.animationDuration : 0
        currentPage = page
        
        UIView.animate(withDuration: duration, delay: 0.0, options: [], animations: {
        }, completion: { (finished: Bool) in
            self.selectMenuItem()
            self.positionMenuItemViews()
        })
    }
    
    func enableScrolling(isEnabled: Bool) {
        isScrollEnabled = isEnabled
    }
}

