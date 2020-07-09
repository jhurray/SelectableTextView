//
//  ViewController.swift
//  SelectableTestView-Example-iOS
//
//  Created by Jeff Hurray on 2/5/17.
//  Copyright © 2017 jhurray. All rights reserved.
//

import UIKit
import SelectableTextView
import SafariServices



class ViewController: UIViewController, SelectableTextViewDelegate {
    
    @IBOutlet weak var textView: SelectableTextView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!

    var hashtagFrame: CGRect? {
        let frames = textView.framesOfWordsMatchingValidator(HashtagTextValidator())
        return frames.first
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        
        let githubLink = "https://github.com/jhurray/SelectableTextView"
        textView.text = "Hello, I'm {{my_name}}\0. I made \(githubLink) to solve the problem of highlighting and selecting specific text in UILabel and UITextView. An example is a hashtag like #Stars or an unsafe link like http://google.com\0!"
        
        let unsafeLinkValidator = UnsafeLinkValidator()
        textView.registerValidator(unsafeLinkValidator) { (text, validator) in
            self.showAlert(title: "🚫", message: "This link is bad mm'kay!")
        }
        
        textView.registerValidator(UIClassValidator())
        
        let githubLinkValidator = CustomLinkValidator(urlString: githubLink, replacementText: "SelectableTextView")
        textView.registerValidator(githubLinkValidator) { (text, validator) in
            if let linkValidator = validator as? CustomLinkValidator {
                self.openWebView(url: linkValidator.url)
            }
        }
        
        let myNameValidator = HandlebarsValidator(searchableText: "my_name", replacementText: "Jeff Hurray")
        textView.registerValidator(myNameValidator) { (text, validator) in
            self.openWebView(url: URL(string: "https://twitter.com/jeffhurray")!)
        }
        
        textView.registerValidator(HashtagTextValidator()) { (text, validator) in
            self.createParticles(seconds: 1)
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func openWebView(url: URL) {
        let browser = SFSafariViewController(url: url)
        present(browser, animated: true, completion: nil)
    }
    
    func animateExpansionButtonForSelectableTextView(textView: SelectableTextView) -> Bool {
        return false
    }
    
    func selectableTextViewContentHeightDidChange(textView: SelectableTextView, oldHeight: CGFloat, newHeight: CGFloat) {
        numberOfLinesLabel.text = "\(textView.numberOfLines)"
        heightConstraint.constant = min(newHeight, view.bounds.height)
        view.setNeedsLayout()
    }
    
    // MARK: Customization
    @IBOutlet weak var numberOfLinesLabel: UILabel!
    @IBOutlet weak var lineSpacingLabel: UILabel!
    @IBOutlet weak var numberOfLinesStepper: UIStepper!
    @IBOutlet weak var lineSpacingStepper: UIStepper!
    
    @IBAction func textAlignmentSelected(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            textView.textAlignment = .left
            break
        case 1:
            textView.textAlignment = .center
            break
        case 2:
            textView.textAlignment = .right
            break
        default:
            break
        }
    }
    
    @IBAction func truncationModeSelected(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            textView.truncationMode = .clipping
            break
        case 1:
            textView.truncationMode = .truncateTail
            break
        default:
            break
        }
    }
    
    @IBAction func numberOfLinesSelected(_ sender: UIStepper) {
        textView.numberOfLines = Int(sender.value)
        numberOfLinesLabel.text = "\(textView.numberOfLines)"
    }
    
    @IBAction func lineSpacingSelected(_ sender: UIStepper) {
        textView.lineSpacing = CGFloat(sender.value)
        lineSpacingLabel.text = "\(textView.lineSpacing)"
    }
    
    @IBAction func addExpansionButtonToggled(_ sender: UISwitch) {
        if sender.isOn {
            let attributes: [NSAttributedString.Key: Any] = [HighlightedTextSelectionAttributes.SelectedBackgroundColorAttribute : UIColor.purple.withAlphaComponent(0.5)]
            let collapsedNumberOfLines = max(Int(numberOfLinesStepper.value), 1)
            textView.addExpansionButton(collapsedState: ("More...", collapsedNumberOfLines),
                                        expandedState: ("Less", 0),
                                        attributes: attributes)
        }
        else {
            textView.removeExpansionButton(numberOfLines: Int(numberOfLinesStepper.value))
        }
    }
    
    func createParticles(seconds: TimeInterval) {
        
        if let frame = hashtagFrame {
            let particleEmitter = CAEmitterLayer()
            let center = CGPoint(x: frame.origin.x + frame.width / 2, y: frame.origin.y + frame.height / 2)
            particleEmitter.emitterPosition = center
            particleEmitter.emitterShape = CAEmitterLayerEmitterShape.point
            particleEmitter.emitterSize = frame.size
            
            let cell = makeEmitterCell()
            
            particleEmitter.emitterCells = [cell]
            
            textView.layer.addSublayer(particleEmitter)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                particleEmitter.removeFromSuperlayer()
            }
        }
    }
    
    func makeEmitterCell() -> CAEmitterCell {
        let cell = CAEmitterCell()
        let image = UIImage(named: "star")?.withRenderingMode(.alwaysTemplate)
        cell.contents = image?.cgImage
        cell.birthRate = 12
        cell.lifetime = 1.0
        cell.lifetimeRange = 0.2
        cell.velocity = 50
        cell.velocityRange = 20
        cell.emissionRange = CGFloat.pi * 2
        cell.spin = 2
        cell.spinRange = 3
        cell.scaleRange = 0.5
        cell.scaleSpeed = -0.05
        cell.alphaSpeed = 0.5
        cell.alphaRange = 0
        cell.scale = 1.0
        cell.scaleSpeed = 0.5
        cell.color = UIColor.yellow.cgColor

        return cell
    }
}
