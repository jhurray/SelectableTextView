//
//  TextCellModel.swift
//  SelectableTextView
//
//  Created by Jeff Hurray on 2/6/17.
//  Copyright © 2017 jhurray. All rights reserved.
//

import Foundation

internal enum TextType {
    case word
    case space
    case newLine
    case tab
    case terminator
}

internal protocol TextCellModel {
    var range: Range<Int> {get}
    var text: String {get}
    var displayText: String? {get}
    var attributes: [NSAttributedStringKey: Any] {get}
    var attributedText: NSAttributedString {get}
    var type: TextType {get}
    var highlightable: Bool {get}
}

internal extension TextCellModel {
    var displayText: String? {
        return nil
    }
    
    var highlightable: Bool {
        return false
    }
}

internal struct Word: TextCellModel {
    var range: Range<Int>
    var text: String
    var attributes: [NSAttributedStringKey: Any]
    var displayText: String?
    var highlightable: Bool
    
    var type: TextType {
        return .word
    }
    
    var attributedText: NSAttributedString {
        let _text = displayText ?? text
        return NSAttributedString(string: _text, attributes: attributes)
    }
}

internal struct Space: TextCellModel {
    private let space = " "
    var range: Range<Int>
    var length: Int
    var attributes: [NSAttributedStringKey: Any]
    
    var type: TextType {
        return .space
    }
    
    var text: String {
        return String(repeating: space, count: length)
    }
    
    var attributedText: NSAttributedString {
        return NSAttributedString(string: text, attributes: attributes)
    }
}

internal struct NewLine: TextCellModel {
    var range: Range<Int>
    var attributes: [NSAttributedStringKey: Any]
    
    var type: TextType {
        return .newLine
    }
    
    var text: String {
        return ""
    }
    
    var attributedText: NSAttributedString {
        return NSAttributedString(string: text, attributes: attributes)
    }
}

public struct TabTextModelConfig {
    // Number of space per tab
    public static var numberOfSpaces: Int = 4
}

internal struct Tab: TextCellModel {
    var range: Range<Int>
    var attributes: [NSAttributedStringKey: Any]
    
    var type: TextType {
        return .tab
    }
    
    var text: String {
        return String(repeating: String(.space), count: TabTextModelConfig.numberOfSpaces)
    }
    
    var attributedText: NSAttributedString {
        return NSAttributedString(string: text, attributes: attributes)
    }
}
