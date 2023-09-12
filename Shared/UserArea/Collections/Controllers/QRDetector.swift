/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the ARKitVision sample.
*/

import UIKit
import SpriteKit
import RealityKit
import ARKit
import Vision
import Combine
import SwiftUI

struct QRDetector: UIViewControllerRepresentable {
    var callback: (_ newID: String) -> Void
    
    func makeUIViewController(context: Context) -> QRDetectorController {
        let view = QRDetectorController()
        view.callback = callback

        return view
    }

    func updateUIViewController(_ uiViewController: QRDetectorController, context: Context) {
    }

    typealias UIViewControllerType = QRDetectorController
}
