//
//  TermView.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/08/22.
//

import SwiftUI

struct TermView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HeaderView(title: "利用規約")

            ScrollView(showsIndicators: false) {
                Text("""
    この利用規約（以下、「本規約」といいます。）は、zwork（以下、「当社」といいます。）が提供するアプリケーション（以下、「アプリ」といいます。）の利用に関する条件を定めるものです。アプリをご利用いただく際には、本規約に同意いただいたものとみなします。
    
    
    1. サービスの提供
    当社は、アプリを通じてユーザー体験を提供します。ユーザーは、本規約に従い、アプリを利用できます。
    
    2. 利用規約の変更
        当社は、必要に応じて本規約を変更することがあります。変更後の利用規約は、アプリ内での表示をもって通知された時点で効力を生じるものとします。
    
    3. ユーザーの責任
        ユーザーは、正確かつ適切な情報を提供し、アプリの利用に際して法律および規制に遵守する責任があります。
    
    4. プライバシー
        ユーザーの個人情報の収集、使用、共有については、当社のプライバシーポリシーに従います。
    
    5. 知的財産権
        アプリに関連する知的財産権は、当社またはライセンサーに帰属します。ユーザーは、無断でこれらの知的財産権を使用、複製、変更することはできません。
    
    6. 免責事項
        アプリの利用に関する一切のリスクは、ユーザーが負うものとし、当社はそれに関連する損害に対して責任を負いません。
    
    7. 法的権限
        本規約に関する紛争については、当社の所在地を管轄する裁判所を専属的合意管轄とします。

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

struct TermView_Previews: PreviewProvider {
    static var previews: some View {
        TermView()
    }
}
