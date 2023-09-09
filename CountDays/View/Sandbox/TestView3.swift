//
//  TestView3.swift
//  CountDays
//
//  Created by shoichiyamazaki on 2023/09/07.
//

import SwiftUI

struct TestView3: View {
    @State private var croppedImage: UIImage?
    @State private var showPicker = false
    var body: some View {
        NavigationStack {
            VStack {
                if let croppedImage {
                    Image(uiImage: croppedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                } else {
                    Text("No Image")
                    
                }
            }
            .navigationTitle("Crop Image Picker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar  {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showPicker.toggle()
                    } label: {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.callout)
                    }
                    .tint(.blue)
                    
                }
            }
            .cropImagePicker(show: $showPicker, croppedImage: $croppedImage)
        }
    }
}

struct TestView3_Previews: PreviewProvider {
    static var previews: some View {
        TestView3()
    }
}
