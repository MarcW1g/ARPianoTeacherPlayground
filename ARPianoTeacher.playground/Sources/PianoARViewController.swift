//
// PianoARViewController.swift
//
// Created by Marc Wiggerman
//

import UIKit
import ARKit

/// A view controller presenting both the ARView and the Piano View
public class PianoARViewController: UIViewController {
    
    // MARK: - Private View Constants
    
    /// An ARView for the Piano Game
    private let gameARSCNView: GameARSCNView = {
        let sceneView = GameARSCNView()
        sceneView.autoenablesDefaultLighting = true
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        return sceneView
    }()
    
    /// A view representing the piano
    public let pianoView: PianoView = {
        let pianoView = PianoView()
        pianoView.translatesAutoresizingMaskIntoConstraints = false
        return pianoView
    }()
    
    /// A view representing the bar containing additional game information
    private let gameControlBar: GameControlBarView = {
        let gameControlBar = GameControlBarView()
        gameControlBar.translatesAutoresizingMaskIntoConstraints = false
        return gameControlBar
    }()
    
    /// A label containing the text indicating the user to tap the screen to start
    private let tapToStartLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap to Start!\n\nPress the key of the correct note when it is at the blue bar!"
        label.numberOfLines = 0
        label.font = UIFont(name: "Baskerville-SemiBold", size: 25)
        label.textColor = .white
        label.textAlignment = .center
        
        // Add a shadow to add contrast with the camera feed
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 0
        label.layer.shadowOpacity = 1
        label.layer.shadowOffset = CGSize(width: 1, height: 1)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// A view containing the information shown when the game is over
    private var gameOverView: GameOverView = {
        let gameOverView = GameOverView()
        gameOverView.translatesAutoresizingMaskIntoConstraints = false
        return gameOverView
    }()
    
    // MARK: - Private Variables
    
    /// A variable holding the game controller used to control the game
    private var gameController: GameController?
    
    // MARK: -  View Events
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add all subviews
        addGameControlBar()
        addARSceneView()
        addPianoView()
        addGameOverView()
        addTapToStartLabel()
        
        // Disable the keys at start
        pianoView.disableKeys()
        
        // Create a game controller
        createGameController()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Start the AR Session
        startARSession()
        
