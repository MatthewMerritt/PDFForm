//
//  ViewController.swift
//  PDFForm
//
//  Created by MatthewMerritt on 03/31/2020.
//  Copyright (c) 2020 MatthewMerritt. All rights reserved.
//

import UIKit
import PDFForm

class ViewController: UIViewController {

    var previewController: PDFViewController = PDFViewController()

    let html = HTML()
    let items: [[String: String]] = [
        [ "item": "Egg's", "price": "2.50"],
        [ "item": "Milk", "price": "1.50"],
        [ "item": "Bacon", "price": "4.79"],
        [ "item": "Egg's", "price": "2.50"],
        [ "item": "Milk", "price": "1.50"],
        [ "item": "Bacon", "price": "4.79"],
        [ "item": "Egg's", "price": "2.50"],
        [ "item": "Milk", "price": "1.50"],
        [ "item": "Bacon", "price": "4.79"],
        [ "item": "Egg's", "price": "2.50"],
        [ "item": "Milk", "price": "1.50"],
        [ "item": "Bacon", "price": "4.79"],
    ]

    lazy var invoiceHTML = {
        return html.getHTML(from: "exercise")
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        html.dataSource = self

        previewController.pdfTitle = "This is a PDF Title"
        previewController.pdfShowPagesOnFooter = .inside


    }

}

extension ViewController: HTMLDataSource {

    var templateItems: [HTML.TemplateItem] {
        get {

            let prices = items.map { Double($0["price"]!)! }.reduce(0, +)


            return  [
                HTML.TemplateItem(templateString: "#EXERCISE_NAME#", templateReplacement: "New Cardio"),
                HTML.TemplateItem(templateString: "#EXERCISE_TYPE#", templateReplacement: "Cardio"),
                HTML.TemplateItem(templateString: "#EXERCISE_REPS#", templateReplacement: "3"),
                HTML.TemplateItem(templateString: "#EXERCISE_DATE#", templateReplacement: "03/31/20"),
                HTML.TemplateItem(templateString: "#TOTAL_AMOUNT#", templateReplacement: "$\(prices)"),
                HTML.TemplateItem(templateString: "#EXERCISE_IMAGE#", templateReplacement: (UIImage(named: "Rylee Soccer")!.pngData()?.base64EncodedString())!)
            ]

        }
    }


    func title() -> String {
        return "Title Return"
    }

    func numberOfRows() -> Int {
        return items.count
    }

    func htmlForRowHeader() -> String {
        var rowHeader = HTML.loadTemplate(from: "row_header")
        rowHeader.replace(templateString: "#ITEM_DESC#", with: "Item Name")
        rowHeader.replace(templateString: "#PRICE#", with: "Item Price")
        return rowHeader
    }

    func htmlForRowFooter() -> String {
        var rowHeader = HTML.loadTemplate(from: "row_header")
        rowHeader.replace(templateString: "#ITEM_DESC#", with: "")
        rowHeader.replace(templateString: "#PRICE#", with: "Footer Price")
        return rowHeader
    }

    func html(for item: Int) -> String {

        var itemHTMLContent: String = ""

        // Determine the proper template file.
        if item != items.count - 1 {
            itemHTMLContent = HTML.loadTemplate(from: "single_item")
        }
        else {
            itemHTMLContent = HTML.loadTemplate(from: "last_item")
        }

        let description = items[item]["item"]!
        let formattedPrice = items[item]["price"]!

        itemHTMLContent.replace(templateString: "#ITEM_DESC#", with: description)
        itemHTMLContent.replace(templateString: "#PRICE#", with: formattedPrice)

        return itemHTMLContent
    }

}

// MARK: - IBActions

extension ViewController {

    @IBAction func getPDFData(_ sender: UIBarButtonItem) {
        // Working: Just get pdfData

        previewController.getPDFData(from: invoiceHTML, completionHandler: { data in

            let title = "PDF Data"

            let activityViewController = UIActivityViewController(activityItems: [data, title], applicationActivities: nil)

            self.view.window?.rootViewController?.present(activityViewController, animated: true, completion: nil)

        })
    }

    @IBAction func printPDFData(_ sender: UIBarButtonItem) {

        previewController.printPDF(from: invoiceHTML, withTitle: "This is the title")
    }

    @IBAction func getPDFURL(_ sender: UIBarButtonItem) {

        previewController.getPDFURL(from: invoiceHTML) { url in

            guard let url = url else {
                print("Bad URL!")
                return
            }

            let activityViewController = UIActivityViewController(activityItems: [url, "Title"], applicationActivities: nil)

            self.view.window?.rootViewController?.present(activityViewController, animated: true, completion: nil)

        }

    }

    @IBAction func getPreviewWebView(_ sender: UIBarButtonItem) {

        previewController.getPreviewWebView(from: invoiceHTML) { webView in
            webView.frame = self.view.frame
            webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            let vc = UIViewController()
            vc.view = webView

            self.navigationController?.pushViewController(vc, animated: true)
        }

    }
}
