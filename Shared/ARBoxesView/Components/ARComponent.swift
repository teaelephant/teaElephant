//
// Created by Andrew Khasanov on 22.01.2021.
//

import RealityKit
import UIKit

@available(iOS 17.0, *)
protocol HasTeaElephantView: Entity {
    var teaElephantComponent: TeaElephantComponent { get set }
}

@available(iOS 17.0, *)
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

    var lenNew: CGFloat? {
        get { teaElephantComponent.lenNew }
        set { teaElephantComponent.lenNew = newValue }
    }

    var len: CGFloat? {
        get { teaElephantComponent.len }
        set { teaElephantComponent.len = newValue }
    }

    var firstSize: CGFloat? {
        get { teaElephantComponent.firstSize }
        set { teaElephantComponent.firstSize = newValue }
    }
    var secondSize: CGFloat? {
        get { teaElephantComponent.secondSize }
        set { teaElephantComponent.secondSize = newValue }
    }
    var firstLen: CGFloat? {
        get { teaElephantComponent.firstLen }
        set { teaElephantComponent.firstLen = newValue }
    }
    var secondLen: CGFloat? {
        get { teaElephantComponent.secondLen }
        set { teaElephantComponent.secondLen = newValue }
    }

    var sizeCorrection: CGSize? {
        get { teaElephantComponent.sizeCorrection }
        set { teaElephantComponent.sizeCorrection = newValue }
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
        // view.cardView.frame.origin = CGPoint(x: centerPoint.x, y: centerPoint.y)

        if let sizeCorrection = sizeCorrection {
            view.cardView.frame.size = sizeCorrection
            view.frame.size = sizeCorrection
            self.sizeCorrection = nil
        } else if let len = len, let lenNew = lenNew {
            let k = calcConstant()
            if let k = k {
                let u = (len + k) / (lenNew + k)
                // view.frame.size = CGSize(width: view.lastFrame.width*u, height: view.lastFrame.height)
            }
        }

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

    func calcConstant() -> CGFloat? {
        guard let secondLen = secondLen else { return nil }
        guard let firstSize = firstSize else { return nil }
        guard let secondSize = secondSize else { return nil }
        guard let firstLen = firstLen else { return nil }
        let sizeDiff = firstSize - secondSize
        if sizeDiff == 0 {
            return nil
        }
        return (secondSize * secondLen - firstSize * firstLen) / sizeDiff
    }

}

@available(iOS 17.0, *)
struct TeaElephantComponent: Component {
    var view: TitleView?
    /// Indicates whether the sticky note should animate to a new position (as opposed to moving instantaneously to a new position).
    var shouldAnimate = false
    /// Contains a screen space projection
    var projection: Projection?

    var lenNew: CGFloat?

    var len: CGFloat?

    var firstSize: CGFloat?
    var firstLen: CGFloat?
    var secondSize: CGFloat?
    var secondLen: CGFloat?
    var sizeCorrection: CGSize?
}

struct Projection {
    let projectedPoint: CGPoint
    let isVisible: Bool
}
