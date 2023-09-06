//
//  Extension.swift
//  CountDays
//
//  Created by shoichiyamazaki on 2023/09/06.
//

import Foundation
import UIKit

extension UIImage {
    func resize(size: CGSize = CGSize(width: 200, height: 200)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
