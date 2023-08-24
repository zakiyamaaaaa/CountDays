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
        controller.setSubject("お問い合わせ")
        controller.setToRecipients(["zwork.official.app@gmail.com"])
        controller.setMessageBody("これが本文", isHTML: false)
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

//            self.parent.isShowing = false
        }
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<MailView>) {
    }
}

//struct MailView_Previews: PreviewProvider {
//    static var previews: some View {
//        MailView()
//    }
//}
