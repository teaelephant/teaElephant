//
// Created by Andrew Khasanov on 22.01.2021.
//

import UIKit

/// A subclass of UIView that will be inserted into the scene in "Screen Space", that composes the sticky note's visual appearance.
class TitleView: UIView {
    var textView: UITextView!
    // ...

    /// Convenience accessor to the StickyNoteView's parent StickyNoteEntity.
    weak var title: TitleEntity!

    /// Subviews which are used to construct the StickyNoteView.
    var blurView: UIVisualEffectView!

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

        self.title = title

        setupBlurViewContainer()
        setupTextView()

        lastFrame = frame
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupBlurViewContainer() {
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurView)
        blurView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        blurView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        blurView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        blurView.layer.cornerRadius = 20
        blurView.layer.masksToBounds = true
    }

    fileprivate func setupTextView() {
        let paddingSpace: CGFloat = 10

        textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        blurView.contentView.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: paddingSpace),
            textView.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: paddingSpace),
            textView.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -paddingSpace),
            textView.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -paddingSpace)
        ])
        textView.backgroundColor = .clear
        textView.font = UIFont(name: "Helvetica", size: 20)
        textView.textAlignment = .center
        textView.text = title.text
        textView.textColor = .orange
    }

}
