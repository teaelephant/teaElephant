//
// Created by Andrew Khasanov on 21.01.2021.
//

import ARKit
import RealityKit
import SwiftUI

class TitleEntity: Entity, HasAnchoring, HasTeaElephantView {
    var teaElephantComponent = TeaElephantComponent()
    
    var uuid: String
    var info: TeaInfo
    /// Initializes a new StickyNoteEntity and assigns the specified transform.
    /// Also automatically initializes an associated StickyNoteView with the specified frame.
    init(frame: CGRect, worldTransform: simd_float4x4, id: String, info: TeaInfo) {
        uuid = id
        self.info = info
        super.init()
        transform.matrix = worldTransform
        teaElephantComponent.view = TitleView(frame: frame, title: self)
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}
