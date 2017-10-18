//
//  TextViewLayout.swift
//  SelectableTextView
//
//  Created by Jeff Hurray on 2/4/17.
//  Copyright © 2017 jhurray. All rights reserved.
//

import UIKit

internal protocol TextViewLayoutDataSource: class {
    func lineSpacing(forLayout layout: TextViewLayout) -> CGFloat
    func numberOfLines(forLayout layout: TextViewLayout) -> Int
    func numberOfTextModels(forLayout layout: TextViewLayout) -> Int
    func truncationMode(forLayout layout: TextViewLayout) -> TruncationMode
    func textAlignment(forLayout layout: TextViewLayout) -> TextAlignment
    func cellModel(atIndex index:Int, layout: TextViewLayout) -> TextCellModel
    func expansionButtonModel(layout: TextViewLayout) -> TextExpansionButtonModel?
}

fileprivate struct AttributeKey: Hashable {
    var indexPath: IndexPath
    var kind: String
    
    fileprivate var hashValue: Int {
        return kind.hashValue ^ indexPath.hashValue
    }
}

fileprivate func ==(left: AttributeKey, right: AttributeKey) -> Bool {
    return left.hashValue == right.hashValue
}

internal struct TruncationContext {
    let indexOfCellModelNeedingTruncation: Int
    let transformedText: String
}


internal struct MalformedTextCellContext {
    let indicesOfMalformedCells: [Int]
}

internal final class TextViewLayout: UICollectionViewLayout {
    
    weak internal var dataSource: TextViewLayoutDataSource? = nil
    internal var truncationContext: TruncationContext? = nil
    internal var malformedTextCellContext: MalformedTextCellContext? = nil
    internal var onLayout: () -> () = {}
    
    fileprivate var contentHeight: CGFloat = 0
    fileprivate var contentWidth: CGFloat = 0
    fileprivate var cellAttributes: [AttributeKey:UICollectionViewLayoutAttributes] = [:]
    
