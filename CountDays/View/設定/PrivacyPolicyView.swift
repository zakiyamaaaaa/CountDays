//
//  PrivacyPolicyView.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/08/22.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HeaderView(title: "プライバシーポリシー")
                
            ScrollView(showsIndicators: false) {
                Text("""
        このプライバシーポリシー（以下、「本ポリシー」といいます。）は、[アプリ名]（以下、「当社」といいます。）が提供する[アプリ名]アプリケーション（以下、「アプリ」といいます。）におけるユーザーの個人情報の収集、使用、共有に関する方針を定めるものです。アプリをご利用いただく際には、本ポリシーに同意いただいたものとみなします。

        1. 収集する情報
           アプリを利用する際、当社は以下の情報を収集することがあります。
           - [収集する情報の例]

        2. 情報の使用
           収集した情報は、以下の目的で使用されることがあります。
           - [情報の使用目的の例]

        3. 情報の共有
           収集した情報は、法的要件に従った場合や以下のケースを除いて、第三者と共有されることはありません。
           - [情報の共有ケースの例]

        4. ユーザーの権利
           ユーザーは、自身の個人情報へのアクセス、修正、削除を要求する権利を有します。詳細は[アプリ名]アプリ内の設定で確認してください。

        5. セキュリティ
           当社は、適切なセキュリティ対策を講じ、ユーザーの個人情報の保護に努めます。

        6. クッキーとトラッキング技術
           アプリ内でクッキーなどのトラッキング技術を使用する場合、その詳細については[アプリ名]アプリ内でご確認ください。

        7. 変更通知
           本ポリシーは変更される場合があり、変更後のポリシーは[アプリ名]アプリ内で通知されます。

        8. 連絡先
           プライバシーポリシーに関するお問い合わせは、以下の連絡先までご連絡ください。
           [連絡先情報]

        以上

    """)
                .multilineTextAlignment(.leading)
            }
            
            .padding(20)
            .statusBarHidden()
            
        }
        .background(ColorUtility.backgroundary)
        .foregroundColor(.white)
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView()
    }
}
