//
//  Extension.swift
//  CountDays
//
//  Created by shoichiyamazaki on 2023/09/06.
//

import Foundation
import SwiftUI
import UIKit

/// 画像のリサイズ
extension UIImage {
    func resize(size: CGSize = CGSize(width: 200, height: 200)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

extension View {
    
    var closableMark: some View {
        RoundedRectangle(cornerSize: CGSize(width: 20, height: 10), style: .continuous)
            .frame(width: 50, height: 10)
            .foregroundStyle(.gray)
    }
    
    func widgetFrame(alignment: Alignment = .center) -> some View {
        frame(width: WidgetConfig.small.size.width, height: WidgetConfig.small.size.height, alignment: alignment)
    }
}

/// スクリーンショット
//extension View {
//    func snapshot() -> UIImage {
//        let controller = UIHostingController(rootView: self)
//        let view = controller.view
//        
//        let targetSize = controller.view.intrinsicContentSize
//        view?.bounds = CGRect(origin: .zero, size: targetSize)
//        view?.backgroundColor = .clear
//        
//        let renderer = UIGraphicsImageRenderer(size: targetSize)
//        
//        return renderer.image { _ in
//            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
////            view?.resizableSnapshotView(from: controller.view.bounds, afterScreenUpdates: true, withCapInsets: .zero)
//        }
//    }
//}


// App icon
extension Bundle {
    public var icon: UIImage? {
        guard let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
              let iconFileName = iconFiles.last
        else { return nil }
        return UIImage(named: iconFileName)
    }
}
