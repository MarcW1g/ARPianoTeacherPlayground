//
// PianoTopBar.swift
//
// Created by Marc Wiggerman
//

import UIKit

/// Protocol implemented by an object wanting to receive changes in the top bar
public protocol PianoTopBarProtocol {
    /// Toggles the note labels on the key views
    /// - Parameter newState: The new state of the note labels
    func toggleNoteLabels(_ newValue: Bool)
}

/// The view containing all views representing the piano top bar
public class PianoTopBar: UIView {
    
    // MARK: - Private View Constants
    
    /// A label presenting the logo of the piano
    private let logoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "HoeflerText-Italic", size: 20)
        label.textColor = .gold
        label.text = "Swift & Sons"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// A switch in the top bar
    private let noteLabelSwitch: UISwitch = {
        let noteLabelSwitch = UISwitch()
        noteLabelSwitch.onTintColor = UIColor(white: 0.6, alpha: 1)
        noteLabelSwitch.setOn(true, animated: false)
        return noteLabelSwitch
    }()
    
    /// A label for the switch
    private let noteLabelSwitchLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Baskerville", size: 15)
        label.textColor = .white
        label.text = "Toggle Labels:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Public Variables
    
    /// The delegate of the top bar
    public var delegate: PianoTopBarProtocol?
    
    // MARK: - Initialization
    
    init() {
        super.init(frame: .zero)
        setupBar()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBar()
    }
    
    // MARK: - Setup
    
    /// Sets up the complete top bar
    private func setupBar() {
        // Set the background and shadow properties
        backgroundColor = .black
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 20
        
        // Add all subviews
        addLogoLabel()
        addToggle()
    }
    
    /// Adds the logo at the middle of the top bar
    private func addLogoLabel() {
        // Add the view to the view hierarchy
        addSubview(logoLabel)
        
        // Set the constraints
        let centerXConstraint = NSLayoutConstraint(item: logoLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYConstraint = NSLayoutConstraint(item: logoLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: logoLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100)
        
        addConstraints([centerXConstraint, centerYConstraint, widthConstraint])
    }
    
    /// Adds the toggle and its corresponding label to the top bar
    private func addToggle() {
        // Set the target
        noteLabelSwitch.addTarget(self, action: #selector(labelToggleValueChanged(_:)), for: .valueChanged)
        
        // Put the label and the toggle in a horizontal stack view
        let horizontalStackView = UIStackView(arrangedSubviews: [noteLabelSwitchLabel, noteLabelSwitch])
        horizontalStackView.axis  = .horizontal
        horizontalStackView.distribution = .fillEqually
        horizontalStackView.alignment = .center
        horizontalStackView.spacing = 5
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the stack view to the view hierarchy
        addSubview(horizontalStackView)
        
        // Set the constraints
        let leadingConstraint = NSLayoutConstraint(item: horizontalStackView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 10)
        let trailingConstraint = NSLayoutConstraint(item: horizontalStackView, attribute: .trailing, relatedBy: .equal, toItem: logoLabel, attribute: .leading, multiplier: 1, constant: -10)
        let centerYConstraint = NSLayoutConstraint(item: horizontalStackView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        
        addConstraints([leadingConstraint, trailingConstraint, centerYConstraint])
    }
    
    // MARK: - Targets
    
    /// Notifies the delegate of this view of changes in the toggle
    /// - Parameter sender: The sender UISwitch
    @objc private func labelToggleValueChanged(_ sender: UISwitch) {
        delegate?.toggleNoteLabels(sender.isOn)
    }
}
