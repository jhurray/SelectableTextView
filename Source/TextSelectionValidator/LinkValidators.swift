//
//  LinkValidators.swift
//  SelectableTextView
//
//  Created by Jeff Hurray on 2/10/17.
//  Copyright © 2017 jhurray. All rights reserved.
//

import Foundation

public protocol LinkValidatorAttributes: TextSelectionValidator {
    var tintColor: UIColor? {get}
    var underlined: Bool {get}
}

public extension LinkValidatorAttributes {
    
    public var tintColor: UIColor? {
        return nil
    }
    
    public var underlined: Bool {
        return true
    }
    
    public var selectionAttributes: [NSAttributedStringKey : Any]? {
        var attributes: [NSAttributedStringKey: Any] = [:]
        if let tintColor = tintColor {
            attributes[NSAttributedStringKey.foregroundColor] = tintColor
        }
        if underlined {
            attributes[NSAttributedStringKey.underlineStyle] = NSUnderlineStyle.styleSingle.rawValue
        }
        return attributes
    }
}

public struct LinkValidator: ContainerTextSelectionValidator, LinkValidatorAttributes {
    
    public init() {}
    
    private(set) public var validator: TextSelectionValidator = ContainsTextValidator(text: "://")
}


// Works for HTTP and HTTPS Links
public struct HTTPLinkValidator: CompositeTextSelectionValidator, LinkValidatorAttributes{
    
    public init() {}
    
    private(set) public var validators: [TextSelectionValidator] =  [
        PrefixValidator(prefix: "http"),
        ContainsTextValidator(text: "://")
    ]
}

public struct UnsafeLinkValidator: ContainerTextSelectionValidator, LinkValidatorAttributes{
    
    public init() {}
    
    private(set) public var validator: TextSelectionValidator =  PrefixValidator(prefix: "http://")
    
    private(set) public var selectionAttributes: [NSAttributedStringKey: Any]? = [NSAttributedStringKey.foregroundColor: UIColor.red]
}


public struct HTTPSLinkValidator: ContainerTextSelectionValidator, LinkValidatorAttributes {
    
    public init() {}
    
    private(set) public var validator: TextSelectionValidator = PrefixValidator(prefix: "https://")
}

public struct CustomLinkValidator: ContainerTextSelectionValidator, LinkValidatorAttributes {
    
    private(set) public var replacementText: String?
    private(set) public var url: URL
    private(set) public var validator: TextSelectionValidator
    
    public init(urlString: String!, replacementText: String? = nil) {
        self.url = URL(string: urlString)!
        self.replacementText = replacementText
        self.validator = MatchesTextValidator(text: urlString)
    }
    
    public init(url: URL!, replacementText: String? = nil) {
        self.url = url
        self.replacementText = replacementText
        self.validator = MatchesTextValidator(text: url.absoluteString)
    }
}
