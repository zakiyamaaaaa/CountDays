//
//  TestView2.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/08/21.
//

import SwiftUI
import PhotosUI
import RealmSwift
import Foundation

struct TestView2: View {
    @State var selectedDate = Date()
    var dateViewModel = DateViewModel()
    @State private var selectedImage: UIImage? = nil
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State var image: UIImage?
    
    var body: some View {
        VStack {
            HStack {
                
                Text("\(dateViewModel.getMonthText(date: selectedDate))月")
                    .font(.system(size: 25))
                    .fontWeight(.bold)
                Text("\(dateViewModel.getDayText(date: selectedDate))日")
                    .font(.system(size: 25))
                    .fontWeight(.bold)
            }
            
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .frame(width: 150, height: 150)
                    .overlay(content: {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(lineWidth: 5)
                            .fill(.red)
                    })
                    .cornerRadius(20)
                    .overlay(alignment: .center) {
                        PhotosPicker(selection: $selectedPhoto, label: {
                            Rectangle()
                                .frame(width: 150, height: 150)
                            .foregroundColor(.clear)})
                        .onChange(of: selectedPhoto) { pickedItem in
                            Task {
                                if let data = try? await pickedItem?.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                                    selectedImage = uiImage
                                }
                                
                            }
                        }
                    }
               
                }  else {
                    Rectangle()
                        .foregroundColor(.gray)
                        .frame(width: 150, height: 150)
                        .overlay(alignment: .center) {
                            PhotosPicker(selection: $selectedPhoto, label: {
                                            Rectangle()
                                                .frame(width: 150, height: 150)
                                                .foregroundColor(.clear)})
                        .onChange(of: selectedPhoto) { pickedItem in
                            Task {
                                if let data = try? await pickedItem?.loadTransferable(type: Data.self), let uiImage = UIImage(data: data) {
                                    selectedImage = uiImage
                                }
                            }
                        }
                    }
                }
            Button {
                let render = ImageRenderer(content: imageSampleView)
                if let image = render.uiImage {
                    self.image = image
                }
                
            } label: {
                Text("複製")
            }
            
            if let image {
                Image(uiImage: image)
            }
        }
    }
    
    private var imageSampleView: some View {
        ZStack {
            Rectangle()
                .frame(width: 100, height: 100)
                .foregroundColor(.red)
            Image(systemName: "lock.fill")
                .resizable()
                .frame(width: 100, height: 100)
        }.cornerRadius(20)
    }
}

struct TestView2_Previews: PreviewProvider {
    static var previews: some View {
        TestView2()
    }
}
