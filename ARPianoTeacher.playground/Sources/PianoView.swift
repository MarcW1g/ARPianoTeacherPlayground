//
// PianoView.swift
//
// Created by Marc Wiggerman
//

import UIKit

/// Protocol implemented by an object wanting to control the piano
public protocol PianoControllable {
    /// Called when a key is pressed by the user
    /// - Parameter note: The note of the pressed key
    func pressedKey(note: Note)
}

/// The type of keys on a piano
public enum KeyType {
    case black
    case white
}

/// The View containing all the views to represent the piano
public class PianoView: UIView {
    
    // MARK: - Private View Constants
    
    /// The top bar of the piano containing some controls
    private let pianoTopBar: PianoTopBar = {
        let pianoTopBar = PianoTopBar()
        pianoTopBar.translatesAutoresizingMaskIntoConstraints = false
        return pianoTopBar
    }()
    
    /// The main horizontal stack view containing the white keys
    public let horizontalKeyStackView: UIStackView = {
        let horizontalStackView = UIStackView()
        horizontalStackView.axis  = .horizontal
        horizontalStackView.distribution = .fillEqually
        horizontalStackView.alignment = .center
        horizontalStackView.spacing = 2
        horizontalStackView.layoutMargins = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        horizontalStackView.isLayoutMarginsRelativeArrangement = true
        horizontalStackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return horizontalStackView
    }()
    
    // MARK: - Private Variables
    
    /// An array containing the views of each individual key
    private var allKeyViews = [Note: KeyView]()
    
    // MARK: - Public Variables
    /// The delegate for the keys
    public var delegate: PianoControllable? {
        didSet {
            // Reset the delegates of all key views
            allKeyViews.forEach {
                $0.value.delegate = delegate
            }
        }
    }
    
    // MARK: - Initialization
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Setup
    
    /// Sets the view properties and starts the process of adding the subviews
    private func setupView() {
        // Set the background color to be like a real piano with velvet on the inside
        backgroundColor = .darkRedVelvet
        
        // Add the key views and the top bar
        addKeys()
        addVerticalTopBar()
    }
    
    /// Add all the subviews representing the keys to the view
    private func addKeys() {
        // First we add the white keys, after which we use their locations to add the black keys
        addWhiteKeys()
        addBlackKeys()
    }
    
    /// Add all white keys to the stack view
    private func addWhiteKeys() {
        // Add the horizontal stack view to the piano view
        addSubview(horizontalKeyStackView)

        // Loop over all base notes to create the white keys
        for note in Note.baseNotesInOrder {
            // Create a new key view
            let keyView = KeyView(keyType: .white, note: note)
            allKeyViews[note] = keyView
            horizontalKeyStackView.addArrangedSubview(keyView)

            // Add a single top constraint to the key view
            keyView.translatesAutoresizingMaskIntoConstraints = false
            let keyConstraints = [
                keyView.topAnchor.constraint(equalTo: self.topAnchor),
            ]
            NSLayoutConstraint.activate(keyConstraints)
        }
    }
    
    /// Add all black keys to the piano view
    public func addBlackKeys() {
        // To simplify the process, we will only add the sharp notes (as they are the same as the flat notes)
        // This will cause that the pressed key will be associated with the sharp note and that we have
        // to add the logic to convert the note to the flat version somewhere else
        let sharpNotes = Note.sharpNotesInOrder
        
        // Get all the leading notes for each sharp note. These can be used an an anchor for the new key view
        let leadingNotes = sharpNotes.compactMap { $0.leadingNote() }
        
        for (sharpNote, leadingNote) in zip(sharpNotes, leadingNotes) {
            // Get the view of the leading note
            guard let leadingKeyView = allKeyViews[leadingNote] else { continue }
            
            // Create a new key view and add it to the view hierarchy
            let blackKeyView = KeyView(keyType: .black, note: sharpNote)
            blackKeyView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(blackKeyView)
            
            // Add the key to the dict
            allKeyViews[sharpNote] = blackKeyView
            
            // Set the constraints
            // Here we use the view of the leading note as an anchor point
            let keyConstraints = [
                blackKeyView.centerXAnchor.constraint(equalTo: leadingKeyView.trailingAnchor),
                blackKeyView.topAnchor.constraint(equalTo: leadingKeyView.topAnchor),
                blackKeyView.heightAnchor.constraint(equalTo: leadingKeyView.heightAnchor, multiplier: 0.7),
                blackKeyView.widthAnchor.constraint(equalTo: leadingKeyView.widthAnchor, multiplier: 0.7)
            ]
            
            NSLayoutConstraint.activate(keyConstraints)
        }
    }
    
    /// Add the top bar to the view and set the delegate to be this view
    private func addVerticalTopBar() {
        // Set the delegate
        pianoTopBar.delegate = self
        
        // Add the view to the view hierarchy
        addSubview(pianoTopBar)
        
        // Set the constraints (i.e. at the top of the view)
        let pianoTopBarConstraints = [
            pianoTopBar.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            pianoTopBar.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            pianoTopBar.topAnchor.constraint(equalTo: self.topAnchor),
            pianoTopBar.heightAnchor.constraint(equalToConstant: 50)
        ]

        NSLayoutConstraint.activate(pianoTopBarConstraints)
    }
    
    // MARK: - Public UI Methods
    
    /// Activate user interaction for the piano keys
    public func enableKeys() {
        // Set the user interaction
        horizontalKeyStackView.isUserInteractionEnabled = true
        
        // The black keys have to be done individually
        Note.sharpNotes.forEach { [weak self] note in
            self?.allKeyViews[note]?.isUserInteractionEnabled = true
        }
        
        // Animate the state
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) { [weak self] in
            self?.horizontalKeyStackView.alpha = 1.0
        }
    }
    
    /// Disable user interaction for the piano keys
    public func disableKeys() {
        // Set the user interaction
        horizontalKeyStackView.isUserInteractionEnabled = false
        
        // The black keys have to be done individually
        Note.sharpNotes.forEach { [weak self] note in
            self?.allKeyViews[note]?.isUserInteractionEnabled = false
        }
        
        // Animate the state
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) { [weak self] in
            self?.horizontalKeyStackView.alpha = 0.7
        }
    }
}

extension PianoView: PianoTopBarProtocol {
    /// Toggles the note labels on the key views
    /// - Parameter newState: The new state of the note labels
    public func toggleNoteLabels(_ newState: Bool) {
        if newState {
            // Show the labels
            for key in allKeyViews.values {
                key.enableLabel()
            }
        } else {
            // Hide the labels
            for key in allKeyViews.values {
                key.disableLabel()
            }
        }
    }
}

