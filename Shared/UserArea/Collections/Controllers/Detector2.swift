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
    var callback: (_ newID: String) -> Void
    
    func makeUIViewController(context: Context) -> DetectorController2 {
        let view = DetectorController2()
        view.setCallback(newCallback: callback)

        return view
    }

    func updateUIViewController(_ uiViewController: DetectorController2, context: Context) {
    }

    typealias UIViewControllerType = DetectorController2
}
