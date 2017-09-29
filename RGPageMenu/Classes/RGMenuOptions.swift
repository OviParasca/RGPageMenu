//
//  MenuOptions.swift
//  paging
//
//  Created by realgreys on 2016. 5. 10..
//  Copyright © 2016 realgreys. All rights reserved.
//

import UIKit

open class RGPageMenuOptions {
    
    open var backgroundColor = UIColor.black
    open var selectedColor = UIColor.black
    open var textColor = UIColor.darkGray
    open var selectedTextColor = UIColor.white
    open var font = UIFont.systemFont(ofSize: 16)
    
    open var menuHeight: CGFloat = 45.0
    open var menuItemMargin: CGFloat = 10.0
    open var menuBounces = true
    open var menuScrolls = false
    open var menuPosition: MenuPosition = .top
    open var menuAlign: MenuAlign = .center
    open var menuStyle: MenuStyle = .underline(height: 3,
                                               color: UIColor.white,
                                               horizontalPadding: 0,
                                               verticalPadding: 0)
    
    open var defaultPage = 0
    open var animationDuration: TimeInterval = 0.3
    var menuItemCount: Int = 0
    
    
    public enum MenuPosition {
        case top
        case bottom
    }
    
    public enum MenuStyle {
        case none
        case underline(height: CGFloat, color: UIColor, horizontalPadding: CGFloat, verticalPadding: CGFloat)
    }
    
    // menu 개수가 frame width보다 작을 때 align 기준
    public enum MenuAlign {
        case left
        case center
        case right
        case fit
    }
    
    public init() {}
}

