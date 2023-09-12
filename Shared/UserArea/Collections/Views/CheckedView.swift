//
//  CheckedView.swift
//  TeaElephant
//
//  Created by Andrew Khasanov on 17/09/2023.
//

import UIKit
import SwiftUI

/// A subclass of UIView that will be inserted into the scene in "Screen Space", that composes the sticky note's visual appearance.
class CheckedView: UIView {
    var cardView: UIView!

    /// Convenience accessor to the StickyNoteView's parent StickyNoteEntity.
    weak var entity: CheckedEntity!
    
    /// States to indicate the current offset between the panning finger and the StickNoteView's origin, used for smooth panning.
    var xOffset: CGFloat = 0
    var yOffset: CGFloat = 0

    /// Stores the most recent non-editing frame of the StickyNoteView
    var lastFrame: CGRect!

    /// Creates a StickyNoteView given the specified frame and its associated StickyNoteEntity.
    init(frame: CGRect, entity: CheckedEntity) {
        super.init(frame: frame)

        let vc = UIHostingController(rootView: CheckedUIView())

        cardView = vc.view!
        cardView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
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

        self.entity = entity

        lastFrame = frame
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
