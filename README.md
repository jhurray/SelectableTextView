<style>
.border {border-right: 1px solid #007AFF;}
.spaced {margin-left: 3.5%; padding-right: 3.5%;width: 25%;}
img.center {display: block; margin: 0 auto;}
</style>
<img class="center" src="./Resources/Logo.png">
<div><div>
<img width=32% src="./Resources/Feature1.png">
<img width=32% src="./Resources/Feature2.png">
<img width=32% src="./Resources/Feature3.png">
</div><div>
<img class="border spaced" src="./Resources/SelectableTextViewDemo1.gif">
<img class="border spaced" src="./Resources/SelectableTextViewDemo2.gif">
<img class="spaced" src="./Resources/SelectableTextViewDemo3.gif">
</div></div>

##The Problem
`UILabel` and `UITextView` offer unsatisfying support for text selection.

Existing solutions like [TTTAttributedLabel](https://github.com/TTTAttributedLabel/TTTAttributedLabel) are great but offer a somewhat limited API for text selection.

##Installation

####CocoaPods

Add the following to your `Podfile`

```ruby
pod 'SelectableTextView', '~> 0.0.1'
```

####Carthage

Add the following to your `Cartfile`

```ruby
github "jhurray/SelectableTextView" ~> 0.0.1
```

####Add to project Manually
Clone the repo and manually add the Files in [/SelectableTextView](./SelectableTextView)

##Usage

```swift
import SelectableTextView

let textView = SelectableTextView()
textView.truncationMode = .truncateTail
textView.numberOfLines = 3
...
```

##Text Selection

To create selectable text, you have to create and register a validator. The validator must conform to the `TextSelectionValidator` protocol.

```swift
let hashtagValidator = PrefixValidator(prefix: "#")
textView.registerValidator(validator: hashtagValidator) { (validText, validator) in
	// Handle selection of hashtag
}
```

You can unregister a validator at any time.

```swift
textView.removeValidator(validator: hashtagValidator)
```

###Custom Validators

[Here](JHTODO) is a resource for creating custom validators using the `TextSelectionValidator` protocol. 

There are other more specific protocols that make customization easier like `ContainerTextSelectionValidator` and `CompositeTextSelectionValidator`.

###Prewritten Validators

There are a few prewritten validators supplied. These can be used as they are, as building blocks for other more complex validators, and as examples on how to build custom validators.

#####Text Validators
```swift
MatchesTextValidator(text: String, caseSensitive: Bool = false)

ContainsTextValidator(text: String, caseSensitive: Bool = false)

PrefixValidator(text: String, caseSensitive: Bool = false)

SuffixValidator(text: String, caseSensitive: Bool = false)

HashtagTextValidator()

AtSymbolTagTextValidator()

QuotationsTextValidator()

HandlebarsValidator(searchableText: String, replacementText: String)
``` 

#####Abstract Validators
```swift
ReverseValidator(validator: TextSelectionValidator)

ContainerValidator(validator: TextSelectionValidator, selectionAttributes: [String: Any]? = nil)

CompositeValidator(validators: [TextSelectionValidator], selectionAttributes: [String: Any]? = nil)
```

#####Link Validators
```swift
LinkValidator() // Validates any link (HTTP, HTTPS, file, etc...)

HTTPLinkValidator() // Validates HTTP and HTTPS links

UnsafeLinkValidator() // Validates HTTP links

HTTPSLinkValidator()

CustomLinkValidator(urlString: String!, replacementText: String? = nil) 
```

Customization is possible using the `LinkValidatorAttributes` protocol. Example [here](JHTODO).

#####Regex Validators
```swift
RegexValidator(pattern: String, options: NSRegularExpression.Options = .caseInsensitive)

EmailValidator()

PhoneNumberValidator()
```

##Text Expansion
You can add a text expansion button with the following method:

```swift
public func addExpansionButton(collapsedState: (text: String, lines: Int), expandedState: (text: String, lines: Int), attributes: [String: Any]? = nil)
```

You can remove the expansion button using the following method:

```swift
public func removeExpansionButton(numberOfLines: Int = 1)
```

Example:

```swift
let attributes = [NSForegroundColorAttributeName: purple]
textView.addExpansionButton(collapsedState: ("More...", 2),
                             expandedState: ("Less", 0),
                                attributes: attributes)
                                
...

textView.removeExpansionButton(numberOfLines: 2)
```

You can customize the background color of the expansion button using the `SelectedBackgroundColorAttribute` property `HighlightedTextSelectionAttributes` struct as an attribute key.

```swift
let attributes: [String: Any] = [HighlightedTextSelectionAttributes.SelectedBackgroundColorAttribute : UIColor.purple]
```

##Customization

// JHTODO

##Interface Builder

You can set most customization properties via interface builder. `SelectableTextView` is marked as `@IBDesignable`.

* numberOfLines
* text
* textColor
* lineSpacing
* isSelectionEnabled
* isScrollEnabled
* fontSize
* truncateTail
* topTextInsets
* bottomTextInsets
* leftTextInsets
* rightTextInsets

##Delegate

Default implementations are provided for all `SelectableTextViewDelegate` methods.

```swift
public protocol SelectableTextViewDelegate: class {
    
    /// Resolves conflict between multiple validates that return `true` from their `validate:` method
    //
    // i.e. PrefixTextValidator for `#` and `#my` will both return true for `#myCoolHashtag`,
    // but the actions they are registered for may differ
    //
    /// Default behavior is to choose the first validator in the composite validator's `validators` array
    func resolveValidationConflictsForSelectableTextView(textView: SelectableTextView, conflictingValidators: [TextSelectionValidator]) -> TextSelectionValidator
    
    /// Defaults to `false`
    func animateExpansionButtonForSelectableTextView(textView: SelectableTextView) -> Bool
    
    /// Defaults to `.truncateTail`
    func truncationModeForWordsThatDontFitForSelectableTextView(textView: SelectableTextView) -> TruncationMode
    
    /// Optional, Default empty implementation provideed
    func selectableTextViewContentHeightDidChange(textView: SelectableTextView, oldHeight: CGFloat, newHeight: CGFloat)
}
```

##Scrolling

`SelectableTextView` supports scrolling and forwards scroll events through `SelectableTextViewScrollDelegate`.

```swift
public protocol SelectableTextViewScrollDelegate: class {
    
    func selectableTextViewDidScroll(_ scrollView: UIScrollView)
    func selectableTextViewWillBeginDragging(_ scrollView: UIScrollView)
    func selectableTextViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    func selectableTextViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    func selectableTextViewWillBeginDecelerating(_ scrollView: UIScrollView)
    func selectableTextViewDidEndDecelerating(_ scrollView: UIScrollView)
    func selectableTextViewDidEndScrollingAnimation(_ scrollView: UIScrollView)
}
```

You can also scroll to specific words or the first word that passes a validator.

```swift
/// Scrolls to the first instance of the word
/// Attempts to match the text and display text of a word
public func scrollToWord(_ word: String, position: ScrollPosition, animated: Bool)
    
   /// Scrolls to the first instance of a word that passes the provided TextSelectionValidator
public func scrollToWordPassingValidator(_ validator: TextSelectionValidator, position: ScrollPosition, animated: Bool)
```


##Goals

* Character wrapping
* More truncation styles: `.head`, `.center`

##Contact Info && Contributing

Feel free to email me at [jhurray33@gmail.com](mailto:jhurray33@gmail.com). I'd love to hear your thoughts on this, or see examples where this has been used.

[MIT License](https://github.com/jhurray/SelectableTextView/blob/master/LICENSE)