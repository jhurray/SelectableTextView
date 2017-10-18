//
//  Operators.swift
//  SelectableTextView
//
//  Created by Jeff Hurray on 2/10/17.
//  Copyright © 2017 jhurray. All rights reserved.
//

import Foundation

internal func += <K,V>(left: Dictionary<K,V>?, right: Dictionary<K,V>) -> Dictionary<K,V> {
    
    guard let _left = left else {
        return right
    }
    var left = _left
    for (key, value) in right {
        left.updateValue(value, forKey: key)
    }
    return left
}
