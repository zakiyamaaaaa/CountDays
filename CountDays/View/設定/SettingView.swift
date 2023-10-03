//
//  SettingView.swift
//  DayCD
//
//  Created by shoichiyamazaki on 2023/08/22.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss
    @State var allowNotification = true
    @State private var isTermView = false
    @State private var isPrivacyView = false
    @State private var isInquiry = false
    @State private var isDeleteAllEvent = false
    @State private var showUpgradeView = false
    @State private var showShareDialog = false
    @State private var showShareText = false
    @State private var showQRCodeShare = false
    
    var body: some View {
        settingView
            
    }
    
    private var settingView: some View {
        VStack {
        NavigationStack {
            
            List {
                Section {
                    HStack {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .frame(width: 40, height: 40)
                        Text("アップグレード")
                            .font(.system(size: 20))
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .listRowBackground(ColorUtility.secondary)
                    
                    .onTapGesture {
                        FirebaseAnalyticsManager.recordEvent(analyticsKey: .SettingViewTapUpgrade)
                        showUpgradeView.toggle()
                    }
                }
                
                HStack {
                    Button {
                        /// 設定している通知を確認
                        NotificationCenter.confirmNotification()
                        
                    } label: {
                        Image(systemName: "bell.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                    
                    Text("通知")
                        .font(.system(size: 20))
                    
                    Spacer()
                    Toggle(isOn: $allowNotification) {
                        
                    }.onChange(of: allowNotification) { newValue in
                        FirebaseAnalyticsManager.recordEvent(analyticsKey: .SettingViewToggleNotificatioin, content: newValue.description)
                    }
                    
                }
                .listRowBackground(ColorUtility.secondary)
                
                Section {
                    HStack {
                        Image(systemName: "paperplane.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                        Text("お問い合わせ")
                            .font(.system(size: 20))
                        
                        Spacer()
                    }
                    .listRowBackground(ColorUtility.secondary)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        FirebaseAnalyticsManager.recordEvent(analyticsKey: .SettingViewTapMail)
                        #if targetEnvironment(simulator)
                        #else
                            isInquiry.toggle()
                        #endif
                    }
                }
                
                Section("共有+プライバシー") {
                    HStack {
                        Image(systemName: "square.and.arrow.up.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                        Text("アプリを共有する")
                            .font(.system(size: 20))
                        
                        Spacer()
                    }
                    .listRowBackground(ColorUtility.secondary)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        FirebaseAnalyticsManager.recordEvent(analyticsKey: .SettingViewTapShareView)
                        showShareDialog.toggle()
                    }
                    
                    HStack {
                        Image(systemName: "lock.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                        Text("プライバシーポリシー")
                            .font(.system(size: 20))
                        Spacer()
                    }
                    .listRowBackground(ColorUtility.secondary)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        FirebaseAnalyticsManager.recordEvent(analyticsKey: .SettingViewTapPrivacyPolicy)
                        isPrivacyView.toggle()
                    }
                    
                    HStack {
                        Image(systemName: "doc.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            
                        Text("利用規約")
                            .font(.system(size: 20))
                            
                        Spacer()
                    }
                    
                    .foregroundColor(.white)
                    .listRowBackground(ColorUtility.secondary)
                    .contentShape(Rectangle())
                    .ignoresSafeArea(.all)
                    .onTapGesture {
                        FirebaseAnalyticsManager.recordEvent(analyticsKey: .SettingViewTapTerm)
                        isTermView.toggle()
                    }
                    
                }.sheet(isPresented: $isTermView) {
                    TermView()
                }.sheet(isPresented: $isPrivacyView) {
                    PrivacyPolicyView()
                }.sheet(isPresented: $isInquiry) {
                    MailView()
                }.sheet(isPresented: $showUpgradeView) {
                    UpgradeView()
                }
                
                Section {
                    HStack {
                        Image(systemName: "trash.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                        Text("すべてのイベントを削除")
                            .font(.system(size: 20))
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .listRowBackground(ColorUtility.secondary)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        FirebaseAnalyticsManager.recordEvent(analyticsKey: .SettingViewTapDeleteAllEvent)
                        isDeleteAllEvent.toggle()
                    }
                    
                }.alert("すべてのイベントを\n削除しますか", isPresented: $isDeleteAllEvent) {
                    Button(role: .cancel) {
                        FirebaseAnalyticsManager.recordEvent(analyticsKey: .SettingViewCancelAlertDeleteAllEvent)
                    } label: {
                        Text("キャンセル")
                    }
                    
                    Button(role: .destructive) {
                        RealmViewModel().deleteAllEvents()
                        dismiss()
                        NotificationCenter.removeAllNotification()
                        FirebaseAnalyticsManager.recordEvent(analyticsKey: .SettingViewExecuteAlertDeleteAllEvent)
                    } label: {
                        Text("OK")
                    }
                }
                .confirmationDialog("シェア方法", isPresented: $showShareDialog) {
                    Button {
                        showShareText.toggle()
                    } label: {
                        Text("テキスト")
                    }
                    
                    Button {
                        showQRCodeShare.toggle()
                    } label: {
                        Text("QRコード")
                    }
                }
                
            }
            .sheet(isPresented: $showShareText, content: {
                let text = "ほげほげ"
//                let image = UIImage(named: "QRCodeSample")!
                let url = "https://www.hogehoge.com"
                ShareSheet(photo: nil, text: text, urlString: url)
            })
            .sheet(isPresented: $showQRCodeShare, content: {
                let image = UIImage(named: "QRCodeSample")!
                let url = "https://www.hogehoge.com"
                ShareSheet(photo: image, text: "QRCODW Share", urlString: url)
            })
            .padding(.top, 10)
            .foregroundColor(.white)
            .scrollContentBackground(.hidden)
            .background(ColorUtility.backgroundary)
            .navigationTitle("設定")
            .environment(\.defaultMinListRowHeight, 67)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground( Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .analyticsScreen(name: String(describing: Self.self),
                                   class: String(describing: type(of: self)))
        }
        .onAppear {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                switch settings.authorizationStatus {
                case .authorized, .notDetermined, .provisional, .ephemeral:
                    allowNotification = true
                case .denied:
                    allowNotification = false
                @unknown default:
                    allowNotification = true
                }
            }
        }
        }
    }
    
    // シェアボタン
   func shareApp(shareText: String, shareImage: Image, shareLink: String) {
       let items = [shareText, shareImage] as [Any]
       let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
       let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
       let rootVC = windowScene?.windows.first?.rootViewController
       rootVC?.present(activityVC, animated: true,completion: {})
   }
}

struct ShareSheet: UIViewControllerRepresentable {
    let photo: UIImage?
    let text: String?
    let urlString: String
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        
        let url = URL(string: urlString)!
        let itemSource = ShareActivityItemSource(shareText: text, shareImage: photo, shareURL: url)
        var activityItems = [Any]()
        if let photo {
            activityItems.append(photo)
        } else if let text {
            activityItems.append(text)
        }
        activityItems.append(urlString)
        activityItems.append(itemSource)
//        let activityItems: [Any] = [photo, text, itemSource]

        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil)

        return controller
    }

    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {
    }
}

import LinkPresentation

class ShareActivityItemSource: NSObject, UIActivityItemSource {

    var shareText: String?
    var shareImage: UIImage?
    var shareURL: URL
    var linkMetaData = LPLinkMetadata()

    init(shareText: String?, shareImage: UIImage?, shareURL: URL) {
        self.shareText = shareText
        self.shareImage = shareImage
        self.shareURL = shareURL
        linkMetaData.title = "CountDays App"
        super.init()
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return UIImage(named: "QRCodeSample") as Any
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return nil
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        return linkMetaData
    }
}

struct SettingView_Previews: PreviewProvider {
    @StateObject static var store = Store()
    static var previews: some View {
        SettingView()
            .environmentObject(store)
    }
}