        // Start the AR experience
        gameARSCNView.startAR()
    }
    
    // MARK: - Methods adding subviews
    
    /// Adds the Control Bar to the view hierarchy
    private func addGameControlBar() {
        view.addSubview(gameControlBar)
        
        // Create and add the constraints
        let gameControlBarConstraints = [
            gameControlBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gameControlBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gameControlBar.topAnchor.constraint(equalTo: view.topAnchor),
            gameControlBar.heightAnchor.constraint(equalToConstant: 60)
        ]
        
        NSLayoutConstraint.activate(gameControlBarConstraints)
    }
    
    /// Adds the main AR scene view to the view hierarchy
    private func addARSceneView() {
        view.addSubview(gameARSCNView)
        
        // Create and add the constraints
        let arSceneViewConstraints = [
            gameARSCNView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gameARSCNView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gameARSCNView.topAnchor.constraint(equalTo: gameControlBar.bottomAnchor),
            gameARSCNView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6)
        ]
        
        NSLayoutConstraint.activate(arSceneViewConstraints)

        let sceneTapGesture = UITapGestureRecognizer(target: self, action: #selector(sceneTouched))
        gameARSCNView.addGestureRecognizer(sceneTapGesture)
    }
    
    /// Adds the Piano view to the view hierarchy
    private func addPianoView() {
        view.addSubview(pianoView)
        
        // Create and add the constraints
        let pianoViewConstraints = [
            pianoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pianoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pianoView.topAnchor.constraint(equalTo: gameARSCNView.bottomAnchor),
            pianoView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(pianoViewConstraints)
    }
    
    /// Adds the Game Over view to the view hierarchy
    private func addGameOverView() {
        // Make sure the view is hidden when it is added to the view
        gameOverView.hide(animated: false)
        view.addSubview(gameOverView)

        // Create and add the constraints
        let gameOverViewConstraints = [
            gameOverView.centerXAnchor.constraint(equalTo: gameARSCNView.centerXAnchor),
            gameOverView.centerYAnchor.constraint(equalTo: gameARSCNView.centerYAnchor),
        ]
        
        NSLayoutConstraint.activate(gameOverViewConstraints)
    }
    
    /// Adds the tap to start label to the view hierarchy
    private func addTapToStartLabel() {
        // Make sure the view is hidden when it is added to the view
        tapToStartLabel.isHidden = true
        view.addSubview(tapToStartLabel)
        
        // Create and add the constraints
        let tapToStartLabelConstraints = [
            tapToStartLabel.leadingAnchor.constraint(equalTo: gameARSCNView.leadingAnchor, constant: 40),
            tapToStartLabel.topAnchor.constraint(equalTo: gameARSCNView.topAnchor, constant: 40),
            tapToStartLabel.trailingAnchor.constraint(equalTo: gameARSCNView.trailingAnchor, constant: -20),
            tapToStartLabel.bottomAnchor.constraint(equalTo: gameARSCNView.bottomAnchor, constant: -20),
        ]
        
        NSLayoutConstraint.activate(tapToStartLabelConstraints)
    }

    // MARK: - AR
    
    /// Starts the AR Session in the AR View
    private func startARSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.worldAlignment = .gravity
        configuration.environmentTexturing = .automatic
        gameARSCNView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // MARK: - Control Handlers
   
    /// Handles touches and selects the appropriate action based on the current game state
    @objc private func sceneTouched() {
        // Check if we have an active game controller
        guard let gameController = gameController else { return }
        
        // Change the action depending on the current game state
        switch gameController.gameState {
        case .initializing:
            // Add the AR Elements like the staff to the AR View
            gameARSCNView.tryAddingMainARElements(completion: { [weak self] (success) in
                if success {
                    // Change the game state and show this to the user
                    gameController.gameState = .readyToStart
                    self?.showStartLabel()
                }
            })
        case .readyToStart:
            // Start the game by enabling the piano keys, and calling start on the game controller
            pianoView.enableKeys()
            gameController.start()
            hideStartLabel()
        case .playing:
            // While playing we ignore touches
            break
        case .gameOver:
            // Restart the game
            gameOverView.hide(animated: true)
            pianoView.enableKeys()
            gameControlBar.resetLives()
            gameControlBar.setScore(newScore: 0)
            gameController.resetData()
            gameController.start()
        }
    }
    
    // MARK: - UI Helpers
    
    /// Hides the start label (animated)
    private func hideStartLabel() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn) { [weak self] in
            self?.tapToStartLabel.alpha = 0
        } completion: { [weak self] _ in
            self?.tapToStartLabel.isHidden = true
        }
    }
    
    /// Presents the start label (animated)
    private func showStartLabel() {
        tapToStartLabel.alpha = 0
        tapToStartLabel.isHidden = false
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn) { [weak self] in
            self?.tapToStartLabel.alpha = 1
        }
    }
}

// MARK: - GameControllable

extension PianoARViewController: GameControllable {
    /// Create an instance of the Game Controller and safe it in the object
    private func createGameController() {
        gameController = GameController(sceneView: gameARSCNView)
        gameController!.delegate = self
        
        // Set the piano view delegate to be the controller to let it handle key presses
        pianoView.delegate = gameController!
    }
    
    /// Score is updated by the controller
    public func scoreDidUpdate(newScore: Int) {
        // Update the UI
        gameControlBar.setScore(newScore: newScore)
    }
    
    /// Called when the score is updated
    /// - Parameter newScore: The new score of the game
    public func didLoseOneLife(number: Int) {
        // Update the UI
        gameControlBar.removeLife(number)
    }
    
    /// Called when the game is over
    public func gameOver() {
        // Check if we have a controller, and that the controller has a score
        guard let gameController = gameController,
              let score = gameController.gameData?.score else { return }
        
        // Set the score data in the game over view
        gameOverView.setScore(score)
        gameOverView.show()
        
        // Present the game over view
        gameController.stop()
        
        // Disable the keys
        pianoView.disableKeys()
    }
}
