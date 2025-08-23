import UIKit
import SpriteKit
import RealityKit
@preconcurrency import ARKit
@preconcurrency import Vision
import Combine
import SwiftUI
@preconcurrency import TeaElephantSchema
import os

private let logAR = Logger(subsystem: Bundle.main.bundleIdentifier ?? "TeaElephant", category: "Network")

@MainActor
class DetectorController: UIViewController, UITextViewDelegate {
	var arView: ARView!
	var subscription: Cancellable!
	var titles = [TitleEntity]()
    var titlesMap: Dictionary<String, TitleEntity> = [:]
	var ids = [String]()
	var newEntities = [EntityModel]()
	
	// Create vision queue once, not for every frame
	private let visionQueue = DispatchQueue(label: "com.teaElephant.ARKitVision.serialVisionQueue")
	private var isProcessingFrame = false

	override func viewDidLoad() {
		super.viewDidLoad()

		arView = ARView(frame: .zero)

		subscription = arView.scene.subscribe(to: SceneEvents.Update.self) { [unowned self] in
			self.updateScene(on: $0)
		}

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

	private func updateScene(on event: SceneEvents.Update) {
		for title in titles {
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

			// Updates the screen position of the note based on its visibility and distance
			title.projection = Projection(
				projectedPoint: projectedPoint,
				isVisible: isVisible,
				distance: currentDistance
			)
			title.updateScreenPosition()
		}
	}

    func handleSessionUpdate(_ session: ARSession, didUpdate frame: ARFrame) {
		// Do not enqueue other buffers for processing while another Vision task is still running.
		// The camera stream has only a finite amount of buffers available; holding too many buffers for analysis would starve the camera.
		guard case .normal = frame.camera.trackingState else {
			return
		}
		
		// Skip if already processing a frame to prevent frame accumulation
		guard !isProcessingFrame else {
			return
		}
		isProcessingFrame = true

        // Retain the image buffer for Vision processing.
        let currentBuffer = frame.capturedImage
		// Most computer vision tasks are not rotation agnostic so it is important to pass in the orientation of the image with respect to device.
		guard let orientation = CGImagePropertyOrientation(rawValue: UInt32(UIDevice.current.orientation.rawValue)) else {
			isProcessingFrame = false
			return
		}
		
        visionQueue.async { [weak self, sessionBox = SendableBox(session), bufferBox = SendableBox(currentBuffer)] in
            guard let self = self else { return }
            let handler = VNImageRequestHandler(cvPixelBuffer: bufferBox.value, orientation: orientation)
            let request = VNDetectBarcodesRequest { request, error in
                defer {
                    Task { @MainActor [weak self] in
                        self?.isProcessingFrame = false
                    }
                }
                guard let results = request.results else { return }
                let session = sessionBox.value
                
                for result in results {
                    guard let barcode = result as? VNBarcodeObservation,
                          let payload = barcode.payloadStringValue else { continue }
                    Task { @MainActor [weak self] in
                        guard let self = self else { return }
                        if self.ids.contains(where: { $0 == payload }) {
                            if let currentFrame = session.currentFrame {
                                self.updateSizeOfTitle(barcode: barcode, frame: currentFrame, id: payload, session: session)
                            }
                        } else if let currentFrame = session.currentFrame {
                            self.processNewBarcode(barcode: barcode, frame: currentFrame, payload: payload, session: session)
                        }
                    }
                }
            }
			request.preferBackgroundProcessing = true
			do {
				try handler.perform([request])
			} catch {
				Task { @MainActor [weak self] in
					self?.isProcessingFrame = false
				}
			}
			Task { @MainActor [weak self] in
				self?.placeNewBarcodes()
			}
		}
	}

	func processNewBarcode(barcode: VNBarcodeObservation, frame: ARFrame, payload: String, session: ARSession) {
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
		ids.append(payload)
		
		// Calculate the reference distance from camera to the detected object
		let cameraPosition = arView.cameraTransform.translation
		let objectPosition = simd_make_float3(raycastResult.worldTransform.columns.3)
		let referenceDistance = length(objectPosition - cameraPosition)
		
		let screenSize: CGRect = UIScreen.main.bounds
		let transform = CGAffineTransform.identity
						.scaledBy(x: 1, y: -1)
						.translatedBy(x: 0, y: -screenSize.height)
						.scaledBy(x: screenSize.width, y: screenSize.height)
		let convertedOrign = center.applying(transform)
		
		// Store the barcode size as reference size for scaling
		let referenceSize = barcode.boundingBox.width
		
		// Calculate initial card size - make it square based on width (50% bigger = 1.5 * 1.5 = 2.25)
		let convertedWidth = barcode.boundingBox.width * screenSize.width * 2.25
		let convertedHeight = convertedWidth // Make it square

        Task {
            do {
                for try await result in Network.shared.apollo.fetchAsync(query: ReadQuery(id: payload), cachePolicy: .fetchIgnoringCacheData) {
                    if let errors = result.errors {
                        logAR.error("AR ReadQuery errors: \(String(describing: errors), privacy: .public)")
                        return
                    }
                    guard let qr = result.data?.qrRecord else {
                        return
                    }
                    let info = TeaInfo(
                        meta: TeaMeta(id: qr.tea.id, expirationDate: ISO8601DateFormatter().date(from: qr.expirationDate)!, brewingTemp: qr.bowlingTemp ),
                        data: TeaData(name: qr.tea.name, type: qr.tea.type, description: qr.tea.description),
                        tags: qr.tea.tags.map({ tag in
                            Tag(id: tag.id, name: tag.name, color: tag.color, category: tag.category.name)
                        })
                    )
                    self.newEntities.append(EntityModel(
                        origin: convertedOrign,
                        width: convertedWidth,
                        height: convertedHeight,
                        id: payload,
                        tea: info,
                        worldTransform: raycastResult.worldTransform,
                        referenceSize: referenceSize,
                        referenceDistance: referenceDistance
                    ))
                }
            } catch {
                logAR.error("AR ReadQuery failure: \(String(describing: error), privacy: .public)")
            }
        }
	}
    
    func updateSizeOfTitle(barcode: VNBarcodeObservation, frame: ARFrame, id: String, session: ARSession) {
        // With real-time scaling, we no longer need to update size when re-detecting barcodes
        // The size is now automatically adjusted based on distance in updateScene
        // This method can be kept empty or removed in future refactoring
    }

	private func placeNewBarcodes() {
		let entities = newEntities
		newEntities = [EntityModel]()
		for entity in entities {
			let titleFrame = CGRect(origin: entity.origin, size: CGSize(width: entity.width, height: entity.height))
			let title = TitleEntity(frame: titleFrame, worldTransform: entity.worldTransform, id: entity.id, info: entity.tea)
			guard let titleView = title.view else {
				return
			}
			
			// Set reference values for real-time scaling
			title.referenceSize = entity.referenceSize
			title.referenceDistance = entity.referenceDistance
			// Ensure square card size
			let squareSize = min(entity.width, entity.height)
			title.baseCardSize = CGSize(width: squareSize, height: squareSize)
			
			title.setPositionCenter(entity.origin)
			arView.scene.addAnchor(title)
			arView.addSubview(titleView)
			titles.append(title)
            titlesMap[entity.id] = title
		}
	}
}

extension DetectorController: ARSessionDelegate {
	nonisolated public func session(_ session: ARSession, didUpdate frame: ARFrame) {
		Task { @MainActor in
			handleSessionUpdate(session, didUpdate: frame)
		}
	}
}
