//
//  TextExpansionButtonModel.swift
//  SelectableTextView
//
//  Created by Jeff Hurray on 2/13/17.
//  Copyright © 2017 jhurray. All rights reserved.
//

import Foundation

internal struct TextExpansionButtonModel {
    
    var expanded: Bool
    let expandedText: String
    let collapsedText: String
    let expandedNumberOfLines: Int
    let collapsedNumberOfLines: Int
    let attributes: [NSAttributedStringKey: Any]?
    
    var numberOfLines: Int {
        return expanded ? expandedNumberOfLines : collapsedNumberOfLines
    }
    
    var attributedText: NSAttributedString {
        if expanded {
            return NSAttributedString(string: expandedText, attributes: attributes)
        }
        else {
            return NSAttributedString(string: collapsedText, attributes: attributes)
        }
    }
}