    override func prepare() {
        super.prepare()
        guard let dataSource = dataSource else {
            return
        }
        if cellAttributes.isEmpty {
            contentWidth = collectionView!.bounds.width - collectionView!.contentInset.left - collectionView!.contentInset.right
            let numberOfLines = dataSource.numberOfLines(forLayout: self)
            let numberOfModels = dataSource.numberOfTextModels(forLayout: self)
            let lineSpacing = dataSource.lineSpacing(forLayout: self)
            var line: Int = 0
            var item: Int = 0
            var lineWidth: CGFloat = 0
            let lineHeight: CGFloat = maxLineHeight()
            
            if numberOfModels > 0 {
                contentHeight = lineHeight
            }
            
            var attributeKeysForCurrentLine: [AttributeKey] = []
            func alignCurrentLine() {
                var shiftValue = floor(contentWidth - lineWidth)
                switch dataSource.textAlignment(forLayout: self) {
                case .center:
                    shiftValue /= 2
                    break
                case .right:
                    // do nothing
                    break
                case .left:
                    shiftValue = 0
                    break
                }
                if shiftValue > 0 {
                    for key: AttributeKey in attributeKeysForCurrentLine {
                        adjustLayoutAttributesFrameForKey(key: key, frameAdjustment: { (frame) -> (CGRect) in
                            var frame = frame
                            frame.origin.x += shiftValue
                            return frame
                        })
                    }
                }
                attributeKeysForCurrentLine.removeAll(keepingCapacity: true)
            }
            
            func isLastLine() -> Bool {
                return numberOfLines != 0 && line == numberOfLines
            }
            
            var indicesOfMalformedCells: [Int] = []
            
            while (numberOfLines == 0 || line < numberOfLines) && item < numberOfModels {
                var xOrigin: CGFloat = lineWidth
                var width: CGFloat = 0
                
                func newLine(additionalWidth: CGFloat) {
                    line += 1
                    let isLastLine: Bool = (numberOfLines != 0 && line == numberOfLines)
                    if (!isLastLine) {
                        alignCurrentLine()
                        // Start new line
                        xOrigin = 0
                        lineWidth = additionalWidth
                        contentHeight += lineHeight + lineSpacing
                    }
                    else {
                        // Truncation
                        let truncationMode = dataSource.truncationMode(forLayout: self)
                        switch truncationMode {
                        case .clipping:
                            width = additionalWidth
                            lineWidth += additionalWidth
                            break
                        case .truncateTail:
                            let remainingWidth = contentWidth - lineWidth
                            width = remainingWidth
                            break
                        }
                    }
                }
                
                let model = dataSource.cellModel(atIndex: item, layout: self)
                switch model.type {
                case .newLine:
                    newLine(additionalWidth: 0)
                default:
                    let attributedText = model.attributedText
                    width = attributedText.width
                    // If this word will take up a whole line and not be the last line
                    if width > contentWidth && line < numberOfLines - 2 {
                        indicesOfMalformedCells.append(item)
                    }
                    
                    if (lineWidth + width) > contentWidth {
                        newLine(additionalWidth: width)
                    }
                    else {
                        lineWidth += width
                    }
                }
                
                if numberOfLines == 0 || line < numberOfLines || item == 0 {
                    let indexPath = IndexPath(item: item, section: 0)
                    let (attributes, key) = registerCell(cellType: TextCell.self, indexPath: indexPath)
                    attributes.frame = CGRect(x: xOrigin, y: contentHeight - lineHeight, width: max(0, min(width, contentWidth)), height: lineHeight)
                    attributeKeysForCurrentLine.append(key)
                    item += 1
                }
            }
            
            // Clean up the end of the text
            if expansionButtonNeedsNewLine() { // Expansion button needs a new line
                
                // Truncation for current line
                truncationContext = nil
                if let newLineWidth = adjustForTruncationIfNecessary(numberOfCellsHiddenByExpansion: 0, expansionOnNewLine: true) {
                    lineWidth = newLineWidth
                }
                // Align current line of text
                alignCurrentLine()
                // Add new linew
                contentHeight += lineHeight
                lineWidth = 0
                
                // Put expansion button on new line
                let (_, expansionButtonKey) = adjustForExpansionButton(lineHeight: lineHeight, onNewLine: true)
                // Move Expansion Button
                if let key = expansionButtonKey {
                    attributeKeysForCurrentLine.append(key)
                    if let attributes = cellAttributes[key] {
                        lineWidth += attributes.frame.width
                    }
                }
                // Align last line of text
                alignCurrentLine()
            }
            else {
                // Expansion
                let (numberOfCellsHiddenByExpansion, expansionButtonKey) = adjustForExpansionButton(lineHeight: lineHeight, onNewLine: false)
                // Truncation
                truncationContext = nil
                if let newLineWidth = adjustForTruncationIfNecessary(numberOfCellsHiddenByExpansion: numberOfCellsHiddenByExpansion, expansionOnNewLine:false) {
                    lineWidth = newLineWidth
                }
                // Move Expansion Button
                if let key = expansionButtonKey {
                    attributeKeysForCurrentLine.append(key)
                    if lineWidth < contentWidth - widthForExpansionButtonCell() {
                        adjustLayoutAttributesFrameForKey(key: key, frameAdjustment: { (frame) -> (CGRect) in
                            var frame = frame
                            frame.origin.x = lineWidth
                            lineWidth += frame.width
                            return frame
                        })
                    }
                }
                // Align last line of text
                alignCurrentLine()
            }
            
            malformedTextCellContext = indicesOfMalformedCells.isEmpty ? nil : MalformedTextCellContext(indicesOfMalformedCells: indicesOfMalformedCells)
        }
        onLayout()
    }
    
    fileprivate func expansionButtonNeedsNewLine() -> Bool {
        guard let dataSource = dataSource else {
            return false
        }
        
        let numberOfLines = dataSource.numberOfLines(forLayout: self)
        guard numberOfLines == 0 else {
            return false
        }
        
        let numberOfModels = dataSource.numberOfTextModels(forLayout: self)
        let (lastAttributes, _, _) = layoutInformationAtIndex(index: numberOfModels - 1)
        let remainingWidth = contentWidth - lastAttributes.frame.maxX
        let expansionButtonWidth = widthForExpansionButtonCell()
        return remainingWidth < expansionButtonWidth
    }
    
