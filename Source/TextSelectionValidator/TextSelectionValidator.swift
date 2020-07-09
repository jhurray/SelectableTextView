//
//  SelectionValidator.swift
//  SelectableTextView
//
//  Created by Jeff Hurray on 2/9/17.
//  Copyright © 2017 jhurray. All rights reserved.
//

import Foundation

// MARK: TextSelectionValidator
public protocol TextSelectionValidator: TextSelectionAppearance {
    
    var identifier: String {get}
    var selectionAttributes: [NSAttributedString.Key: Any]? {get}
    var replacementText: String? {get}
    
    func validate(text: String) -> Bool
}

public extension TextSelectionValidator {
    
    var selectionAttributes: [NSAttributedString.Key: Any]? {
        return nil
    }
    
    var replacementText: String?  {
        return nil
    }
}

internal extension TextSelectionValidator {
    
    var typeString: String {
        return String(describing: type(of: self))
    }
}

// MARK: ContainerTextSelectionValidator
public protocol ContainerTextSelectionValidator: TextSelectionValidator {
        
    var validator: TextSelectionValidator {get}
    var identifier: String {get}
    
    func validate(text: String) -> Bool
}

public extension ContainerTextSelectionValidator {
    
    var identifier: String {
        return "\(typeString)." + validator.identifier
    }
    
    func validate(text: String) -> Bool {
        return validator.validate(text: text)
    }
}


// MARK: CompositeTextSelectionValidator
public protocol CompositeTextSelectionValidator: TextSelectionValidator {
    
    var validators: [TextSelectionValidator] {get}
    var identifier: String {get}
    
    func validate(text: String) -> Bool
}

public extension CompositeTextSelectionValidator {
    
    var identifier: String {
        return validators.reduce("\(typeString)", { (compositeIdentifier: String, validator: TextSelectionValidator) -> String in
            return "\(compositeIdentifier).\(validator.identifier)"
        })
    }
    
    func validate(text: String) -> Bool {
        for validator in validators {
            if validator.validate(text: text) == false {
                return false
            }
        }
        return true
    }
}


// MARK: Internal
internal struct DefaultInvalidTextValidator: TextSelectionValidator {
    
    public var identifier: String {
        return "\(typeString).default_to_invalid"
    }
    
    public func validate(text: String) -> Bool {
        return false
    }
}
