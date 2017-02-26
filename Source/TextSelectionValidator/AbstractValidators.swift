//
//  AbstractValidators.swift
//  SelectableTextView
//
//  Created by Jeff Hurray on 2/19/17.
//  Copyright © 2017 jhurray. All rights reserved.
//

import Foundation

// MARK: ReverseValidator
public struct ReverseValidator: ContainerTextSelectionValidator {
    
    private(set) public var validator: TextSelectionValidator
    
    public init(validator: TextSelectionValidator) {
        self.validator = validator
    }
    
    public func validate(text: String) -> Bool {
        return !validator.validate(text: text)
    }
}

// MARK: ContainerValidator
public struct ContainerValidator: ContainerTextSelectionValidator {
    
    private(set) public var validator: TextSelectionValidator
    private(set) public var selectionAttributes: [String: Any]?
    
    public init(validator: TextSelectionValidator, selectionAttributes: [String: Any]? = nil) {
        self.validator = validator
        self.selectionAttributes = selectionAttributes
    }
}

// MARK: CompositeValidator
public struct CompositeValidator: CompositeTextSelectionValidator {
    
    private(set) public var validators: [TextSelectionValidator]
    private(set) public var selectionAttributes: [String: Any]?
    
    public init(validators: [TextSelectionValidator], selectionAttributes: [String: Any]? = nil) {
        self.validators = validators
        self.selectionAttributes = selectionAttributes
    }
}