    fileprivate func widthForExpansionButtonCell() -> CGFloat {
        guard let expansionButtonModel = dataSource?.expansionButtonModel(layout: self) else {
            return 0
        }
        let padding: CGFloat = TextExpansionButtonConfig.horizontalPadding
        return expansionButtonModel.attributedText.width + 2 * padding
    }
    
    fileprivate func layoutInformationAtIndex(index: Int) -> (UICollectionViewLayoutAttributes, TextCellModel, AttributeKey) {
        let indexPath = IndexPath(item: index, section: 0)
        let key = AttributeKey(indexPath: indexPath, kind: TextCell.kind)
        guard let attributes = cellAttributes[key] else {
            fatalError("Attributes should not be nil")
        }
        guard let dataSource = dataSource else {
            fatalError("DataSource should not be nil")
        }
        let model = dataSource.cellModel(atIndex: index, layout: self)
        return (attributes, model, key)
    }
    
    // Returns he number of cells hidden, the key for the button attributes, and whether or not a new line was added
    fileprivate func adjustForExpansionButton(lineHeight: CGFloat, onNewLine: Bool) -> (Int, AttributeKey?) {
        guard let dataSource = dataSource else {
            return (0, nil)
        }
        guard (dataSource.expansionButtonModel(layout: self)) != nil else {
            return (0, nil)
        }
        
        let numberOfModels = dataSource.numberOfTextModels(forLayout: self)
        let expansionButtonWidth: CGFloat = widthForExpansionButtonCell()
        
        let indexPath = IndexPath(item: numberOfModels, section: 0)
        let (expansionButtonAttributes, expansionButtonKey) = registerCell(cellType: TextExpansionButtonCell.self, indexPath: indexPath)
        let xOrigin: CGFloat = onNewLine ? 0 : contentWidth - expansionButtonWidth
        expansionButtonAttributes.frame = CGRect(x: xOrigin, y: contentHeight - lineHeight, width: expansionButtonWidth, height: lineHeight)
        
        guard !onNewLine else {
            return (0, expansionButtonKey)
        }
        
        guard let attributeCollection = layoutAttributesForElements(in: expansionButtonAttributes.frame) else {
            return (0, expansionButtonKey)
        }
        var numberOfCellsHiddenByExpansion = 0
        for attributes in attributeCollection {
            let index = attributes.indexPath.item
            guard index != numberOfModels else {
                continue
            }
            let (_, _, key) = layoutInformationAtIndex(index: index)
            let expansionButtonFrame = expansionButtonAttributes.frame
            if expansionButtonFrame.contains(attributes.frame) {
                hideCellForKey(key: key)
                numberOfCellsHiddenByExpansion += 1
            }
            else {
                adjustLayoutAttributesFrameForKey(key: key, frameAdjustment: { (frame) -> (CGRect) in
                    assert(frame.height == expansionButtonFrame.height)
                    assert(frame.minY == expansionButtonFrame.minY)
                    assert(frame.minX <= expansionButtonFrame.minX)
                    var frame = frame
                    let intersection = expansionButtonFrame.intersection(frame)
                    frame.size.width -= intersection.width
                    return frame
                })
            }
        }
        return (numberOfCellsHiddenByExpansion, expansionButtonKey)
    }
    
