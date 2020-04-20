//
//  CustomPrintPageRenderer.swift
//  Print2PDF
//
//  Created by Gabriel Theodoropoulos on 24/06/16.
//  Copyright © 2016 Appcoda. All rights reserved.
//

import UIKit

public class PDFPrintPageRenderer: UIPrintPageRenderer {

    let A4PageWidth: CGFloat = 595.2
    
    let A4PageHeight: CGFloat = 841.8

    public enum PagesOnFooterSide {
        case left, right, inside, outside, none
    }

    public var headerText: String = "Exercise Report"
    public var footerText: String = "Footer Text"

    public var showPagesOnFooter: PagesOnFooterSide = .none

    public var headerFont: UIFont = UIFont(name: "AmericanTypewriter-Bold", size: 28.0)!
    public var headerFontColor: UIColor = UIColor(red: 243.0/255, green: 82.0/255.0, blue: 30.0/255.0, alpha: 1.0)

    public var footerFont: UIFont = UIFont(name: "Noteworthy-Bold", size: 14.0)!
    public var footerFontColor: UIColor  = UIColor(red: 70.0/255, green: 130.0/255.0, blue: 180.0/255.0, alpha: 1.0)

    public var pageNumberFont: UIFont = UIFont(name: "Noteworthy-Bold", size: 10.0)!
    public var pageNumberFontColor: UIColor = UIColor(red: 205.0/255, green: 205.0/255.0, blue: 205.0/255.0, alpha: 1.0)

    public var horizontalRuleColor: UIColor = UIColor(red: 205.0/255.0, green: 205.0/255.0, blue: 205.0/255, alpha: 1.0)

    override init() {
        super.init()
        
        // Specify the frame of the A4 page.
        let pageFrame = CGRect(x: 0.0, y: 0.0, width: A4PageWidth, height: A4PageHeight)
        
        // Set the page frame.
        self.setValue(NSValue(cgRect: pageFrame), forKey: "paperRect")
        
        // Set the horizontal and vertical insets (that's optional).
        // self.setValue(NSValue(CGRect: pageFrame), forKey: "printableRect")
        self.setValue(NSValue(cgRect: pageFrame.insetBy(dx: 10.0, dy: 10.0)), forKey: "printableRect")
        
        self.headerHeight = 50.0
        self.footerHeight = 50.0
    }
    
    
    public override func drawHeaderForPage(at pageIndex: Int, in headerRect: CGRect) {
        // Specify the header text.
        let headerText: NSString = self.headerText as NSString
        
        // Specify some text attributes we want to apply to the header text.
        let textAttributes = [
            NSAttributedString.Key.font: headerFont,
            NSAttributedString.Key.foregroundColor: headerFontColor,
            NSAttributedString.Key.kern: 7.5
            ] as [NSAttributedString.Key : Any]
        
        // Calculate the text size.
        let textSize = getTextSize(text: headerText as String, font: nil, textAttributes: textAttributes)
        
        // Determine the offset to the right side.
        let offsetX: CGFloat = 20.0
        
        // Specify the point that the text drawing should start from.
        let pointX = headerRect.size.width - textSize.width - offsetX
        let pointY = headerRect.size.height/2 - textSize.height/2
        
        // Draw the header text.
        headerText.draw(at: CGPoint(x: pointX, y: pointY), withAttributes: textAttributes)
    }

    public override func drawFooterForPage(at pageIndex: Int, in footerRect: CGRect) {
        let footerText: NSString = self.footerText as NSString
        let textSize = getTextSize(text: footerText as String, font: footerFont)

        let pageNumberText: NSString = "Page \(pageIndex + 1) of \(numberOfPages)" as NSString
        let pageNumberSize = getTextSize(text: pageNumberText as String, font: pageNumberFont)

        let centerX = footerRect.size.width/2 - textSize.width/2
        let centerY = footerRect.origin.y + self.footerHeight/2 - textSize.height/2
        let attributes = [
            NSAttributedString.Key.font: footerFont,
            NSAttributedString.Key.foregroundColor: footerFontColor,
        ]
        
        footerText.draw(at: CGPoint(x: centerX, y: centerY), withAttributes: attributes)

        if showPagesOnFooter != .none {

            var smallX = CGFloat(0)
            switch showPagesOnFooter {
                case .left:
                    smallX = 50
                case .right:
                    smallX = footerRect.size.width - pageNumberSize.width - 50
                case .inside:
                    smallX = (pageIndex + 1) % 2 == 1 ? footerRect.width - pageNumberSize.width - 50 : 50
                case .outside:
                    smallX = (pageIndex + 1) % 2 == 0 ? footerRect.width - pageNumberSize.width - 50 : 50
                case .none:
                    break
            }

            let smallAttributes = [
                NSAttributedString.Key.font: pageNumberFont as Any,
                NSAttributedString.Key.foregroundColor: pageNumberFontColor,
            ]

            pageNumberText.draw(at: CGPoint(x: smallX, y: centerY), withAttributes: smallAttributes)
        }

        // Draw a horizontal line.
        let lineOffsetX: CGFloat = 20.0
        let context = UIGraphicsGetCurrentContext()
        context!.setStrokeColor(horizontalRuleColor.cgColor)
        context!.move(to: CGPoint(x: lineOffsetX, y: footerRect.origin.y))
        context!.addLine(to: CGPoint(x: footerRect.size.width - lineOffsetX, y: footerRect.origin.y))
        context!.strokePath()
    }
    

    func getTextSize(text: String, font: UIFont?, textAttributes: [NSAttributedString.Key: Any]! = nil) -> CGSize {
        let testLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.paperRect.size.width, height: footerHeight))
        if let attributes = textAttributes {
            testLabel.attributedText = NSAttributedString(string: text, attributes: attributes)
        }
        else {
            testLabel.text = text
            testLabel.font = font
        }
        
        testLabel.sizeToFit()
        
        return testLabel.frame.size
    }
    
}
