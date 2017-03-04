//
//  SelectableTextViewTests.swift
//  SelectableTextViewTests
//
//  Created by Jeff Hurray on 2/4/17.
//  Copyright © 2017 jhurray. All rights reserved.
//

import XCTest
@testable import SelectableTextView

internal class SelectableTextViewTests: XCTestCase {
    
    internal func testValidator(validator: TextSelectionValidator, shouldPass: [String], shouldNotPass:[String]) {
        for text in shouldPass {
            XCTAssertTrue(validator.validate(text: text))
        }
        for text in shouldNotPass {
            XCTAssertFalse(validator.validate(text: text))
        }
    }
}
