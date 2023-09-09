//
//  CustomImagePicker.swift
//  CountDays
//
//  Created by shoichiyamazaki on 2023/09/07.
//

import SwiftUI
import StoreKit
import PhotosUI

extension View {
    @ViewBuilder
    func cropImagePicker(show: Binding<Bool>, croppedImage: Binding<UIImage?>) -> some View {
        CustomImagePicker(show: show, croppedImage: croppedImage) {
            self
        }
    }
    
    @ViewBuilder
    func frame(_ size: CGSize) -> some View {
        self.frame(width: size.width, height: size.height)
    }
}

struct CustomImagePicker<Content: View>: View {
    var content: Content
    @Binding var show: Bool
    @Binding var croppedImage: UIImage?
    @State private var photosItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showDialog: Bool = false
    @State private var showCropView: Bool = false
    
    
    init(show: Binding<Bool>, croppedImage: Binding<UIImage?>, @ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        self._show = show
        self._croppedImage = croppedImage
    }
    
    var body: some View {
        content
            .photosPicker(isPresented: $show, selection: $photosItem)
            .onChange(of: photosItem) { newValue in
                if let newValue {
                    Task {
                        if let imageData = try? await newValue.loadTransferable(type: Data.self), let image = UIImage(data: imageData) {
                            await MainActor.run(body: {
                                selectedImage = image
//                                showDialog.toggle()
                                showCropView.toggle()
                            })
                        }
                    }
                }
            }
//            .sheet(isPresented: $showCropView, content: {
//                CropView(image: selectedImage) { croppedImage, status in
//                    if let croppedImage {
//                        self.croppedImage = croppedImage
//                    }
//                }
//            })
            .fullScreenCover(isPresented: $showCropView) {
                selectedImage = nil
            } content: {
                CropView(image: selectedImage) { croppedImage, status in
                    if let croppedImage {
                        self.croppedImage = croppedImage
                    }
                }
            }

//            .confirmationDialog("", isPresented: $showDialog) {
//                Button {
//                    showCropView.toggle()
//                } label: {
//                    Text("OK")
//                }
//            }
    }
}

struct CustomImagePicker_Previews: PreviewProvider {
    @StateObject static var store = Store()
    static var previews: some View {
        CropView(image: UIImage(named: "sample")) { _, _ in}
            .environmentObject(store)
    }
}

struct CropView: View {
    @EnvironmentObject var store: Store
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 0
    @State private var offset: CGSize = .zero
    @State private var lastStoredOffsed: CGSize = .zero
    @State var imageBrightness: CGFloat = 0
    @State private var imageBlur: CGFloat = 0
    @State private var pressed = false
    @State private var isPurchased = true
    @State private var showUpgradeView = false
    @State private var showUpgradeAlert = false
    @State private var opacity: CGFloat = 0
    @GestureState private var isInteraction: Bool = false {
        willSet {
            print("interaction: \(newValue)")
        }
    }
    
    var image: UIImage?
    var onCrop: (UIImage?, Bool) -> ()
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            headerView
//                .onAppear {
//                    opacity = 1
//                }
            
