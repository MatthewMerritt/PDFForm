//
//  PDF.swift
//  HTMLWithImagesToPDF
//
//  Created by user on 20.09.17.
//  Copyright © 2017 nyg. All rights reserved.
//
//  TODO: Make these properties
//          - footerPagesText
//          - showDateOnFooter
//          - footerDateText

import UIKit

public class PDF {

    /// Generates a PDF using the given print formatter and saves it to the user's document directory.
    /// - Parameters:
    ///   - printFormatter: The print formatter used to generate the PDF
    ///   - fileName: the HTML Template file
    /// - Returns: the URL to the gerenated PDF File
    public class func createPDFFileAndReturnPath(using printFormatter: UIPrintFormatter, fileName: String, pdfTitle: String, pdfFooter: String, showPagesOnFooter: PDFPrintPageRenderer.PagesOnFooterSide) -> URL? {

        let renderer = PDFPrintPageRenderer()
        renderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        renderer.headerText = pdfTitle
        renderer.footerText = pdfFooter
        renderer.showPagesOnFooter = showPagesOnFooter

        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
        renderer.setValue(page, forKey: "paperRect")
        renderer.setValue(page, forKey: "printableRect")

        let options: [CFString: Any] = [
            kCGPDFOutlineTitle:         pdfTitle,
            kCGPDFContextTitle:         pdfTitle,
            kCGPDFContextAuthor:        "Exercise",
            kCGPDFContextCreator:       "MerrittWare",
            kCGPDFContextSubject:       "Exercise Report",
            kCGPDFContextKeywords:      "",
//            kCGPDFContextUserPassword:  "Password",
//            kCGPDFContextOwnerPassword: "1234",
        ]

        UIGraphicsBeginPDFContextToFile(outputURL(with: fileName).absoluteString.replacingOccurrences(of: "file://", with: ""), CGRect.zero, options)

        for i in 0..<renderer.numberOfPages {
            UIGraphicsBeginPDFPageWithInfo(page, nil)
            renderer.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }

        UIGraphicsEndPDFContext()

        return outputURL(with: fileName)
    }

    /// Generates a PDF using the given print formatter and saves it to the user's document directory.
    /// - Parameter printFormatter: The print formatter used to generate the PDF
    /// - returns: The generated PDF
    public class func generate(using printFormatter: UIPrintFormatter, pdfTitle: String, pdfFooter: String, showPagesOnFooter: PDFPrintPageRenderer.PagesOnFooterSide) -> Data {

        // assign the print formatter to the print page renderer
        let renderer = PDFPrintPageRenderer()
        renderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        renderer.headerText = pdfTitle
        renderer.footerText = pdfFooter
        renderer.showPagesOnFooter = showPagesOnFooter

        // assign paperRect and printableRect values
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
        renderer.setValue(page, forKey: "paperRect")
        renderer.setValue(page, forKey: "printableRect")

        // create pdf context and draw each page
        let pdfData = NSMutableData()

        UIGraphicsBeginPDFContextToData(pdfData, page, nil)

        for i in 0..<renderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            renderer.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }

        UIGraphicsEndPDFContext()

        //  Return the generated PDF Data
        return pdfData as Data
    }

    /// Generated outputURL used for creating no repeating filenames
    private class var outputURL: URL {
        let generatedFileName = "generated-\(Int(Date().timeIntervalSince1970))"

        return outputURL(with: generatedFileName)
    }

    /// Use this function to create an outputURL using a supplied file name
    /// - Parameter fileName: the string file name to be used
    /// - Returns: the generated URL
    private class func outputURL(with fileName: String) -> URL {

        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            else { fatalError("Error getting user's document directory.") }

        let url = directory.appendingPathComponent(fileName)
        return url
    }

}
