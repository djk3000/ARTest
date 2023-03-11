//
//  ContentView.swift
//  ARTest
//
//  Created by 邓璟琨 on 2023/2/19.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject var cameraVM: CameraViewModel = CameraViewModel()
    @State var changeCamera: Bool = true
    @State var cameraIsChange: Bool = false
    @State var uiImage: UIImage?
    @State var flipped = false
    
    let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
        .makeConnectable()
        .autoconnect()
    
    var body: some View {
        ZStack {
            //            cameraView
            imageCameraView
                .onTapGesture(count: 2) {
                    cameraIsChange = true
                    changeCamera.toggle()
                    cameraVM.setUpCaptureSession(usingBack: changeCamera)
                    withAnimation (.easeInOut(duration: 0.5)) {
                        flipped.toggle()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        cameraIsChange = false
                    }
                }
            
        }
        .ignoresSafeArea()
        .onReceive(orientationChanged) { _ in
            //是否旋转
            print(UIDevice.current.orientation)
        }
    }
    
    var cameraView: some View {
        GeometryReader{ proxy in
            ZStack {
                CameraControl(cameraVM: cameraVM, size: proxy.size
                )
                .onAppear {
                    cameraVM.checkPermission(usingBack: changeCamera)
                }
                
                if cameraIsChange {
                    RoundedRectangle(cornerRadius: 0)
                        .foregroundColor(.gray)
                        .opacity(0.2)
                        .blendMode(.hardLight)
                        .foregroundStyle(.regularMaterial)
                        .ignoresSafeArea()
                        .rotation3DEffect(self.flipped ? Angle(degrees: 180): Angle(degrees: 0), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))
                }
            }
        }
    }
    
    var imageCameraView: some View{
        ZStack {
            if let image = cameraVM.cgImage {
                GeometryReader { geometry in
                    Image(image, scale: 1.0, orientation: .right, label: Text("frame"))
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height,
                            alignment: .center)
                        .clipped()
                }
            } else {
                EmptyView()
            }
            
            if cameraIsChange {
                RoundedRectangle(cornerRadius: 0)
                    .foregroundColor(.gray)
                    .opacity(1)
                    .blendMode(.hardLight)
                    .foregroundStyle(.regularMaterial)
                    .ignoresSafeArea()
                    .rotation3DEffect(self.flipped ? Angle(degrees: 180): Angle(degrees: 0), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))
            }
        }
        .onAppear {
            cameraVM.checkPermission(usingBack: changeCamera)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(cameraVM: CameraViewModel())
    }
}
