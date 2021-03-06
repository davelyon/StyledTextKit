//
//  TextStyle.swift
//  StyledTextKit
//
//  Created by Ryan Nystrom on 12/12/17.
//  Copyright © 2017 Ryan Nystrom. All rights reserved.
//

import UIKit

public struct TextStyle: Hashable, Equatable {

    public let font: Font
    public let size: CGFloat
    public let attributes: [NSAttributedStringKey: Any]
    public let minSize: CGFloat
    public let maxSize: CGFloat
    public let scalingTextStyle: UIFont.TextStyle

    public init(
        font: Font = .system(.default),
        size: CGFloat = UIFont.systemFontSize,
        attributes: [NSAttributedStringKey: Any] = [:],
        minSize: CGFloat = 0,
        maxSize: CGFloat = .greatestFiniteMagnitude,
        scalingTextStyle: UIFont.TextStyle = .body
        ) {
        self.font = font
        self.size = size
        self.attributes = attributes
        self.minSize = minSize
        self.maxSize = maxSize
        self.scalingTextStyle = scalingTextStyle

        self._hashValue = font
            .combineHash(with: size)
            .combineHash(with: attributes.count)
            .combineHash(with: minSize)
            .combineHash(with: maxSize)
            .combineHash(with: scalingTextStyle)
    }

    public func font(contentSizeCategory: UIContentSizeCategory) -> UIFont {
        let calculatedSize: CGFloat

        if #available(iOS 11.0, *) {
            let metrics = UIFontMetrics(forTextStyle: scalingTextStyle)
            calculatedSize = metrics.scaledValue(for: size, compatibleWith: UITraitCollection(preferredContentSizeCategory: contentSizeCategory))
        } else {
            calculatedSize = size * contentSizeCategory.approximateScaleFactor(forTextStyle: scalingTextStyle)
        }

        let preferredSize = min(max(calculatedSize, minSize), maxSize)

        switch font {
        case .name(let name):
            guard let font = UIFont(name: name, size: preferredSize) else {
                print("WARNING: Font with name \"\(name)\" not found. Falling back to system font.")
                return UIFont.systemFont(ofSize: preferredSize)
            }
            return font
        case .descriptor(let descriptor): return UIFont(descriptor: descriptor, size: preferredSize)
        case .system(let system):
            switch system {
            case .default: return UIFont.systemFont(ofSize: preferredSize)
            case .bold: return UIFont.boldSystemFont(ofSize: preferredSize)
            case .italic: return UIFont.italicSystemFont(ofSize: preferredSize)
            case .weighted(let weight): return UIFont.systemFont(ofSize: preferredSize, weight: weight)
            case .monospaced(let weight): return UIFont.monospacedDigitSystemFont(ofSize: preferredSize, weight: weight)
            }
        }
    }

    // MARK: Hashable

    internal let _hashValue: Int
    public var hashValue: Int {
        return _hashValue
    }

    // MARK: Equatable

    public static func ==(lhs: TextStyle, rhs: TextStyle) -> Bool {
        return lhs.size == rhs.size
            && lhs.minSize == rhs.minSize
            && rhs.maxSize == rhs.maxSize
            && lhs.font == rhs.font
            && lhs.scalingTextStyle == rhs.scalingTextStyle
            && NSDictionary(dictionary: lhs.attributes).isEqual(to: rhs.attributes)
    }

}
