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

class QRDetectorController: UIViewController, ARSessionDelegate {
    var arView: ARView!
    var subscription: Cancellable!
    var ids = [String]()
    var callback: ((_ newID: String) -> Void)!
    var checked: [CheckedEntity] = [CheckedEntity]()
    var checkedMap: Dictionary<String, CheckedEntity> = [:]
    var newEntities = [CheckedEntityModel]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        arView = ARView(frame: .zero)
        
        subscription = arView.scene.subscribe(to: SceneEvents.Update.self) { [unowned self] in
            self.updateScene(on: $0)
        }

        arViewSetup()
    }
    
    private func updateScene(on event: SceneEvents.Update) {
        for title in checked {
            // Gets the 2D screen point of the 3D world point.
            guard let projectedPoint = arView.project(title.position) else {
                return
            }


            // Calculates whether the note can be currently visible by the camera.
            let cameraForward = arView.cameraTransform.matrix.columns.2.xyz
            let cameraToWorldPointDirection = normalize(title.transform.translation - arView.cameraTransform.translation)
            let dotProduct = dot(cameraForward, cameraToWorldPointDirection)
            let isVisible = dotProduct < 0


            // Calculate current distance from camera to the AR object
            let currentDistance = length(title.position(relativeTo: nil) - arView.cameraTransform.translation)
            
            // Updates the screen position of the note based on its visibility
            title.projection = Projection(projectedPoint: projectedPoint, isVisible: isVisible, distance: currentDistance)
            title.updateScreenPosition()
        }
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
        let visionQueue = DispatchQueue(label: "com.teaElephant.ARKitVision.serialVisionQueue")
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
                            self.updateSizeOfTitle(barcode: barcode, frame: frame, id: payload, session: session)
                            continue
                        }
                        self.processNewBarcode(barcode: barcode, frame: frame, payload: payload, session: session)
                    }
                }
            })

            // Use CPU for Vision processing to ensure that there are adequate GPU resources for rendering.
            request.preferBackgroundProcessing = true

            return request
        }()
        visionQueue.async {
            do {
                try requestHandler.perform([classificationRequest])
            } catch {
                print("Error: Vision request failed with error \"\(error)\"")
            }
        }
        placeNewBarcodes()
    }
    
    func processNewBarcode(barcode: VNBarcodeObservation, frame: ARFrame, payload: String, session: ARSession) {
        ids.append(payload)
        self.callback(payload)
        var rect = barcode.boundingBox
        // Flip coordinates
        rect = rect.applying(CGAffineTransform(scaleX: 1, y: -1))
        rect = rect.applying(CGAffineTransform(translationX: 0, y: 1))
        // Get center
        let center = CGPoint(x: rect.midX, y: rect.midY)

        let query = frame.raycastQuery(
                        from: center,
                        allowing: .estimatedPlane,
                        alignment: .any)
        guard let raycastResult = session.raycast(query).first else {
            return
        }
        let screenSize: CGRect = UIScreen.main.bounds
        let transform = CGAffineTransform.identity
                        .scaledBy(x: 1, y: -1)
                        .translatedBy(x: 0, y: -screenSize.height)
                        .scaledBy(x: screenSize.width, y: screenSize.height)
        let convertedOrign = center.applying(transform)
        let convertedHeight = barcode.boundingBox.height * screenSize.height
        let convertedWidth = barcode.boundingBox.width * screenSize.width * 2

        self.newEntities.append(CheckedEntityModel(
                        origin: convertedOrign,
                        width: convertedWidth,
                        height: convertedHeight,
                        id: payload,
                        worldTransform: raycastResult.worldTransform
        ))
    }
    
    func updateSizeOfTitle(barcode: VNBarcodeObservation, frame: ARFrame, id: String, session: ARSession) {
        var rect = barcode.boundingBox
        // Flip coordinates
        rect = rect.applying(CGAffineTransform(scaleX: 1, y: -1))
        rect = rect.applying(CGAffineTransform(translationX: 0, y: 1))
        let screenSize: CGRect = UIScreen.main.bounds
        let convertedWidth = barcode.boundingBox.width * screenSize.width * 2
        DispatchQueue.main.async {
            self.checkedMap[id]?.sizeCorrection = CGSize(width: convertedWidth, height: convertedWidth)
            if self.checkedMap[id]?.secondSize == nil {
                self.checkedMap[id]?.secondSize = convertedWidth
            }
        }
    }

    private func placeNewBarcodes() {
        let entities = newEntities
        newEntities = [CheckedEntityModel]()
        for entity in entities {
            let titleFrame = CGRect(origin: entity.origin, size: CGSize(width: entity.width, height: entity.width))
            let title = CheckedEntity(frame: titleFrame, worldTransform: entity.worldTransform, id: entity.id)
            guard let titleView = title.view else {
                return
            }
            title.setPositionCenter(entity.origin)
            title.firstSize = entity.width
            arView.scene.addAnchor(title)
            arView.addSubview(titleView)
            checked.append(title)
            checkedMap[entity.id] = title
        }
    }
}
