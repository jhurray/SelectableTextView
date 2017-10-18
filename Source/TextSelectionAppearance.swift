//
//  TextSelectionAppearance.swift
//  SelectableTextView
//
//  Created by Jeff Hurray on 2/18/17.
//  Copyright © 2017 jhurray. All rights reserved.
//

import Foundation

// MARK: TextSelectionAppearance
/// Additional attributes for text selection
public struct HighlightedTextSelectionAttributes {
    public static let SelectedBackgroundColorAttribute: NSAttributedStringKey = NSAttributedStringKey(rawValue: "HighlightedTextSelectionAttributes.SelectedBackgroundColorAttribute.Hurray")
}

public protocol TextSelectionAppearance {
    var selectionAttributes: [NSAttributedStringKey: Any]? {get}
    var replacementText: String? {get}
}
