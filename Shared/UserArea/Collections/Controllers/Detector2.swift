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

struct Detector2: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> DetectorController {
        let view = DetectorController()

        return view
    }

    func updateUIViewController(_ uiViewController: DetectorController, context: Context) {
    }

    typealias UIViewControllerType = DetectorController
}

class GradientView2: UIView {

    init(topColor: CGColor, bottomColor: CGColor) {
        super.init(frame: .zero)
        let gradientLayer = layer as? CAGradientLayer
        gradientLayer?.colors = [
            topColor,
            bottomColor
        ]
        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open class var layerClass: AnyClass {
        CAGradientLayer.self
    }

}
