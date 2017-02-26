//
//  TextCell.swift
//  SelectableTextView
//
//  Created by Jeff Hurray on 2/4/17.
//  Copyright © 2017 jhurray. All rights reserved.
//

import UIKit

internal final class TextCell: UICollectionViewCell {
    
    internal var model: TextCellModel? {
        didSet {
            label.attributedText = model?.attributedText
        }
    }
    
    internal var lineBreakMode: NSLineBreakMode {
        get {
            return label.lineBreakMode
        }
        set {
            label.lineBreakMode = newValue
        }
    }
    
    private let label: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        lineBreakMode = .byClipping
        contentView.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        lineBreakMode = .byClipping
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
            
            if let highlightable = model?.highlightable {
                contentView.backgroundColor = newValue && highlightable ? highlightedColor : .clear
            }
        }
    }
}
