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
    このプライバシーポリシー（以下、「本ポリシー」といいます。）は、zwork（以下、「当社」といいます。）が提供するアプリケーション（以下、「アプリ」といいます。）におけるユーザーの個人情報の収集、使用、共有に関する方針を定めるものです。アプリをご利用いただく際には、本ポリシーに同意いただいたものとみなします。

    1. 収集する情報
    アプリを利用する際、当社は以下の情報を収集することがあります。
           - ユーザーのアプリ利用時間

    2. 情報の使用
    収集した情報は、以下の目的で使用されることがあります。
           - アプリの改善、お知らせなど

    3. 情報の共有
    収集した情報は、法的要件に従った場合や以下のケースを除いて、第三者と共有されることはありません。
    ・人の生命，身体または財産の保護のために必要がある場合であって，本人の同意を得ることが困難であるとき
    ・公衆衛生の向上または児童の健全な育成の推進のために特に必要がある場合であって，本人の同意を得ることが困難であるとき
    ・国の機関もしくは地方公共団体またはその委託を受けた者が法令の定める事務を遂行することに対して協力する必要がある場合であって，本人の同意を得ることにより当該事務の遂行に支障を及ぼすおそれがあるとき

    4. ユーザーの権利
    ユーザーは、自身の個人情報へのアクセス、修正、削除を要求する権利を有します。詳細はアプリ内の設定で確認してください。

    5. セキュリティ
    当社は、適切なセキュリティ対策を講じ、ユーザーの個人情報の保護に努めます。

    6. クッキーとトラッキング技術
    アプリ内でクッキーなどのトラッキング技術を使用する場合、その詳細についてはアプリ内でご確認ください。

    7. 変更通知
    本ポリシーは変更される場合があり、変更後のポリシーはアプリ内で通知されます。

    8. 連絡先
    プライバシーポリシーに関するお問い合わせは、以下の連絡先までご連絡ください。
               zwork.official.app@gmail.com

    以上

    """)
                .multilineTextAlignment(.leading)
            }
            
            .padding(20)
            .statusBarHidden()
            
        }
        .background(ColorUtility.backgroundary)
        .foregroundColor(.white)
        .analyticsScreen(name: String(describing: Self.self),
                                   class: String(describing: type(of: self)))
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView()
    }
}
