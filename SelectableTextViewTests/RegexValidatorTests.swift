//
//  RegexValidatorTests.swift
//  SelectableTextView
//
//  Created by Jeff Hurray on 3/4/17.
//  Copyright © 2017 jhurray. All rights reserved.
//

import Foundation
@testable import SelectableTextView

class RegexValidatorTests: SelectableTextViewTests {
    
    func testEmailValidator() {
        let validator = EmailValidator()
        let shouldPass = [
            "jhurray@umich.edu",
            "bob@hotmail.eu",
            "hello@yahoo.com",
            ]
        let shouldNotPass = [
            "@bobyahoo.com",
            "hello@yahoo",
            "jhurray@umichcom",
            ]
        testValidator(validator: validator, shouldPass: shouldPass, shouldNotPass: shouldNotPass)
    }
    
    func testPhoneNumberValidator() {
        let validator = PhoneNumberValidator()
        let shouldPass = [
            "1234567890",
            "(123)-456-7890",
            "123-456-7890",
            ]
        let shouldNotPass = [
            "123456789",
            "(12)3-456-7890",
            "23-456-7890",
            ]
        testValidator(validator: validator, shouldPass: shouldPass, shouldNotPass: shouldNotPass)
    }
}
