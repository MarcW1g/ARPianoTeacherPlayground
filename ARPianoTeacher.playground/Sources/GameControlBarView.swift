//
// GameContrBarView.swift
//
// Created by Marc Wiggerman
//

import UIKit

/// A bar showing the current score and the number of lives left
public class GameControlBarView: UIView {
    
    // MARK: - Private View Constants
    
    /// A label containing the score value
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textColor = .systemYellow
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// A horizontal stack to keep the score views
    private let scoreStackView: UIStackView = {
        let horizontalStackView = UIStackView()
        horizontalStackView.axis  = .horizontal
        horizontalStackView.distribution = .fillProportionally
        horizontalStackView.alignment = .leading
        horizontalStackView.spacing = 5
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        return horizontalStackView
    }()
    
    /// A label to be used before the score display
    private let scoreLabelLabel: UILabel = {
        let label = UILabel()
        label.text = "Score:"
        label.font = UIFont(name: "Baskerville-SemiBold", size: 15)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// A label to be used before the life display
    private let livesLabel: UILabel = {
        let label = UILabel()
        label.text = "Lives:"
        label.font = UIFont(name: "Baskerville-Bold", size: 15)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Private Variables
    
    /// The total amount of lives presented
    private let nrOfLives = 3
    
    /// An array holding the views representing the lives
    private var lifeViews = [Int: UIView]()
    
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
    
    /// Configures the view and adds the subviews
    private func setupView() {
        backgroundColor = .black
        
        // Add the subviews
        addScoreLabel()
        addLivesIndicator()
    }
    
    /// Add the score and score label to the view
    private func addScoreLabel() {
        // Add the views
        addSubview(scoreStackView)
        
        scoreStackView.addArrangedSubview(scoreLabelLabel)
        scoreStackView.addArrangedSubview(scoreLabel)
        
    
        // Configure and add the constrains
        let scoreStackViewConstraints = [
            scoreStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            scoreStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(scoreStackViewConstraints)
    }
    
    /// Adds the indicator showing the number of lives left
    private func addLivesIndicator() {
        // Variable to hold the anchor of the previous view (standard the training anchor of the view itself)
        var previousViewAnchor: NSLayoutAnchor = self.trailingAnchor
        
        // Add the life indicators
        for i in 1...nrOfLives {
            // Create the indicator
            let view = UIImageView(frame: .zero)
            view.image = UIImage(named: "heart_icon.png")
            view.contentMode = .scaleAspectFit
            view.translatesAutoresizingMaskIntoConstraints = false
            
            // Add it to the view
            addSubview(view)
            
            // Add it to the dict of views
            lifeViews[nrOfLives - i] = view
            
            // Configure and add the constraints
            let viewConstraints = [
                view.widthAnchor.constraint(equalToConstant: 30),
                view.heightAnchor.constraint(equalToConstant: 30),
                view.trailingAnchor.constraint(equalTo:previousViewAnchor, constant: -4),
                view.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ]
            
            NSLayoutConstraint.activate(viewConstraints)
            
            // Set the previous anchor to be the leading anchor of the just added view
            previousViewAnchor = view.leadingAnchor
        }
        
        // Add the lives label
        addSubview(livesLabel)
        
        // Configure and add the constraints
        let livesLabelConstraints = [
            livesLabel.trailingAnchor.constraint(equalTo: previousViewAnchor, constant: -10),
            livesLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(livesLabelConstraints)
    }
    
    /// Resets the life views
    public func resetLives() {
        // A small delay increasing with the number of life views
        var delay: TimeInterval = 0.0
        
        // Loop over the views from right to left
        for i in 0..<nrOfLives {
            // Get the view
            if let lifeView = lifeViews[i] {
                // Present it
                UIView.animate(withDuration: 0.5, delay: delay, options: .curveEaseOut) {
                    lifeView.alpha = 1
                }
                
                // Increase the delay
                delay += 0.2
            }
        }
    }
    
    /// Hides the right most life
    /// - Parameter number: The life number which will be removed
    public func removeLife(_ number: Int) {
        // Check if we do not want to remove a non-existing view
        guard number <= nrOfLives,
              let lifeView = lifeViews[number - 1] else { return }
        
        // Hide it
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut) {
            lifeView.alpha = 0
        }
    }
    
    
    /// Set the score used in the bar
    /// - Parameter newScore: The new score which will be presented
    public func setScore(newScore: Int) {
        scoreLabel.text = "\(newScore)"
    }
}
