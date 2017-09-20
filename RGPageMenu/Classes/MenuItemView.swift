//
//  MenuItemView.swift
//  paging
//
//  Created by realgreys on 2016. 5. 10..
//  Copyright © 2016 realgreys. All rights reserved.
//

import UIKit

class MenuItemView: UIView {
    
    fileprivate var options: RGPageMenuOptions!
    
    var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate var labelSize: CGSize {
        guard let text = titleLabel.text else { return .zero }
        return NSString(string: text).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
                                                   options: .usesLineFragmentOrigin,
                                                   attributes: [NSAttributedStringKey.font: titleLabel.font],
                                                   context: nil).size
    }
    fileprivate var widthConstraint: NSLayoutConstraint!
    
    var selected: Bool = false {
        didSet {
            backgroundColor = selected ? options.selectedColor : options.backgroundColor
            titleLabel.textColor = selected ? options.selectedTextColor : options.textColor
            
            // font가 변경되면 size 계산 다시 해야 한다.
        }
    }
    
    // MARK: - Lifecycle
    
    init(title: String, options: RGPageMenuOptions) {
        super.init(frame: .zero)
        
        self.options = options
        
        backgroundColor = options.backgroundColor
        translatesAutoresizingMaskIntoConstraints = false
        
        setupLabel(title)
        layoutLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Layout
    
    fileprivate func setupLabel(_ title: String) {
        titleLabel.text = title
        titleLabel.textColor = options.textColor
        titleLabel.font = options.font
        addSubview(titleLabel)
    }
    
    fileprivate func layoutLabel() {
        let viewsDictionary = ["label": titleLabel]
        
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[label]|",
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: viewsDictionary)
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]|",
                                                                 options: [],
                                                                 metrics: nil,
                                                                 views: viewsDictionary)
        
        NSLayoutConstraint.activate(horizontalConstraints + verticalConstraints)
        
        let labelSize = calcLabelSize()
        widthConstraint = NSLayoutConstraint(item: titleLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: labelSize.width)
        widthConstraint.isActive = true
    }
    
    fileprivate func calcLabelSize() -> CGSize {
        
        let height = floor(labelSize.height) // why floor?
        
        if options.menuAlign == .fit {
            let windowSize = UIApplication.shared.keyWindow!.bounds.size
            let width = windowSize.width / CGFloat(options.menuItemCount)
            return CGSize(width: width, height: height)
        } else {
            let width = ceil(labelSize.width)
            
            return CGSize(width: width + options.menuItemMargin * 2, height: height)
        }
    }
    
}