            ZStack {
                ImageView()
//                    .navigationTitle("Crop View")
//                    .navigationBarTitleDisplayMode(.inline)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Rectangle()
                    .opacity(pressed ? 0.8 : 1)
                    .ignoresSafeArea(edges:.bottom)
                    .overlay {
                        Rectangle()
                            .cornerRadius(20)
                            .frame(width: 150, height: 150)
                            .blendMode(.destinationOut)
                    }
                    .compositingGroup()
                    .allowsHitTesting(false)
                    .animation(.easeOut(duration: 0.3).delay(0.2), value: pressed)
                
                VStack {
                    Spacer()
                    
                    Spacer()
                    Color.clear
                        .cornerRadius(20)
                        .frame(width: 150, height: 150)
                        
                    
                    Button {
                        
                        if isPurchased {
                            let render = ImageRenderer(content: ImageView())
                            render.proposedSize = .init(cropSize)
                            
                            if let image = render.uiImage {
                                onCrop(image, true)
                            } else {
                                onCrop(nil, false)
                            }
                            dismiss()
                        } else {
                            showUpgradeAlert.toggle()
                        }
                        
                        
                    } label: {
                        Text("OK")
                            .foregroundColor(.white)
                            .frame(width:100, height: 40)
                            .background(.mint)
                            .cornerRadius(20)
                    }
                    .disabled(pressed)
                    .opacity(pressed ? 0.5 : 1.0)
                    .offset(y:40)
                    .animation(.easeIn(duration: 0.2), value: pressed)
                    

                    
                    Spacer()
                    
                    
                    HStack {
                        Text("明るさ💡")
                            .foregroundColor(.white)
                        Text(String(format: "%.1f", imageBrightness))
                            .foregroundColor(.white)
                        Slider(value: $imageBrightness, in: -0.5...0.5) {
                            Text("明るさ")
                        }
                        .tint(.mint)
                        .padding(.horizontal)
                        
                        Button {
                            imageBrightness = 0
                        } label: {
                            Image(systemName: "gobackward")
                        }
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("ぼかし🌫️")
                            .foregroundColor(.white)
                        Text(String(format: "%.1f", imageBlur))
                            .foregroundColor(.white)
                        Slider(value: $imageBlur, in: 0...5) {
                            Text("明るさ")
                        }
                        .tint(.white)
                        .padding(20)
                        
                        Button {
                            imageBlur = 0
                        } label: {
                            Image(systemName: "gobackward")
                        }

                    }
                    .padding(.horizontal)
                }
                
                }
            .onAppear {
                opacity = 1.0
            }
//                .toolbar {
//                    ToolbarItem(placement: .navigationBarTrailing) {
//                        Button {
//                            let render = ImageRenderer(content: ImageView())
//                            render.proposedSize = .init(cropSize)
//
//                            if let image = render.uiImage {
//
//                                onCrop(image, true)
//                            } else {
//                                onCrop(nil, false)
//                            }
//                            dismiss()
//                        } label: {
//                            Image(systemName: "checkmark")
//                                .font(.callout)
//                                .fontWeight(.semibold)
//                        }
//
//                    }
//
//
//                    ToolbarItem(placement: .navigationBarLeading) {
//                        Button {
//                            dismiss()
//                        } label: {
//                            Image(systemName: "xmark")
//                                .font(.callout)
//                                .fontWeight(.semibold)
//                        }
//                    }
//
//                }
                .task {
                    guard let product = try? await store.fetchProducts(ProductId.super.rawValue).first else { return }
                    
                    do {
                        try await self.isPurchased = store.isPurchased(product)
                        
                        #if DEBUG
                        self.isPurchased = true
                        #endif
                        
                    } catch(let error) {
                        print(error.localizedDescription)
                    }
                }
                .alert("画像を使用するにはアップグレードが必要です🙇‍♂️", isPresented: $showUpgradeAlert) {
                    Button("OK") {
                        showUpgradeView.toggle()
                    }
                }
                .sheet(isPresented: $showUpgradeView) {
                    
                } content: {
                    UpgradeView()
                }

        }
    }
    
    /// HeaderView
    private var headerView: some View {
        
        
        HStack {
            if opacity > 0{
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        
                }
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
                .font(.system(size: 30))
                .background(ColorUtility.secondary)
                .clipShape(Circle())
                .padding()
                
                .transition(.opacity)
                .opacity(opacity)
//                .opacity(opacity ? 1 : 0)
                .animation(.easeIn(duration: 1.0).delay(1.7), value: opacity)
            }
            
            
            
            Text("画像編集")
                .foregroundColor(.white)
                .fontWeight(.bold)
                .font(.system(.largeTitle))
            
            Spacer()
        }
        .animation(.easeOut(duration: 0.4).delay(0.5), value: opacity)
        .frame(height: 80)
        .background(ColorUtility.primary)
    }
    
    let cropSize = CGSize(width: 150, height: 150)
    @ViewBuilder
    func ImageView() -> some View {
        
        GeometryReader {
            let size = $0.size
            
            if let image {
                
                    Image(uiImage: image)
                        
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .brightness(imageBrightness)
                        .blur(radius: imageBlur)
                        .overlay(content: {
                            GeometryReader { proxy in
                                let rect = proxy.frame(in: .named("CROPVIEW"))
                                Color.clear
                                    
                                    .onChange(of: isInteraction) { newValue in
                                        
                                        withAnimation(.easeOut(duration: 0.2)) {
                                            
                                            if rect.minX > 0 {
                                                offset.width = offset.width - rect.minX
                                            }
                                            
                                            if rect.minY > 0 {
                                                offset.height = offset.height - rect.minY
                                            }
                                            
                                            if rect.maxX < size.width {
                                                offset.width = rect.minX - offset.width
                                            }
                                            if rect.maxY < size.height {
                                                offset.height = rect.minY - offset.height
                                            }
                                            
                                        }
//                                        pressed = true
                                        if !newValue {
//                                            pressed = false
                                            lastStoredOffsed = offset
                                        }
                                    }
                                    .onLongPressGesture(perform: {
                                        
                                    }, onPressingChanged: { value in
                                        pressed = value
                                    })
                            }
                        })
                        .frame(size)
            }
        }
        
        .scaleEffect(scale)
        .offset(offset)
        .frame(cropSize)
        .overlay(content: {
            Grids()
                .opacity(pressed ? 1.0 : 0)
                .animation(.easeIn(duration: 0.2), value: pressed)
        })
        .coordinateSpace(name: "CROPVIEW")
        .gesture(
            DragGesture()
                .updating($isInteraction, body: { _, out, _ in
                    out = true
                }).onChanged({ value in
                    let translation = value.translation
                    offset = CGSize(width: translation.width + lastStoredOffsed.width, height: translation.height + lastStoredOffsed.height)
                    pressed = true
                }).onEnded({ _ in
                    pressed = false
                })
        )
        .gesture(
            MagnificationGesture()
                .updating($isInteraction, body: { _, out, _ in
                    out = true
                }).onChanged({ value in
                    let updatedScale = value + lastScale
                    scale = (updatedScale < 1 ? 1 : updatedScale)
                    pressed = true
                }).onEnded({ value in
                    withAnimation(.easeOut(duration: 0.2)) {
                        if scale < 1 {
                            scale = 1
                            lastScale = 0
                        } else {
                            lastScale = scale - 1
                        }
                    }
                    pressed = false
                })
        )
        .onLongPressGesture( perform: {
            
        }, onPressingChanged: { state in
            pressed = state
        })
//        .onAppear(
//            if let image {
//                image
//            }
//        )
        
    }
    
    @ViewBuilder
    func Grids() -> some View {
        ZStack {
            HStack {
                ForEach(1...4, id: \.self){_ in
                    Rectangle()
                        .fill(.white.opacity(0.7))
                        .frame(width: 1)
                        .frame(maxWidth: .infinity)
                }
            }
            
            VStack {
                ForEach(1...4, id: \.self){_ in
                    Rectangle()
                        .fill(.white.opacity(0.7))
                        .frame(height: 1)
                        .frame(maxHeight: .infinity)
                }
            }
        }
    }
}
