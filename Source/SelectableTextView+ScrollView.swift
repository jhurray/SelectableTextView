//
//  SelectableTextView+ScrollView.swift
//  SelectableTextView
//
//  Created by Jeff Hurray on 2/13/17.
//  Copyright © 2017 jhurray. All rights reserved.
//

import Foundation
import UIKit

public protocol SelectableTextViewScrollDelegate: class {
    
    func selectableTextViewDidScroll(_ scrollView: UIScrollView)
    func selectableTextViewWillBeginDragging(_ scrollView: UIScrollView)
    func selectableTextViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    func selectableTextViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    func selectableTextViewWillBeginDecelerating(_ scrollView: UIScrollView)
    func selectableTextViewDidEndDecelerating(_ scrollView: UIScrollView)
    func selectableTextViewDidEndScrollingAnimation(_ scrollView: UIScrollView)
}

public enum ScrollPosition {
    case top
    case center
    case bottom
}

public extension SelectableTextView {
    
    /// Scrolls to the first instance of the word
    /// Attempts to match the text and display text of a word
    public func scroll(toWord word: String, position: ScrollPosition, animated: Bool) {
        for (index, model) in textModels.enumerated() {
            if let _word = model as? Word {
                if _word.text == word || _word.displayText == word {
                    let indexPath = IndexPath(item: index, section: 0)
                    scroll(toIndexPath: indexPath, position: position, animated: animated)
                }
            }
        }
    }
    
    /// Scrolls to the first instance of a word that passes the provided TextSelectionValidator
    public func scroll(toWordPassingValidator validator: TextSelectionValidator, position: ScrollPosition, animated: Bool) {
        for (index, model) in textModels.enumerated() {
            if let word = model as? Word {
                if validator.validate(text: word.text) {
                    let indexPath = IndexPath(item: index, section: 0)
                    scroll(toIndexPath: indexPath, position: position, animated: animated)
                }
            }
        }
    }
    
    fileprivate func scroll(toIndexPath indexPath: IndexPath, position: ScrollPosition, animated: Bool) {
        var scrollPosition: UICollectionViewScrollPosition?
        switch position {
        case .top:
            scrollPosition = UICollectionViewScrollPosition.top
        case .center:
            scrollPosition = UICollectionViewScrollPosition.centeredVertically
        case .bottom:
            scrollPosition = UICollectionViewScrollPosition.top
        }
        collectionView.scrollToItem(at: indexPath, at: scrollPosition!, animated: animated)
    }
    
    // MARK: UIScrollView Event Forwarding
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.selectableTextViewDidScroll(scrollView)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollDelegate?.selectableTextViewWillBeginDragging(scrollView)
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollDelegate?.selectableTextViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollDelegate?.selectableTextViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }

    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollDelegate?.selectableTextViewWillBeginDecelerating(scrollView)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollDelegate?.selectableTextViewDidEndDecelerating(scrollView)
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollDelegate?.selectableTextViewDidEndScrollingAnimation(scrollView)
    }
}

// MARK: Empty Implementations
public extension SelectableTextViewScrollDelegate {
    func selectableTextViewDidScroll(_ scrollView: UIScrollView) {}
    func selectableTextViewWillBeginDragging(_ scrollView: UIScrollView) {}
    func selectableTextViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {}
    func selectableTextViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {}
    func selectableTextViewWillBeginDecelerating(_ scrollView: UIScrollView) {}
    func selectableTextViewDidEndDecelerating(_ scrollView: UIScrollView) {}
    func selectableTextViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {}
}
