//
// Created by Andrew Khasanov on 22.01.2021.
//

import RealityKit
import UIKit

protocol HasTeaElephantView: Entity {
    var teaElephantComponent: TeaElephantComponent { get set }
}

extension HasTeaElephantView {
    var view: TitleView? {
        get { teaElephantComponent.view }
        set { teaElephantComponent.view = newValue }
    }

    var shouldAnimate: Bool {
        get { teaElephantComponent.shouldAnimate }
        set { teaElephantComponent.shouldAnimate = newValue }
    }

    var projection: Projection? {
        get { teaElephantComponent.projection }
        set { teaElephantComponent.projection = newValue }
    }

    // Returns the center point of the enity's screen space view
    func getCenterPoint(_ point: CGPoint) -> CGPoint {
        guard let view = view else {
            fatalError("Called getCenterPoint(_point:) on a screen space component with no view.")
        }
        let xCoord = CGFloat(point.x) - (view.frame.width) / 2
        let yCoord = CGFloat(point.y) - (view.frame.height) / 2
        return CGPoint(x: xCoord, y: yCoord)
    }

    // Centers the entity's screen space view on the specified screen location.
    func setPositionCenter(_ position: CGPoint) {
        let centerPoint = getCenterPoint(position)
        guard let view = view else {
            fatalError("Called centerOnHitLocation(_hitLocation:) on a screen space component with no view.")
        }
        view.frame.origin = CGPoint(x: centerPoint.x, y: centerPoint.y)

        // Updating the lastFrame of the StickyNoteView
        view.lastFrame = view.frame
    }

    /// - Tag: ScreenSpaceViewAnimatedPositionUpdatesTag

    // Animates the entity's screen space view to the the specified screen location, and updates the shouldAnimate state of the entity.
    func animateTo(_ point: CGPoint) {

        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .linear) {
            self.setPositionCenter(point)
        }
        // ...

        animator.addCompletion {
            switch $0 {
            case .end:
                self.teaElephantComponent.shouldAnimate = false
            default:
                self.teaElephantComponent.shouldAnimate = true
            }
        }

        animator.startAnimation()
    }

    // Updates the screen space position of an entity's screen space view to the current projection.
    func updateScreenPosition() {
        guard let projection = projection else { return }
        let projectedPoint = projection.projectedPoint
        // Hides the sticky note if it can not visible from the current point of view
        isEnabled = projection.isVisible
        view?.isHidden = !isEnabled

        if shouldAnimate {
            animateTo(projectedPoint)
            // ...
        } else {
            setPositionCenter(projectedPoint)
        }
    }

}

struct TeaElephantComponent: Component {
    var view: TitleView?
    /// Indicates whether the sticky note should animate to a new position (as opposed to moving instantaneously to a new position).
    var shouldAnimate = false
    /// Contains a screen space projection
    var projection: Projection?
}

struct Projection {
    let projectedPoint: CGPoint
    let isVisible: Bool
}