    // Returns new value of line width
    fileprivate func adjustForTruncationIfNecessary(numberOfCellsHiddenByExpansion: Int, expansionOnNewLine: Bool) -> CGFloat? {
        guard let dataSource = dataSource else {
            return nil
        }
        let truncationMode = dataSource.truncationMode(forLayout: self)
        guard truncationMode != .clipping else {
            return nil
        }
        let numberOfLines = dataSource.numberOfLines(forLayout: self)
        guard numberOfLines > 0 else {
            return nil
        }
        
        let numberOfModels = dataSource.numberOfTextModels(forLayout: self)
        var numberOfCells = cellAttributes.count - numberOfCellsHiddenByExpansion
        
        if (dataSource.expansionButtonModel(layout: self)) != nil {
            numberOfCells -= 1
        }
        let expansionButtonWidth = expansionOnNewLine ? 0 : widthForExpansionButtonCell()
        
        guard numberOfCells > 0 else {
            return nil
        }
        
        // the last visible cell not covered by expansion
        let (lastCellAttributes, lastCellModel, lastKey) = layoutInformationAtIndex(index: numberOfCells - 1)
        let remainingWidth = contentWidth - lastCellAttributes.frame.minX - expansionButtonWidth
        let lastCellModelIsWordThatDoesntFit = (lastCellModel is Word)
                                            && (lastCellModel.attributedText.width > lastCellAttributes.frame.width)
                                            && (lastCellModel.text.truncatedString(fittingWidth: remainingWidth, attributes: lastCellModel.attributes) == nil)
        let needsTruncation: Bool = numberOfCells < numberOfModels || lastCellModelIsWordThatDoesntFit
        guard needsTruncation else {
            return nil
        }
        
        let isOnlyCell: Bool = (numberOfCells == 1)
        if lastCellModelIsWordThatDoesntFit {
            
            if isOnlyCell {
                return lastCellAttributes.frame.width
            }
            else {
                // hide last cell
                hideCellForKey(key: lastKey)
                numberOfCells -= 1
            }
        }
        
        // get the last visible word and create truncation context
        for cellIndex in (0..<numberOfCells).reversed() {
            let (attributes, model, key) = layoutInformationAtIndex(index: cellIndex)
            if let word = model as? Word, !attributes.isHidden {
                let availableWidthForTruncatedText: CGFloat = floor(contentWidth - attributes.frame.minX - expansionButtonWidth)
                let text = word.displayText ?? word.text
                guard let truncatedString = text.truncatedString(fittingWidth: availableWidthForTruncatedText, attributes: word.attributes) else {
                    // JHTODO assert? should ever happen?
                    return nil
                }
                let truncatedStringWidth = truncatedString.width(withAttributes: word.attributes)
                let newMaxX = attributes.frame.minX + truncatedStringWidth
                adjustLayoutAttributesFrameForKey(key: key, frameAdjustment: { (frame) -> (CGRect) in
                    var frame = frame
                    frame.size.width = truncatedStringWidth
                    return frame
                })
                truncationContext = TruncationContext(indexOfCellModelNeedingTruncation: cellIndex, transformedText: truncatedString)
                return newMaxX
            }
            
            else {
                hideCellForKey(key: key)
            }
        }
        return nil
    }
    
    fileprivate func hideCellForKey(key: AttributeKey) {
        adjustLayoutAttributesForKey(key: key, adjustment: { (attributes) -> (UICollectionViewLayoutAttributes) in
            attributes.isHidden = true
            return attributes
        })
    }
    
    fileprivate func adjustLayoutAttributesFrameForKey(key: AttributeKey, frameAdjustment: (CGRect) -> (CGRect)) {
        adjustLayoutAttributesForKey(key: key) { (attributes) -> (UICollectionViewLayoutAttributes) in
            let frame = frameAdjustment(attributes.frame)
            attributes.frame = frame
            return attributes
        }
    }
    
    fileprivate func adjustLayoutAttributesForKey(key: AttributeKey, adjustment: (UICollectionViewLayoutAttributes) -> (UICollectionViewLayoutAttributes)) {
        guard let attributes = cellAttributes[key] else {
            return
        }
        
        cellAttributes[key] = adjustment(attributes)
    }
    
    func maxLineHeight() -> CGFloat {
        guard let dataSource = dataSource else {
            return 0
        }
        var maxHeight: CGFloat = 0
        let numberOfModels = dataSource.numberOfTextModels(forLayout: self)
        var item = 0
        while item < numberOfModels {
            let model = dataSource.cellModel(atIndex: item, layout: self)
            let attributedString = model.attributedText
            maxHeight = max(maxHeight, attributedString.size().height)
            item += 1
        }
        return ceil(maxHeight)
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        cellAttributes = [AttributeKey:UICollectionViewLayoutAttributes]()
        contentWidth = 0
        contentHeight = 0
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cellAttributes.values.filter {
            return $0.frame.intersects(rect)
        }
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let key = AttributeKey(indexPath: indexPath, kind: TextCell.kind)
        return self.cellAttributes[key]
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return false
    }
    
    fileprivate func registerCell(cellType: UICollectionViewCell.Type, indexPath: IndexPath) -> (UICollectionViewLayoutAttributes, AttributeKey) {
        let key = AttributeKey(indexPath: indexPath, kind: cellType.kind)
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        cellAttributes[key] = attributes
        return (attributes, key)
    }
}
