//
// Created by Andrew Khasanov on 22.01.2021.
//

import UIKit
import SwiftUI

/// A subclass of UIView that will be inserted into the scene in "Screen Space", that composes the sticky note's visual appearance.
@available(iOS 17.0, *)
class TitleView: UIView {
    var cardView: UIView!

    /// Convenience accessor to the StickyNoteView's parent StickyNoteEntity.
    weak var title: TitleEntity!
    
    /// Indicates whether the sticky note is currently inside of the trash zone.
    var isInTrashZone = false

    /// Indicates whether the placeholder text has been removed.
    var placeHolderWasRemoved = false

    /// States to indicate the current offset between the panning finger and the StickNoteView's origin, used for smooth panning.
    var xOffset: CGFloat = 0
    var yOffset: CGFloat = 0

    /// Stores the most recent non-editing frame of the StickyNoteView
    var lastFrame: CGRect!

    /// Creates a StickyNoteView given the specified frame and its associated StickyNoteEntity.
    init(frame: CGRect, title: TitleEntity) {
        super.init(frame: frame)

        let vc = UIHostingController(rootView: ARCardUIView(info:title.info))

        cardView = vc.view!
        
        cardView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(cardView)

        // 3
        // Create and activate the constraints for the swiftui's view.
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: centerYAnchor),
            cardView.heightAnchor.constraint(equalTo: heightAnchor),
            cardView.widthAnchor.constraint(equalTo: widthAnchor)
            ])

        self.title = title

        lastFrame = frame
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
