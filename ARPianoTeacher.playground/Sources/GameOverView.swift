//
// GameOverView.swift
//
// Created by Marc Wiggerman
//

import UIKit

/// View representing the view presented on Game Over
public class GameOverView: UIView {
    
    // MARK: - Private View Constants
    
    /// A label presenting the "Game Over!" text
    private let gameOverLabel: UILabel = {
        let label = UILabel()
        label.text = "Game Over!"
        label.font = UIFont(name: "Baskerville-SemiBold", size: 35)
        label.textColor = .white
        label.textAlignment = .center
        
        // Add a shadow to improve the contrast with the background
        label.layer.shadowColor = UIColor.red.cgColor
        label.layer.shadowRadius = 0
        label.layer.shadowOpacity = 1
        label.layer.shadowOffset = CGSize(width: 1, height: 1)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// A label presenting the score
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.text = "Score: 0"
        label.font = UIFont(name: "Baskerville-SemiBold", size: 25)
        label.textColor = .white
        label.textAlignment = .center
        
        // Add a shadow to improve the contrast with the background
        label.layer.shadowColor = UIColor.blue.cgColor
        label.layer.shadowRadius = 0
        label.layer.shadowOpacity = 1
        label.layer.shadowOffset = CGSize(width: 1, height: 1)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// A label presenting the message telling the user to tap the screen to restart the game
    private let tapToRestartLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap to Restart!"
        label.font = UIFont(name: "Baskerville-SemiBold", size: 25)
        label.textColor = .white
        label.textAlignment = .center
        
        // Add a shadow to improve the contrast with the background
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 0
        label.layer.shadowOpacity = 1
        label.layer.shadowOffset = CGSize(width: 1, height: 1)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// The main vertical stack view containing the labels
    public let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis  = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    // MARK: - Setup
    
    /// Adds all subviews to the Game Over view using a stack view
    private func setupSubviews() {
        addSubview(stackView)
        
        // Add the views to the stack view
        stackView.addArrangedSubview(gameOverLabel)
        stackView.addArrangedSubview(scoreLabel)
        stackView.addArrangedSubview(tapToRestartLabel)
        
        // Create and set the constraints
        let gameOverLabelConstraints = [
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
        ]

        NSLayoutConstraint.activate(gameOverLabelConstraints)
    }
    
    // MARK: - Controls

    /// Set the score in the score label
    public func setScore(_ score: Int) {
        scoreLabel.text = "Score: \(score)"
    }
    
    /// Show the game over view (animated)
    public func show() {
        alpha = 0.0
        isHidden = false
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) { [weak self] in 
            self?.alpha = 1.0
        }
    }
    
    /// Hide the game over view
    /// - Parameter animated: Boolean indicating if the hide action should be animated
    public func hide(animated: Bool) {
        if !animated {
            isHidden = true
            return
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) { [weak self] in 
            self?.alpha = 0.0
        } completion: { [weak self] (_) in
            self?.isHidden = true
        }
    }
}
