//
//  TextExpansionButtonCell.swift
//  SelectableTextView
//
//  Created by Jeff Hurray on 2/13/17.
//  Copyright © 2017 jhurray. All rights reserved.
//

import UIKit

public struct TextExpansionButtonConfig {
    public static var backgroundColor: UIColor? = nil
    public static var horizontalPadding: CGFloat = 2.5
}

class TextExpansionButtonCell: UICollectionViewCell {
    
    internal var model: TextExpansionButtonModel? {
        didSet {
            label.attributedText = model?.attributedText
        }
    }
    
    private let label: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadData() {
        backgroundColor = TextExpansionButtonConfig.backgroundColor ?? tintColor.withAlphaComponent(0.05)
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
    
    override var isHighlighted: Bool {
        willSet {
            var highlightedColor = UIColor.gray.withAlphaComponent(0.2)
            if let attributes = model?.attributes, let color = attributes[HighlightedTextSelectionAttributes.SelectedBackgroundColorAttribute] as? UIColor {
                highlightedColor = color
            }
            contentView.backgroundColor = newValue ? highlightedColor : .clear
        }
    }
}
