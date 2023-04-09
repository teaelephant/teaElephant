import UIKit
import SpriteKit
import RealityKit
import ARKit
import Vision
import Combine
import SwiftUI
import TeaElephantSchema

class DetectorController: UIViewController, ARSessionDelegate, UITextViewDelegate {
	var arView: ARView!
	var subscription: Cancellable!
	var titles = [TitleEntity]()
	var ids = [String]()
	var newEntities = [EntityModel]()
	var direction: SIMD3<Float> = SIMD3(0, 0, 0)

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

			guard let or = arView.ray(through: projectedPoint) else {
				return
			}

			if direction - or.direction != SIMD3(0, 0, 0) {
				print(direction - or.direction)
				direction = or.direction
			}


			// Calculates whether the note can be currently visible by the camera.
			let cameraForward = arView.cameraTransform.matrix.columns.2.xyz
			let cameraToWorldPointDirection = normalize(title.transform.translation - arView.cameraTransform.translation)
			let dotProduct = dot(cameraForward, cameraToWorldPointDirection)
			let isVisible = dotProduct < 0


			// Updates the screen position of the note based on its visibility
			title.projection = Projection(projectedPoint: projectedPoint, isVisible: isVisible)
			title.updateScreenPosition()
		}
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
						self.processNewBarcode(barcode: barcode, frame: frame, payload: payload, session: session)
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
		placeNewBarcodes()
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
		let screenSize: CGRect = UIScreen.main.bounds
		let transform = CGAffineTransform.identity
						.scaledBy(x: 1, y: -1)
						.translatedBy(x: 0, y: -screenSize.height)
						.scaledBy(x: screenSize.width, y: screenSize.height)
		let convertedOrign = center.applying(transform)
		let convertedHeight = barcode.boundingBox.height * screenSize.height
		let convertedWidth = barcode.boundingBox.width * screenSize.width * 2

		Network.shared.apollo.fetch(query: ReadQuery(id: payload)) { result in
			switch result {
			case .success(let graphQLResult):
				if let errors = graphQLResult.errors {
					print(errors)
					return
				}
				guard let tea = graphQLResult.data?.qrRecord?.tea else {
					return
				}
				self.newEntities.append(EntityModel(
								origin: convertedOrign,
								width: convertedWidth,
								height: convertedHeight,
								id: payload,
								name: tea.name,
								worldTransform: raycastResult.worldTransform
				))
			case .failure(let error):
				print(error)
			}
		}

	}

	private func placeNewBarcodes() {
		let entities = newEntities
		newEntities = [EntityModel]()
		for entity in entities {
			let titleFrame = CGRect(origin: entity.origin, size: CGSize(width: entity.width, height: entity.height))
			let title = TitleEntity(frame: titleFrame, worldTransform: entity.worldTransform, id: entity.id, name: entity.name)
			guard let titleView = title.view else {
				return
			}
			title.setPositionCenter(entity.origin)
			arView.scene.addAnchor(title)
			arView.addSubview(titleView)
			titles.append(title)
			titleView.textView.delegate = self
		}
	}
}
