//
//  Skitch.swift
//  PhotoBrowser
//
//  Created by bruce on 2017/4/13.
//  Copyright © 2017年 Teambition. All rights reserved.
//

import Foundation

public struct Point {
    var x: CGFloat = 0
    var y: CGFloat = 0
    var width: CGFloat = 0
    var height: CGFloat = 0

    init(pointJSON: [String: Any]) {
        if let x = pointJSON["x"] as? Double, let y = pointJSON["y"] as? Double {
            self.x = CGFloat(x)
            self.y = CGFloat(y)
        } else if let x = pointJSON["x"] as? Int, let y = pointJSON["y"] as? Int {
            self.x = CGFloat(x)
            self.y = CGFloat(y)
        }
        if let width = pointJSON["width"] as? Double, let height = pointJSON["height"] as? Double {
            self.width = CGFloat(width)
            self.height = CGFloat(height)
        } else if let width = pointJSON["width"] as? Int, let height = pointJSON["height"] as? Int {
            self.width = CGFloat(width)
            self.height = CGFloat(height)
        }
    }

    init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }

    init() {
        self.x = 0
        self.y = 0
    }
}

public enum SkitchType: String {
    case point
    case rectangle
}

public struct Skitch {
    public var id: String!
    public var number: Int!
    public var point: Point!
    public var type: SkitchType = .point

    init?(skitchJSON: [String: Any]) {
        id = skitchJSON["_id"] as? String ?? ""
        number = skitchJSON["num"] as? Int ?? 0
        let pointJSON = skitchJSON["coordinate"] as? [String: Any] ?? [:]
        point = Point(pointJSON: pointJSON)

        if let type = skitchJSON["type"] as? String, let skitchType = SkitchType(rawValue: type) {
            self.type = skitchType
        } else {
            return nil
        }
    }
}
