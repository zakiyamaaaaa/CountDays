//
//  MailView.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/08/22.
//

import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
//    @Binding var isShowing: Bool

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> UIViewController {
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = context.coordinator
        controller.toolbar.tintColor = .black
        controller.navigationBar.tintColor = .black
        controller.setSubject("お問い合わせ")
        controller.setToRecipients(["zwork.official.app@gmail.com"])
        controller.setMessageBody("ここに問い合わせ内容をお知らせください。バグに関連する場合は、①バグの内容②OSのバージョン③機種を記載いただけると素早い対応が可能です", isHTML: false)
        
        return controller
    }

    func makeCoordinator() -> MailView.Coordinator {
        return Coordinator(parent: self)
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {
        let parent: MailView
        init(parent: MailView) {
            self.parent = parent
            
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            // 終了時の処理あれこれ
            controller.toolbar.tintColor = .black
            controller.navigationBar.tintColor = .black
            
//            self.parent.isShowing = false
        }
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<MailView>) {
        uiViewController.editButtonItem.tintColor = .black
    }
}

//struct MailView_Previews: PreviewProvider {
//    static var previews: some View {
//        MailView()
//    }
//}
