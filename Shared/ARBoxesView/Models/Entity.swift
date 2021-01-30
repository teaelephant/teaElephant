//
// Created by Andrew Khasanov on 28.01.2021.
//

import UIKit
import RealityKit

struct EntityModel {
	let origin: CGPoint
	let width: CGFloat
	let height: CGFloat
	let id: String
	let name: String
	let worldTransform: simd_float4x4
}
