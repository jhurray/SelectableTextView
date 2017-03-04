//
//  TextValidatorTests.swift
//  SelectableTextView
//
//  Created by Jeff Hurray on 3/4/17.
//  Copyright © 2017 jhurray. All rights reserved.
//

import Foundation
@testable import SelectableTextView

class TextValidatorTests: SelectableTextViewTests {
    
    func testMatchesTextValidator() {
        let validator = MatchesTextValidator(text: "Test", caseSensitive: false)
        testValidator(validator: validator, shouldPass: ["test", "Test", "TEST", "tesT"], shouldNotPass: ["testing", "atest"])
    }
    
    func testMatchesTextValidatorCaseSensitive() {
        let validator = MatchesTextValidator(text: "Test", caseSensitive: true)
        testValidator(validator: validator, shouldPass: ["Test"], shouldNotPass: ["Testing", "aTest", "test", "TEST"])
    }
    
    func testMatchesContainsTextValidator() {
        let validator = ContainsTextValidator(text: "Test", caseSensitive: false)
        let shouldPass = ["test", "Test", "TEST", "tesT", "atest", "testing", "ateSTing"]
        testValidator(validator: validator, shouldPass: shouldPass, shouldNotPass: ["tst", "estingt"])
    }
    
    func testContainsTextValidatorCaseSensitive() {
        let validator = ContainsTextValidator(text: "Test", caseSensitive: true)
        let shouldPass = ["omgTest", "Testing", "Test"]
        testValidator(validator: validator, shouldPass: shouldPass, shouldNotPass: ["TEST", "tesT", "atest", "tst", "estingt", "test"])
    }
    
    func testPrefixValidator() {
        let validator = PrefixValidator(prefix: "Test", caseSensitive: false)
        testValidator(validator: validator, shouldPass: ["Test", "test", "testify"], shouldNotPass: ["attesting", "omgTest"])
    }
    
    func testMatchesPrefixValidatorCaseSensitive() {
        let validator = PrefixValidator(prefix: "Test", caseSensitive: true)
        testValidator(validator: validator, shouldPass: ["Test", "Testify"], shouldNotPass: ["Attesting", "aTest", "test", "TEST", "testify"])
    }
    
    func testSuffixValidator() {
        let validator = SuffixValidator(suffix: "Test", caseSensitive: false)
        testValidator(validator: validator, shouldPass: ["Test", "test", "attest", "Intertest"], shouldNotPass: ["attesting", "omgTesting", "testing"])
    }
    
    func testMatchesSuffixValidatorCaseSensitive() {
        let validator = SuffixValidator(suffix: "Test", caseSensitive: true)
        testValidator(validator: validator, shouldPass: ["Test", "ATTest"], shouldNotPass: ["Attesting", "aTestt", "test", "TEST", "testify", "attest"])
    }
    
    func testHashtagTextValidator() {
        let validator = HashtagTextValidator()
        testValidator(validator: validator, shouldPass: ["#Test", "#test", "#attest", "#"], shouldNotPass: ["a#ttesting", "omgTesting#", "testing"])
    }
    
    func testAtSymbolTagTextValidator() {
        let validator = AtSymbolTagTextValidator()
        testValidator(validator: validator, shouldPass: ["@Test", "@test", "@attest", "@"], shouldNotPass: ["a@ttesting", "omgTesting@", "testing"])
    }
    
    func testQuotationsTextValidator() {
        let validator = QuotationsTextValidator()
        testValidator(validator: validator, shouldPass: ["\"Test\""], shouldNotPass: ["a\"ttesting\"", "\"omgTesting@", "testing\"", "testing"])
    }
    
    func testHandlebarsValidator() {
        let validator = HandlebarsValidator(searchableText: "test", replacementText: "Test")
        testValidator(validator: validator, shouldPass: ["{{test}}"], shouldNotPass: ["{test}", "{{test}", "test", "{{testing}}", "{{Test}}"])
    }
}
