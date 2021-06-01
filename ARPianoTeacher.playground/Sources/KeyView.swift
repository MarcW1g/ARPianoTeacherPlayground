//
// KeyView.swift
//
// Created by Marc Wiggerman
//

import UIKit

/// A view representing a single white or black key
public class KeyView: UIView {
    
    // MARK: - Private View Constants
    
    /// The label containing the note of the key
    private let noteLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Baskerville-SemiBold", size: 15)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Private Constants
    
    /// The key type of this key (either white or black)
    private let keyType: KeyType
    
    /// The note attached to the key
    private let note: Note
    
    // MARK: - Public Variables
    
    /// The delegate of this key (used to indicate when the key is pressed)
    public var delegate: PianoControllable?


    // MARK: - Initialization
    
    /// Create a new Key View using a key type and note
    /// - Parameters:
    ///   - keyType: The type of the key. Either .black or .white
    ///   - note: The note which has to be assigned to the key
    init(keyType: KeyType, note: Note) {
        self.keyType = keyType
        self.note = note
        super.init(frame: .zero)
        setupKey()
    }
    
    public required init?(coder: NSCoder) {
        // Set the key to basic properties
        self.keyType = .white
        self.note = .A
        super.init(coder: coder)
        setupKey()
    }
    
    // MARK: - Touches
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Notify the delegate of the key press
        delegate?.pressedKey(note: note)
        
        // Change the background color to represent the pressed state
        switch (keyType) {
        case .white:
            backgroundColor = UIColor(white: 0.8, alpha: 1)
        case .black:
            backgroundColor = UIColor(white: 0.1, alpha: 1)
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Change the background color to represent the pressed state
        switch (keyType) {
        case .white:
            backgroundColor = .white
        case .black:
            backgroundColor = .black
        }
    }
    
    // MARK: - Setup

    /// Sets up the UI of the key
    private func setupKey() {
        // Set the corner radius
        layer.cornerRadius = 5
        layer.cornerCurve = .continuous
        
        // Add the note label to the key
        addNoteLabel()
        
        // Set the color and shadow depending on the key type
        switch keyType {
        case .white:
            backgroundColor = .white
            noteLabel.textColor = .black
        case .black:
            backgroundColor = .black
            noteLabel.textColor = .white
            
            // Add a shadow
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.6
            layer.shadowOffset = CGSize(width: 2, height: 2)
            layer.shadowRadius = 2
        }
    }
    
    /// Adds the note label to the bottom middle of the key view
    private func addNoteLabel() {
        // Set the text of the label
        switch(keyType) {
        case .white:
            noteLabel.text = note.rawValue
        case .black:
            noteLabel.text = "\(note.rawValue)/\(note.flatVersion()!.rawValue)"
        }
        
        // Add the label to the view hierarchy
        addSubview(noteLabel)

        // Create and set the constraints
        let noteLabelConstraints = [
            noteLabel.heightAnchor.constraint(equalToConstant: 100),
            noteLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 10),
            noteLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            noteLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10)
        ]

        NSLayoutConstraint.activate(noteLabelConstraints)
    }
    
    // MARK: - Note Label States
    
    /// Shows the note label (animated)
    public func enableLabel() {
        noteLabel.isHidden = false
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) { [weak self] in
            self?.noteLabel.alpha = 1.0
        }
    }
    
    /// Hides the note label (animated)
    public func disableLabel() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) { [weak self] in
            self?.noteLabel.alpha = 0.0
        } completion: { [weak self] _ in
            self?.noteLabel.isHidden = false
        }
    }
}
