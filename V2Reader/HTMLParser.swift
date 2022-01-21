//
//  HTMLParser.swift
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
    if tag == "br /" {
        return AttributedString("\(prev)\n") + parseHTML(html: String(rest))
    }
    let tagName = tag.split(separator: " ", omittingEmptySubsequences: false)[0]
    let closing = rest.range(of: "</\(tagName)>")
    if closing == nil {
        return AttributedString("\(prev)<\(tag)>") + parseHTML(html: String(rest))
    }
    let content = rest[rest.startIndex..<closing!.lowerBound]
    rest = rest[closing!.upperBound..<rest.endIndex]
    switch tagName {
    case "p":
        return AttributedString(prev.isEmpty ? "" : "\(prev)\n") + parseHTML(html: String(content)) + AttributedString("\n") + parseHTML(html: String(rest))
    case "div":
        return AttributedString(prev.isEmpty ? "" : "\(prev)\n") + parseHTML(html: String(content)) + AttributedString("\n") + parseHTML(html: String(rest))
    case "h1":
        var title = parseHTML(html: String(content))
        title.font = .title
        title.inlinePresentationIntent = .stronglyEmphasized
        return AttributedString(prev.isEmpty ? "" : "\(prev)\n") + title + AttributedString("\n") + parseHTML(html: String(rest))
    case "h2":
        var title = parseHTML(html: String(content))
        title.font = .title2
        title.inlinePresentationIntent = .stronglyEmphasized
        return AttributedString(prev.isEmpty ? "" : "\(prev)\n") + title + AttributedString("\n") + parseHTML(html: String(rest))
    case "h3":
        var title = parseHTML(html: String(content))
        title.font = .title3
        title.inlinePresentationIntent = .stronglyEmphasized
        return AttributedString(prev.isEmpty ? "" : "\(prev)\n") + title + AttributedString("\n") + parseHTML(html: String(rest))
    case "strong":
        var text = parseHTML(html: String(content))
        text.inlinePresentationIntent = .stronglyEmphasized
        return AttributedString(prev) + text + parseHTML(html: String(rest))
    case "ul":
        return AttributedString(prev) + parseList(list: String(content)) + parseHTML(html: String(rest))
    default:
        return AttributedString("\(prev)<\(tag)>") + parseHTML(html: "\(content)</\(tagName)>\(rest)")
    }
}

func parseList(list: String) -> AttributedString {
    let listPref = "•\t"
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
    let content = rest[rest.startIndex..<firstClosing!.lowerBound]
    rest = rest[firstClosing!.upperBound..<rest.endIndex]
    var result = AttributedString("\(prev)\(listPref)\(content)")
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
        let content = rest[rest.startIndex..<nextClosing!.lowerBound]
        rest = rest[nextClosing!.upperBound..<rest.endIndex]
        result += AttributedString("\(prev)\(listSeparator)\(listPref)\(content)")
    }
    return result
}
