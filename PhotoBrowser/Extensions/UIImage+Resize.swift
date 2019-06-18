//
//  UIImage+Resize.swift
//  PhotoBrowser
//
//  Created by WangWei on 2019/6/18.
//  Copyright © 2019 Teambition. All rights reserved.
//

import UIKit

extension UIImage {
    func resize(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        draw(in: CGRect(origin: .zero, size: size))
        guard let cgImage = context?.makeImage() else {
            return self
        }
        return UIImage(cgImage: cgImage)
    }
}
