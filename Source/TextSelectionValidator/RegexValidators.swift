//
//  RegexValidators.swift
//  SelectableTextView
//
//  Created by Jeff Hurray on 2/10/17.
//  Copyright © 2017 jhurray. All rights reserved.
//

import Foundation

fileprivate final class Regex {
    
    let internalExpression: NSRegularExpression
    let pattern: String
    
    init(_ pattern: String, options: NSRegularExpression.Options = .caseInsensitive) throws {
        self.pattern = pattern
        self.internalExpression = try NSRegularExpression(pattern: pattern, options: options)
    }

    func test(input: String) -> Bool {
        let matches = self.internalExpression.matches(in: input, options: [], range: NSMakeRange(0, input.characters.count))
        return matches.count > 0
    }
}

public struct RegexValidator: TextSelectionValidator {
    
    private(set) var pattern: String
    private var regex: Regex
    
    public init(pattern: String, options: NSRegularExpression.Options = .caseInsensitive) {
        self.pattern = pattern
        do {
            self.regex = try Regex(pattern, options: options)
        }
        catch {
            fatalError("Invalid regex: pattern = \(pattern), options = \(options)")
        }
    }
    
    public var identifier: String {
        return "\(typeString).regex_matches.\(pattern)"
    }
    
    public func validate(text: String) -> Bool {
        return regex.test(input: text)
    }
}

public struct EmailValidator: ContainerTextSelectionValidator {
    
    public init() {}
    
    private(set) public var validator: TextSelectionValidator = RegexValidator(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
}

public struct PhoneNumberValidator: ContainerTextSelectionValidator {
    
    public init() {}
    
    private(set) public var validator: TextSelectionValidator = RegexValidator(pattern: "^([0-9]( |-)?)?(\\(?[0-9]{3}\\)?|[0-9]{3})( |-)?([0-9]{3}( |-)?[0-9]{4}|[a-zA-Z0-9]{7})$")
}
