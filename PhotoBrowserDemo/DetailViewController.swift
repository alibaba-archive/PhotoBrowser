//
//  DetailViewController.swift
//  PhotoBrowserDemo
//
//  Created by Suric on 2017/1/10.
//  Copyright © 2017年 Teambition. All rights reserved.
//

import UIKit

// KVO for fixing navigationBar bug
fileprivate let navigationBarHiddenKeyPath = "hidden"
fileprivate var navigationBarKVOContext = 0

class DetailViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.addObserver(self, forKeyPath: navigationBarHiddenKeyPath, options: [.new, .old], context: &navigationBarKVOContext)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.removeObserver(self, forKeyPath: navigationBarHiddenKeyPath, context: &navigationBarKVOContext)
    }
}

// MARK: - KVO for NavigationBar
extension DetailViewController {
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &navigationBarKVOContext else {
            return
        }
        
        if let hidden = change?[.newKey] as? Bool, keyPath == navigationBarHiddenKeyPath {
            if let vc = navigationController?.topViewController, vc == self && hidden {
                navigationController?.setNavigationBarHidden(false, animated: false)
            }
        }
    }
}
