//
//  TextValidators.swift
//  SelectableTextView
//
//  Created by Jeff Hurray on 2/9/17.
//  Copyright © 2017 jhurray. All rights reserved.
//

import Foundation

public struct MatchesTextValidator: TextSelectionValidator {
    
    private(set) var text: String
    private(set) var caseSensitive: Bool
    
    public init(text: String, caseSensitive: Bool = false) {
        self.text = text
        self.caseSensitive = caseSensitive
    }
    
    public var identifier: String {
        return "\(typeString).matches.\(text)"
    }
    
    public func validate(text: String) -> Bool {
        if caseSensitive {
            return self.text == text
        }
        return self.text.lowercased() == text.lowercased()
    }
}

public struct ContainsTextValidator: TextSelectionValidator {
    
    private(set) var text: String
    private(set) var caseSensitive: Bool
    
    public init(text: String, caseSensitive: Bool = false) {
        self.text = text
        self.caseSensitive = caseSensitive
    }
    
    public var identifier: String {
        return "\(typeString).contains.\(text)"
    }
    
    public func validate(text: String) -> Bool {
        if caseSensitive {
            return text.contains(self.text)
        }
        return text.lowercased().contains(self.text.lowercased())
    }
}

public struct PrefixValidator: TextSelectionValidator {
    
    private(set) var text: String
    private(set) var caseSensitive: Bool
    
    public init(prefix: String, caseSensitive: Bool = false) {
        self.text = prefix
        self.caseSensitive = caseSensitive
    }
    
    public var identifier: String {
        return "\(typeString).begins_with.\(text)"
    }
    
    public func validate(text: String) -> Bool {
        if caseSensitive {
            return text.hasPrefix(self.text)
        }
        return text.lowercased().hasPrefix(self.text.lowercased())
    }
}

public struct SuffixValidator: TextSelectionValidator {
    
    private(set) var text: String
    private(set) var caseSensitive: Bool
    
    public init(suffix: String, caseSensitive: Bool = false) {
        self.text = suffix
        self.caseSensitive = caseSensitive
    }
    
    public var identifier: String {
        return "\(typeString).ends_with.\(text)"
    }
    
    public func validate(text: String) -> Bool {
        if caseSensitive {
            return text.hasSuffix(self.text)
        }
        return text.lowercased().hasSuffix(self.text.lowercased())
    }
}

public struct HashtagTextValidator: ContainerTextSelectionValidator {
    
    public init() {}
    
    private(set) public var validator: TextSelectionValidator = PrefixValidator(prefix: "#")
    

}

public struct AtSymbolTagTextValidator: ContainerTextSelectionValidator {
    
    public init() {}
    
    private(set) public var validator: TextSelectionValidator = PrefixValidator(prefix: "@")
}

public struct QuotationsTextValidator: CompositeTextSelectionValidator {
    
    public init() {}
    
    private(set) public var validators: [TextSelectionValidator] =  [
        PrefixValidator(prefix: "\""),
        SuffixValidator(suffix: "\"")
    ]
}

public struct HandlebarsValidator: CompositeTextSelectionValidator {
    
    private(set) public var searchableText: String
    private(set) public var replacementText: String?
    private(set) public var validators: [TextSelectionValidator]
    
    public init(searchableText: String, replacementText: String) {
        self.searchableText = searchableText
        self.replacementText = replacementText
        self.validators =  [
                            PrefixValidator(prefix: "{{"),
                            SuffixValidator(suffix: "}}"),
                            MatchesTextValidator(text: "{{" + searchableText + "}}", caseSensitive: true),
                            ]
    }
}
