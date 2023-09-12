//
//  TestView3.swift
//  CountDays
//
//  Created by shoichiyamazaki on 2023/09/07.
//

import SwiftUI

class TestViewModel: ObservableObject {
    @Published var textTitle: String
    
    init(textTitle: String = "") {
        self.textTitle = textTitle
    }
//    init(textTitle: Binding<String>) {
//        self._textTitle = textTitle
//    }
}

struct TestView3Sub: View {
//    @Binding var testvm: TestViewModel
    @StateObject var testvm: TestViewModel
    
    var body: some View {
        Text("the text below")
        Text(testvm.textTitle)
    }
}

struct TestView3: View {
    @State private var croppedImage: UIImage?
    @State private var showPicker = false
    @State var title = ""
    @StateObject var model: TestViewModel = TestViewModel()
    @State private var showView = false
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
                    TextField("hoge", text: $model.textTitle)
                        .border(.white)
                        .font(.system(size: 30))
                        .padding()
                        .foregroundColor(.white)
                        .frame(height : 80.0)
                        .background(RoundedRectangle(cornerRadius: 20)
                            .fill(ColorUtility.secondary))
                    
                    TestView3Sub(testvm: model)
                    
                    Button {
                        showView.toggle()
                    } label: {
                        Text("次へ")
                    }
                }
            }
            .sheet(isPresented: $showView, content: {
                TestView2(model: model)
            })
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
