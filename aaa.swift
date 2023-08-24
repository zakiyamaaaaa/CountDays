//
//  aaa.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/08/05.
//

import SwiftUI

struct aaa: View {
    @Binding var number: Int
    var body: some View {
        Text("\(number)")
    }
}

struct aaa_Previews: PreviewProvider {
    @State static var index: Int = 0
    static var previews: some View {
        aaa(number: $index)
    }
}
