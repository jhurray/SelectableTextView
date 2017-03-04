//
//  LinkValidatorTests.swift
//  SelectableTextView
//
//  Created by Jeff Hurray on 3/4/17.
//  Copyright © 2017 jhurray. All rights reserved.
//

import Foundation
@testable import SelectableTextView

class LinkValidatorTests: SelectableTextViewTests {

    func testLinkValidator() {
        let validator = LinkValidator()
        let shouldPass = [
            "http://link",
            "https://link",
            "file://~/link",
            "yfansports://link",
        ]
        let shouldNotPass = [
            "http:/link",
            "https:link",
            "file///link",
            ]
        testValidator(validator: validator, shouldPass: shouldPass, shouldNotPass: shouldNotPass)
    }
    
    func testHTTPLinkValidator() {
        let validator = HTTPLinkValidator()
        let shouldPass = [
            "http://link",
            "https://link",
            ]
        let shouldNotPass = [
            "http:/link",
            "https:link",
            "file///link",
            "file://~/link",
            "yfansports://link",
            ]
        testValidator(validator: validator, shouldPass: shouldPass, shouldNotPass: shouldNotPass)
    }
    
    func testHTTPSLinkValidator() {
        let validator = HTTPSLinkValidator()
        let shouldPass = [
            "https://link",
            ]
        let shouldNotPass = [
            "http:/link",
            "https:link",
            "file///link",
            "file://~/link",
            "yfansports://link",
            "http://link",
            ]
        testValidator(validator: validator, shouldPass: shouldPass, shouldNotPass: shouldNotPass)
    }
    
    func testUnsafeLinkValidator() {
        let validator = UnsafeLinkValidator()
        let shouldPass = [
            "http://link",
            ]
        let shouldNotPass = [
            "http:/link",
            "https:link",
            "file///link",
            "file://~/link",
            "yfansports://link",
            "https://link",
            ]
        testValidator(validator: validator, shouldPass: shouldPass, shouldNotPass: shouldNotPass)
    }
    
    func testCustomLinkValidator() {
        let url = URL(string: "https://google.com")
        let validator = CustomLinkValidator(url: url)
        let shouldPass = [
            "https://google.com",
            ]
        let shouldNotPass = [
            "http:/link",
            "https:link",
            "file///link",
            "file://~/link",
            "yfansports://link",
            "http://link",
            "https://link",
            ]
        testValidator(validator: validator, shouldPass: shouldPass, shouldNotPass: shouldNotPass)
    }
}
