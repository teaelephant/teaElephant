import UIKit
import SpriteKit
import RealityKit
import ARKit
import Vision
import Combine
import SwiftUI
import TeaElephantSchema

func emptyCallback(_ newID: String) -> Void {
    
}

class DetectorController2: UIViewController, ARSessionDelegate {
    var arView: ARView!
    var ids = [String]()
    var callback: ((_ newID: String) -> Void)!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        arView = ARView(frame: .zero)

        arViewSetup()
    }
    
    private func arViewSetup() {
        #if !targetEnvironment(simulator)
        let config = ARWorldTrackingConfiguration()
        // If the following line fails to compile "Value of type 'ARView' has no member 'session'"
            // You need to select a Real Device or Generic iOS Device and not a simulator
        arView.session.delegate = self
        // If the following line fails to compile "Value of type 'ARView' has no member 'session'"
            // You need to select a Real Device or Generic iOS Device and not a simulator
        arView.session.run(config)
        view = arView
        #endif
    }

    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Do not enqueue other buffers for processing while another Vision task is still running.
        // The camera stream has only a finite amount of buffers available; holding too many buffers for analysis would starve the camera.
        guard case .normal = frame.camera.trackingState else {
            return
        }

        // Retain the image buffer for Vision processing.
        let currentBuffer = frame.capturedImage
        // Most computer vision tasks are not rotation agnostic so it is important to pass in the orientation of the image with respect to device.
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(UIDevice.current.orientation.rawValue))

        let requestHandler = VNImageRequestHandler(cvPixelBuffer: currentBuffer, orientation: orientation!)
        let visionQueue = DispatchQueue(label: "com.example.apple-samplecode.ARKitVision.serialVisionQueue")
        let classificationRequest: VNDetectBarcodesRequest = {
            // Instantiate the model from its generated Swift class.
            let request: VNDetectBarcodesRequest = VNDetectBarcodesRequest(completionHandler: { request, error in
                guard let results = request.results else {
                    print("Unable to classify image.\n\(error!.localizedDescription)")
                    return
                }

                // Loopm through the found results
                for result in results {
                    // Cast the result to a barcode-observation
                    if let barcode = result as? VNBarcodeObservation {
                        guard let payload = barcode.payloadStringValue else {
                            return
                        }
                        if self.ids.contains(where: { id in
                            id == payload
                        }) {
                            continue
                        }
                        self.ids.append(payload)
                        self.callback(payload)
                    }
                }
            })

            // Use CPU for Vision processing to ensure that there are adequate GPU resources for rendering.
            request.usesCPUOnly = true

            return request
        }()
        visionQueue.async {
            do {
                try requestHandler.perform([classificationRequest])
            } catch {
                print("Error: Vision request failed with error \"\(error)\"")
            }
        }
    }
}
