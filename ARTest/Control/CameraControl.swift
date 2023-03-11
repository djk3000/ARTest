import Foundation
import SwiftUI
import AVFoundation

struct CameraControl: UIViewRepresentable {
    @ObservedObject var cameraVM: CameraViewModel
    let size: CGSize
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        cameraVM.previewLayer = AVCaptureVideoPreviewLayer(session: cameraVM.captureSession)
        
        cameraVM.addOutput()
        
        cameraVM.previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(cameraVM.previewLayer)
        
        cameraVM.previewLayer.frame.size = size
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
//        let view = UIView(frame: UIScreen.main.bounds)
//        let statusBarOrientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
//        let videoOrientation: AVCaptureVideoOrientation = statusBarOrientation?.videoOrientation ?? .portrait
//        cameraVM.previewLayer.frame = view.frame
//        cameraVM.previewLayer.connection?.videoOrientation = videoOrientation
    }
    
    
    typealias UIViewType = UIView
}

extension UIInterfaceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeRight: return .landscapeRight
        case .landscapeLeft: return .landscapeLeft
        case .portrait: return .portrait
        default: return nil
        }
    }
}
