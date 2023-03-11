import Foundation
import AVFoundation
import UIKit

class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    //    @Published var frame: CGImage?
    @Published var cgImage: CGImage?
    @Published var frame: CVPixelBuffer?
    private let context = CIContext()
    
    private var cameraAccessGranted = false
    private var microphoneAccessGranted = false
    @Published var previewLayer: AVCaptureVideoPreviewLayer!
    
    var activeInput: AVCaptureDeviceInput!
    var captureDevice : AVCaptureDevice?
    var stillImageOutput: AVCapturePhotoOutput!
    
    @Published var captureSession = AVCaptureSession()
    @Published var photoImage: UIImage?
    @Published var isSuccess: Bool = false
    
    func checkPermission(usingBack: Bool){
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .authorized:
            setUpCaptureSession(usingBack: usingBack)
            addDataOutput()
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { status in
                if status {
                    self.setUpCaptureSession(usingBack: usingBack)
                    self.addDataOutput()
                }
            }
        case .denied:
            return
        case .restricted:
            return
        @unknown default:
            return
        }
    }
    
    //设置摄像头
    func setUpCaptureSession(usingBack: Bool) {
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        
        if(usingBack){
            captureDevice = getBackCamera()
        }else{
            captureDevice = getFrontCamera()
        }
        
        //        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
        //            for input in inputs {
        //                captureSession.removeInput(input)
        //            }
        //        }
        stopCaptureSession()
        
        do{
            if captureDevice != nil{
                let captureDeviceInput1 = try AVCaptureDeviceInput(device: captureDevice!)
                activeInput = captureDeviceInput1
                captureSession.addInput(captureDeviceInput1)
                startSession()
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    
    func addOutput() {
        stillImageOutput = AVCapturePhotoOutput()
        
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }
    }
    
    func addDataOutput() {
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: .main)
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
    }
    
    func getFrontCamera() -> AVCaptureDevice?{
        return AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front).devices.first
    }
    
    func getBackCamera() -> AVCaptureDevice?{
        return AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices.first
    }
    
    //MARK:- Camera Session
    func startSession() {
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopCaptureSession () {
        self.captureSession.stopRunning()
        
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                self.captureSession.removeInput(input)
            }
        }
    }
    
    //拍照
    func takePhoto() {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    //获取图片
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation()
        else { return }
        
        let image = UIImage(data: imageData)
        self.photoImage = image
        self.isSuccess = true
    }
    
    //静音
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("[Camera]: Silent sound activated")
        AudioServicesDisposeSystemSoundID(1108)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        AudioServicesDisposeSystemSoundID(1108)
    }
    
    //转换成CVPixelBuffer
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard sampleBuffer.isValid else { return }
        
        if let buffer = sampleBuffer.imageBuffer {
            DispatchQueue.main.async {
//                self.frame = buffer
                let image = CIImage(cvPixelBuffer: buffer).oriented(.up)
                self.cgImage = self.context.createCGImage(image, from: image.extent)
            }
        }
    }
}
