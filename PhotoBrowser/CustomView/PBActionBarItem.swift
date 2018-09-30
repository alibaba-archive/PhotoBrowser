//
//  PBActionBarItem.swift
//  PhotoBrowser
//
//  Created by WangWei on 16/5/20.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import Foundation

public typealias BarActionClosure = (PhotoBrowser, PBActionBarItem) -> Void

open class PBActionBarItem: NSObject {
    open var barButtonItem: UIBarButtonItem!
    open var action: BarActionClosure?
    open weak var photoBrowser: PhotoBrowser?

    public init(title: String?, style: UIBarButtonItem.Style, action: BarActionClosure? = nil) {
        super.init()
        self.action = action
        barButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(PBActionBarItem.triggerAction))
    }

    public init(image: UIImage?, style: UIBarButtonItem.Style, action: BarActionClosure? = nil) {
        super.init()
        self.action = action
        barButtonItem = UIBarButtonItem(image: image, style: style, target: self, action: #selector(PBActionBarItem.triggerAction))
    }

    public init(barButtonItem: UIBarButtonItem, action: BarActionClosure? = nil) {
        super.init()
        self.barButtonItem = barButtonItem
        self.action = action
    }

    @objc func triggerAction() {
        guard let photoBrowser = photoBrowser, let action = action else {
            return
        }
        action(photoBrowser, self)
    }
}

public extension PhotoBrowser {
    func addActionBarItem(title: String?, style: UIBarButtonItem.Style, action: BarActionClosure?) {
        let barItem = PBActionBarItem(title: title, style: style, action: action)
        barItem.photoBrowser = self
        actionItems.append(barItem)
    }

    func insert(_ actionBarItem: PBActionBarItem, at index: Int) {
        let barItem = actionBarItem
        barItem.photoBrowser = self
        actionItems.insert(barItem, at: index)
    }

    func removeAllToolbarItems() {
        actionItems.removeAll()
    }
}
