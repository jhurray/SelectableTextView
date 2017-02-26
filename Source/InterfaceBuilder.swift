//
//  InterfaceBuilder.swift
//  SelectableTextView
//
//  Created by Jeff Hurray on 2/19/17.
//  Copyright © 2017 jhurray. All rights reserved.
//

import Foundation

// MARK: Interface Builder
public extension SelectableTextView {
    
    public override func prepareForInterfaceBuilder() {
        lineSpacing = 1
        lineBreakMode = .wordWrap
        textAlignment = .left
        truncationMode = .clipping
        textColor = .darkText
        font = .systemFont(ofSize: 17)
        topTextInsets = 0
        bottomTextInsets = 0
        leftTextInsets = 0
        rightTextInsets = 0
        fontSize = 17
    }
    
    @IBInspectable var fontSize: CGFloat {
        set {
            font = font.withSize(newValue)
        }
        get {
            return font.pointSize
        }
    }
    
    @IBInspectable var trucateTail: Bool  {
        set {
            truncationMode = newValue ? .truncateTail : .clipping
        }
        get {
            return truncationMode == .truncateTail
        }
    }
    
    @IBInspectable var topTextInsets: CGFloat {
        set {
            textContainerInsets.top = newValue
        }
        get {
            return textContainerInsets.top
        }
    }
    
    @IBInspectable var bottomTextInsets: CGFloat {
        set {
            textContainerInsets.bottom = newValue
        }
        get {
            return textContainerInsets.bottom
        }
    }
    
    @IBInspectable var leftTextInsets: CGFloat {
        set {
            textContainerInsets.left = newValue
        }
        get {
            return textContainerInsets.left
        }
    }
    
    @IBInspectable var rightTextInsets: CGFloat {
        set {
            textContainerInsets.right = newValue
        }
        get {
            return textContainerInsets.right
        }
    }
}
