//
//  Extensions.swift
//  SelectableTextView
//
//  Created by Jeff Hurray on 2/9/17.
//  Copyright © 2017 jhurray. All rights reserved.
//

import Foundation

// MARK: Bool
internal extension Bool {
    
    mutating func toggle() {
        self = !self
    }
}

// MARK: Character
internal extension Character {
    
    static let space: Character = " "
    
    static let newLine: Character = "\n"
    
    static let tab: Character = "\t"
    
    static let terminator: Character = "\0"
}


// MARK: String
internal extension String {
    
    var length: Int {
        return characters.count
    }
    
    func truncate(leadingCharacters: Int) -> String {
        let range = Range(uncheckedBounds: (startIndex, index(startIndex, offsetBy: leadingCharacters)))
        let start: String = String(self[range])
        let truncation: String = "..."
        return start.appending(truncation)
    }
    
    func width(withAttributes attributes: [NSAttributedStringKey: Any]?) -> CGFloat {
        let attributedString = NSAttributedString(string: self, attributes: attributes)
        return attributedString.size().width
    }
    
    func truncatedString(fittingWidth width: CGFloat, attributes: [NSAttributedStringKey: Any]?) -> String? {
        
        func passesTest(leadingCharacters: Int) -> Bool {
            let truncatedString = truncate(leadingCharacters: leadingCharacters)
            let truncatedWidth = truncatedString.width(withAttributes: attributes)
            return width > truncatedWidth
        }
        
        guard passesTest(leadingCharacters: 0) else {
            return nil
        }
        for length in (0...self.length).reversed() {
            if passesTest(leadingCharacters: length) {
                return truncate(leadingCharacters: length)
            }
        }
        return nil
    }
}


// MARK: UICollectionReusableView
internal extension UICollectionReusableView {
    
    class var defaultIdentifier: String {
        return String(describing: self)
    }
    
    class var kind: String {
        return defaultIdentifier
    }
}


// MARK: NSAttributedString
internal extension NSAttributedString {
    
    var width: CGFloat {
        return size().width
    }
    
    var height: CGFloat {
        return size().height
    }
}


// MARKL CGRect
internal extension CGRect {
    
    func translate(x: CGFloat, y: CGFloat) -> CGRect {
        let newOrigin = CGPoint(x: origin.x + x, y: origin.y + y)
        return CGRect(origin: newOrigin, size: size)
    }
}
