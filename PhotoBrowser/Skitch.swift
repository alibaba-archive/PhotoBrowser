//
//  Skitch.swift
//  PhotoBrowser
//
//  Created by bruce on 2017/4/13.
//  Copyright © 2017年 Teambition. All rights reserved.
//

import Foundation

public struct Point {
    var x: CGFloat!
    var y: CGFloat!
    var width: CGFloat = 0
    var height: CGFloat = 0

    init(pointJSON: [String: Any]) {
        self.width = 0
        self.height = 0
        if let x = pointJSON["x"] as? Double, let y = pointJSON["y"] as? Double {
            self.x = CGFloat(x)
            self.y = CGFloat(y)
        }
        if let width = pointJSON["width"] as? Double, let height = pointJSON["height"] as? Double {
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
        if let skitchType = skitchJSON["type"] as? String, skitchType == "point" {
            self.type = .point
        } else if let skitchType = skitchJSON["type"] as? String, skitchType == "rectangle" {
            self.type = .rectangle
        } else {
            return nil
        }

        self.id = skitchJSON["_id"] as? String ?? ""
        self.number = skitchJSON["num"] as? Int ?? 0
        let pointJSON = skitchJSON["coordinate"] as? [String: Any] ?? [:]
        self.point = Point(pointJSON: pointJSON)
    }
}
