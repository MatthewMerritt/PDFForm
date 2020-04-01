//
//  PDFViewController.swift
//  HTMLWithImagesToPDF
//
//  Created by Matthew Merritt on 3/30/20.
//  Copyright © 2020 nyg. All rights reserved.
//

import UIKit
import WebKit

public class PDFViewController: UIViewController, WKNavigationDelegate {

    /// Readability for completion handlers used
    public typealias CompletionHandler = (_ data: Data) -> Void
    public typealias CompletionHandlerWithWebView = (_ webView: WKWebView) -> Void
    public typealias CompletionHandlerWithURL = (_ url: URL?) -> Void

    /// The rendering WKWebView used to generate HTML -> PDF
    private var previewWebView: WKWebView = WKWebView()

    /// The completionHandlers used
    private var completion: CompletionHandler?
    private var completionWithWebView: CompletionHandlerWithWebView?
    private var completionWithURL: CompletionHandlerWithURL?

    public var pdfTitle: String = "PDF Title"
    public var pdfFooter: String = "PDF Footer"
    public var pdfShowPagesOnFooter: PDFPrintPageRenderer.PagesOnFooterSide = .none

    /// Hackie webView loading since we are performing multiple loads between generating HTML and PDF
    private var done = false

    /// Use this to generate and display PDF Data and return the created WKWebView.
    /// - Parameters:
    ///   - from: the string path of the HTML Template file
    ///   - completionHandlerWithWebView: the completion handler to recieve the WKWebView
    public func getPreviewWebView(from: String, completionHandlerWithWebView: CompletionHandlerWithWebView? = nil) {
        done = false

        completion = nil
        completionWithURL = nil

        completionWithWebView = completionHandlerWithWebView

        previewWebView.navigationDelegate = self
        previewWebView.loadHTMLString(from, baseURL: Bundle.main.bundleURL)
    }

    /// Use this to generate and return PDF Data from an HTML Template.
    /// - Parameters:
    ///   - from: the string path of the HTML Template file
    ///   - completionHandler: the completion handler to recieve the PDF Data
    public func getPDFData(from: String, completionHandler: CompletionHandler? = nil) {
        done = false

        completionWithWebView = nil
        completionWithURL = nil

        completion = completionHandler

        previewWebView.navigationDelegate = self
        previewWebView.loadHTMLString(from, baseURL: Bundle.main.bundleURL)
    }

    /// Use this to generate and return the URL path to the PDF from an HTML Template.
    /// - Parameters:
    ///   - from: the string path of the HTML Template file
    ///   - completionHandler: the completion handler to recieve the URL
    public func getPDFURL(from: String, completionHandler: CompletionHandlerWithURL? = nil) {

        done = false

        completionWithWebView = nil
        completion = nil

        completionWithURL = completionHandler

        previewWebView.navigationDelegate = self
        previewWebView.loadHTMLString(from, baseURL: Bundle.main.bundleURL)
    }


    /// Use this to generate and print PDF from an HTML Template.
    /// - Parameters:
    ///   - from: the string path of the HTML Template file
    ///   - withTitle: the title to display
    public func printPDF(from: String, withTitle: String) {

        done = false

        completionWithWebView = nil
        completionWithURL = nil
        completion = nil

        title = withTitle
        previewWebView.navigationDelegate = self
        previewWebView.loadHTMLString(from, baseURL: Bundle.main.bundleURL)

    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        if !done {
            // We are now done, maybe a better way to do this so we don't create a loop
            done = true

            // Send the URL to the file that has the generated PDF
            guard completionWithURL == nil else {
                let url = PDF.createPDFFileAndReturnPath(using: self.previewWebView.viewPrintFormatter(), fileName: "PDFInvoice.pdf", pdfTitle: self.pdfTitle, pdfFooter: self.pdfFooter, showPagesOnFooter: self.pdfShowPagesOnFooter)
                completionWithURL?(url)
                return
            }

            // Generate the PDF Data and load it into the previewWebView for use
            let wkPDFData = PDF.generate(using: self.previewWebView.viewPrintFormatter(), pdfTitle: pdfTitle, pdfFooter: pdfFooter, showPagesOnFooter: pdfShowPagesOnFooter)
            self.loadIntoPreviewWKWebView(wkPDFData)

            // Send the WKWebView with the generated PDF Data to the completionHandler
            guard completionWithWebView == nil else {
                
               completionWithWebView?(webView)
                return
            }

            // Send the generated PDF Data to the completionHandler
            guard completion == nil else {
                completion?(wkPDFData)
                return
            }

            // Default case does not have a completionHandler defined so we are printing the PDF
            let printController = UIPrintInteractionController.shared

            let printInfo = UIPrintInfo(dictionary:nil)
            printInfo.outputType = UIPrintInfo.OutputType.general
            printController.showsNumberOfCopies = false
            printInfo.jobName = "PDF ID: " + self.title!
            printController.printInfo = printInfo

            printController.printFormatter = self.previewWebView.viewPrintFormatter()

            printController.present(animated: true) { (controller, completed, error) in
                print(error ?? "Print controller presented.")
            }

        }
    }

    // MARK: Helpers

    /// This loads PDF Data into a WKWebView.
    /// - Parameter data: the PDF Data to use
    private func loadIntoPreviewWKWebView(_ data: Data) {
        previewWebView.load(data, mimeType: "application/pdf", characterEncodingName: "utf-8", baseURL: Bundle.main.bundleURL)
    }

    /// Get a UIPrintFormatter for a WKWebView.
    /// - Returns: an instance of UIPrintFormatter
    private func previewPrintFormatter() -> UIPrintFormatter {
        return previewWebView.viewPrintFormatter()
    }
}
