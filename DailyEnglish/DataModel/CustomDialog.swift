//
//  CustomDialog.swift
//  CustomDialogTest
//
//  Created by 石井大翔 on 2023/12/05.
//

import SwiftUI

struct CustomDialog: View {
    let title: String
    let subtitle: String
    let onClicked: () -> Void
    
    @State private var isLarge = false
    
    let widthSize =  UIScreen.main.bounds.width
    let heightSize =  UIScreen.main.bounds.height
    let gradationColor = LinearGradient(gradient: Gradient(colors: [.orange, .yellow]), startPoint: .topTrailing, endPoint: .bottomLeading)
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.title.bold())
                .padding(.top)
            Spacer()
            Image(systemName: "ticket")
                .resizable()
                .scaledToFit()
                .frame(width: widthSize / 2)
                .foregroundStyle(gradationColor)
                .scaleEffect(isLarge ? 1.3 : 1)
                .animation(.spring(), value: isLarge)
            Spacer()
            Text(subtitle)
                .font(.headline)
            
            Spacer()
            Button(action: {
                onClicked()
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("閉じる")
                    .font(.headline)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 50,alignment:.center)
                    .background(Color.yellow)
                    .clipShape(.rect(cornerRadius: 10))
            })
        }
        .onAppear {
            // 2秒ごとに反転
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
                isLarge.toggle()
            }
        }
        .padding()
    }
}

func showCustomDialog(title: String, subtitle: String, onClicked: @escaping () -> Void) {
    let contentView = CustomDialog(title: title, subtitle: subtitle, onClicked: onClicked)
    
    let root = getTopViewController()
    
    root?.present(UIHostingController(rootView: contentView), animated: true)
}

//現在表示しているViewを取得する関数
func getTopViewController() -> UIViewController? {
    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        if let window = scene.windows.first {
            var topViewController = window.rootViewController
            
            while let presentedViewController = topViewController?.presentedViewController {
                topViewController = presentedViewController
            }
            
            return topViewController
        }
    }
    
    return nil
}



#Preview {
    CustomDialog(
        title: "タイトル",
        subtitle: "サブタイトルです。",
        onClicked: {})
}
