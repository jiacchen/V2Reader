//
//  Util.swift
//  V2Reader
//
//  Created by Jiachen Chen on 1/20/22.
//

import Foundation

func parseHTML(html: String) -> AttributedString {
    let tagLeft = html.firstIndex(of: "<")
    if tagLeft == nil {
        return AttributedString(html)
    }
    let prev = html[html.startIndex..<tagLeft!]
    var rest = html[tagLeft!..<html.endIndex]
    let tagRight = rest.firstIndex(of: ">")
    if tagRight == nil {
        return AttributedString(html)
    }
    var tag = rest[rest.startIndex..<tagRight!]
    tag.removeFirst()
    rest = rest[tagRight!..<rest.endIndex]
    rest.removeFirst()
    let tagName = tag.split(separator: " ", omittingEmptySubsequences: false)[0]
    if tagName == "br" || tag == "br/" {
        return AttributedString("\(prev)\n") + parseHTML(html: String(rest))
    } else if tagName == "img" {
        let src = tag.range(of: "src=\"")
        if src == nil {
            return AttributedString(prev) + parseHTML(html: String(rest))
        }
        var link = tag[src!.upperBound..<tag.endIndex]
        let linkEnd = link.range(of: "\"")
        if linkEnd == nil {
            return AttributedString(prev) + parseHTML(html: String(rest))
        }
        link = link[link.startIndex..<linkEnd!.lowerBound]
        if link[link.startIndex..<link.index(link.startIndex, offsetBy: 5)] != "https" {
            var image = AttributedString(link)
            if let alt = tag.range(of: "alt=\"") {
                var imageName = tag[alt.upperBound..<tag.endIndex]
                if let altEnd = imageName.range(of: "\"") {
                    imageName = imageName[imageName.startIndex..<altEnd.lowerBound]
                    image = AttributedString(imageName)
                }
            }
            image.link = URL(string: String(link))
            return AttributedString(prev) + image + parseHTML(html: String(rest))
        }
        var image = AttributedString("<img>")
        image.imageURL = URL(string: String(link))
        return AttributedString(prev) + image + parseHTML(html: String(rest))
    }
    let closing = rest.range(of: "</\(tagName)>")
    if closing == nil {
        return AttributedString("\(prev)<\(tag)>") + parseHTML(html: String(rest))
    }
    let content = rest[rest.startIndex..<closing!.lowerBound]
    rest = rest[closing!.upperBound..<rest.endIndex]
    switch tagName {
    case "p":
        return AttributedString(prev) + parseHTML(html: String(content)) + parseHTML(html: String(rest))
    case "div":
        return AttributedString(prev) + parseHTML(html: String(content)) + parseHTML(html: String(rest))
    case "h1":
        var title = parseHTML(html: String(content))
        title.font = .title
        title.inlinePresentationIntent = .stronglyEmphasized
        return AttributedString(prev) + title + parseHTML(html: String(rest))
    case "h2":
        var title = parseHTML(html: String(content))
        title.font = .title2
//        title.swiftUI.underlineStyle = .init(pattern: .solid, color: .secondary)
        title.inlinePresentationIntent = .stronglyEmphasized
        return AttributedString(prev) + title + parseHTML(html: String(rest))
    case "h3":
        var title = parseHTML(html: String(content))
        title.font = .title3
        title.inlinePresentationIntent = .stronglyEmphasized
        return AttributedString(prev) + title + parseHTML(html: String(rest))
    case "strong":
        print(content)
        var text = parseHTML(html: String(content))
        text.inlinePresentationIntent = .stronglyEmphasized
        return AttributedString(prev) + text + parseHTML(html: String(rest))
    case "ul":
        return AttributedString(prev) + parseList(list: String(content)) + parseHTML(html: String(rest))
    case "a":
        let href = tag.range(of: "href=\"")
        if href == nil {
            return AttributedString(prev) + parseHTML(html: String(content)) + parseHTML(html: String(rest))
        }
        var link = tag[href!.upperBound..<tag.endIndex]
        let linkEnd = link.range(of: "\"")
        if linkEnd == nil {
            return AttributedString(prev) + parseHTML(html: String(content)) + parseHTML(html: String(rest))
        }
        link = link[link.startIndex..<linkEnd!.lowerBound]
        var text = parseHTML(html: String(content))
        text.link = URL(string: String(link))
        return AttributedString(prev) + text + parseHTML(html: String(rest))
    case "pre":
        var pre = parseHTML(html: String(content))
        pre.inlinePresentationIntent = .code
        return AttributedString(prev) + pre + parseHTML(html: String(rest))
    case "code":
        var code = parseHTML(html: String(content))
        code.inlinePresentationIntent = .code
        return AttributedString(prev) + code + parseHTML(html: String(rest))
    case "blockquote":
        var blockquote = parseHTML(html: String(content))
        blockquote.inlinePresentationIntent = .blockHTML
        return AttributedString(prev) + blockquote + parseHTML(html: String(rest))
    case "table":
        let table = parseTable(table: String(content))
        return AttributedString(prev) + table + parseHTML(html: String(rest))
    default:
        return AttributedString("\(prev)<\(tag)>") + parseHTML(html: "\(content)</\(tagName)>\(rest)")
    }
}

func parseList(list: String) -> AttributedString {
    let listPref = "• "
    let listSeparator = "\u{2029}"
    let firstTag = list.range(of: "<li>")
    if firstTag == nil {
        return parseHTML(html: list)
    }
    let prev = list[list.startIndex..<firstTag!.lowerBound]
    var rest = list[firstTag!.upperBound..<list.endIndex]
    let firstClosing = rest.range(of: "</li>")
    if firstClosing == nil {
        return parseHTML(html: "\(prev)<li>\(rest)")
    }
    var content = rest[rest.startIndex..<firstClosing!.lowerBound]
    if content.first == "\n" {
        content.removeFirst()
    }
    rest = rest[firstClosing!.upperBound..<rest.endIndex]
    var result = parseHTML(html: "\(prev)\(listPref)\(content)")
    while !rest.isEmpty {
        let nextTag = rest.range(of: "<li>")
        if nextTag == nil {
            result += parseHTML(html: String(rest))
            return result
        }
        let prev = rest[rest.startIndex..<nextTag!.lowerBound]
        rest = rest[nextTag!.upperBound..<rest.endIndex]
        let nextClosing = rest.range(of: "</li>")
        if nextClosing == nil {
            result += parseHTML(html: "\(prev)<li>\(rest)")
            return result
        }
        var content = rest[rest.startIndex..<nextClosing!.lowerBound]
        if content.first == "\n" {
            content.removeFirst()
        }
        rest = rest[nextClosing!.upperBound..<rest.endIndex]
        result += parseHTML(html: "\(prev)\(listSeparator)\(listPref)\(content)")
    }
    return result
}

func parseTable(table: String) -> AttributedString {
    return AttributedString()
}

func processAttributedString(attributedString: AttributedString) -> [AttributedString] {
    var parts: [AttributedString] = []
    var rest = attributedString[attributedString.startIndex..<attributedString.endIndex]
    while true {
        if let image = rest.range(of: "<img>") {
            var part = rest[rest.startIndex..<image.lowerBound]
            part.imageURL = rest[image].imageURL
            parts.append(AttributedString(part))
            rest = rest[image.upperBound..<rest.endIndex]
        } else {
            parts.append(AttributedString(rest))
            break
        }
    }
    return parts
}
