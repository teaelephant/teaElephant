//
// Created by Andrew Khasanov on 28.01.2021.
//

import UIKit
import RealityKit
import TeaElephantSchema

struct EntityModel {
	let origin: CGPoint
	let width: CGFloat
	let height: CGFloat
	let id: String
    let tea: TeaInfo
	let worldTransform: simd_float4x4
	let referenceSize: CGFloat
	let referenceDistance: Float
}
