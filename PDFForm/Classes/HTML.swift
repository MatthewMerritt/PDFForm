//
//  HTML.swift
//  HTMLWithImagesToPDF
//
//  Created by user on 20.09.17.
//  Copyright © 2017 nyg. All rights reserved.
//

import UIKit

public protocol HTMLDataSource {

    func title() -> String

    func htmlForRowHeader() -> String
    func htmlForRowFooter() -> String

    func numberOfRows() -> Int
    func html(for item: Int) -> String

    var templateItems: [HTML.TemplateItem] { get }
}

public extension HTMLDataSource {
    var templateItems: [HTML.TemplateItem] { get { return [] } }
}

public class HTML {

    public struct TemplateItem {
        public var templateString = ""
        public var templateReplacement  = ""

        public init(templateString: String, templateReplacement: String) {
            self.templateString = templateString
            self.templateReplacement = templateReplacement
        }
    }

    public var dataSource: HTMLDataSource?

    public init() { }

    /// Reads the given HTML file and replaces `{{ABSOLUTE_PATH}}` and `{{BASE64_STRING}}` with proper values.
    /// - Parameter fileName: the name of the HTML file
    /// - Returns: The transformed HTML code
    public func getHTML(from fileName: String) -> String {

        guard let htmlFile = Bundle.main.url(forResource: fileName, withExtension: "html") else { fatalError("Error locating HTML file.") }

        guard var htmlContent = try? String(contentsOf: htmlFile) else { fatalError("Error getting HTML file content.") }

        var allItems = ""

        guard dataSource != nil else { return "" }

        let rowHeader = dataSource!.htmlForRowHeader()
        let rowFooter = dataSource!.htmlForRowFooter()

        for i in 0..<dataSource!.numberOfRows() {

            // Add the item's HTML code to the general items string.
            allItems += dataSource!.html(for: i) //itemHTMLContent
        }

        // Set the items.

        dataSource!.templateItems.forEach {
            htmlContent.replace(templateString: $0.templateString, with: $0.templateReplacement)
        }

        return htmlContent
            .replacing(templateString: "#ROW_HEADER#", with: rowHeader)
            .replacing(templateString: "#ROW_FOOTER#", with: rowFooter)
            .replacing(templateString: "#ITEMS#", with: allItems)
    }

    public static func loadTemplate(from fileName: String) -> String {
        let pathToHTMLTemplate = Bundle.main.path(forResource: fileName, ofType: "html")

        return try! String(contentsOfFile: pathToHTMLTemplate!)
    }

}


public extension String {

    mutating func replace(templateString: String, with replacement: String) {
        self = self.replacingOccurrences(of: templateString, with: replacement)
    }

    func replacing<TemplateString, Replacement>(templateString: TemplateString, with replacement: Replacement) -> String where TemplateString : StringProtocol, Replacement : StringProtocol {

        return replacingOccurrences(of: templateString, with: replacement)
    }
}
