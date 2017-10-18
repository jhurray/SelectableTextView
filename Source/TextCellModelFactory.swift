//
//  TextViewModelFactory.swift
//  SelectableTextView
//
//  Created by Jeff Hurray on 2/6/17.
//  Copyright © 2017 jhurray. All rights reserved.
//

import Foundation


fileprivate extension TextType {
    
    static func fromCharacter(character: Character) -> TextType {
        switch character {
        case Character.space:
            return .space
        case Character.newLine:
            return .newLine
        case Character.tab:
            return .tab
        case Character.terminator:
            return .terminator
        default:
            return .word
        }
    }
}


final internal class TextCellModelFactory {
    
    internal func buildTextModels(attributedText: NSAttributedString?) -> [TextCellModel] {
        
        var textModels: [TextCellModel] = []
        
        guard let attributedText = attributedText else {
            return textModels
        }
        
        let text = attributedText.string
        guard text.characters.count > 0 else {
            return textModels
        }
        
        var characterCount: Int = 0
        var currentTextChunkStart = 0
        var currentTextChunkType = TextType.fromCharacter(character: text[text.startIndex])
        typealias _Index = String.CharacterView.Index
        
        func addModelAtIndex(index: _Index) {
            let currentTextChunkEnd = characterCount
            let range = Range<Int>(uncheckedBounds: (currentTextChunkStart, currentTextChunkEnd))
            let length = characterCount - currentTextChunkStart
            let attributes = attributedText.attributes(at: currentTextChunkStart, longestEffectiveRange: nil, in: NSMakeRange(currentTextChunkStart, length))
            
            switch currentTextChunkType {
            case .newLine:
                let newLine = NewLine(range: range, attributes: attributes)
                textModels.append(newLine)
                break
            case .tab:
                let tab = Tab(range: range, attributes: attributes)
                textModels.append(tab)
                break
            case .space:
                let space = Space(range: range, length: length, attributes: attributes)
                textModels.append(space)
                break
            case .terminator:
                // Do Nothing
                break
            case .word:
                let substringRange = Range<_Index>(uncheckedBounds: (text.index(text.startIndex, offsetBy: currentTextChunkStart), text.index(text.startIndex, offsetBy: characterCount)))
                let substring = String(text[substringRange])
                let word = Word(range: range, text: substring, attributes: attributes, displayText: nil, highlightable: false)
                textModels.append(word)
                break
            }
            currentTextChunkStart = currentTextChunkEnd
        }
        
        for index in text.characters.indices {
            let currentCharacterTextType = TextType.fromCharacter(character: text[index])
            if currentTextChunkType != currentCharacterTextType {
                addModelAtIndex(index: index)
                currentTextChunkType = currentCharacterTextType
            }
            characterCount += 1
        }
        addModelAtIndex(index: text.endIndex)
        
        return textModels
    }
}
