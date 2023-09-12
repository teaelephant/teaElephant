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

struct Detector: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> DetectorController {
        return DetectorController()
    }

    func updateUIViewController(_ uiViewController: DetectorController, context: Context) {
    }

    typealias UIViewControllerType = DetectorController
}

class GradientView: UIView {

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

extension SIMD4 {
    var xyz: SIMD3<Scalar> {
        self[SIMD3(0, 1, 2)]
    }
}

extension CVPixelBuffer {
    var size: CGSize {
        get {
            let width = CGFloat(CVPixelBufferGetWidth(self))
            let height = CGFloat(CVPixelBufferGetHeight(self))
            return CGSize(width: width, height: height)
        }
    }
}
