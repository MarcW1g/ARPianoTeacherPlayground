//
// PlacementGuide.swift
//
// Created by Marc Wiggerman
//

import ARKit

/// The node representing the guide used to guide the user with
/// correctly placing the AR scene
public class PlacementGuide: SCNNode {
    /// The state of the placement guide during the session
    public enum State: Equatable {
        case initializing
        case detecting(raycastResult: ARRaycastResult)
    }
    
    // MARK: - Private Constants
    
    /// The main node for the placement guide
    private let guideNode: SCNNode = SCNNode()

    // MARK: - Private Variables
    
    /// The most recent locations provided to the node
    /// This value is kept for a smoother positioning
    private var recentPositions = [SIMD3<Float>]()
    
    /// Boolean indicating if the node is hidden
    private var nodeIsHidden: Bool = false
    
    // MARK: - Public Variables
    
    /// The current state of the placement guide
    public var state: State = .initializing {
        didSet {
            // Check if the state did change
            guard state != oldValue else { return }

            switch state {
            case .initializing:
                // We cannot find a plane so we hide the node
                hide()
            case let .detecting(raycastResult):
                // If we found a plane we will correctly place the node
                if let _ = raycastResult.anchor as? ARPlaneAnchor {
                    show()
                    setPosition(with: raycastResult)
                }
            }
        }
    }
    
    /// The current location of the guide node
    /// - Note: Only returns the position if the node is placed on a surface
    public var latestPosition: SIMD3<Float>? {
        switch state {
        case .initializing: return nil
        case .detecting(let raycastResult):
            return raycastResult.worldTransform.translation
        }
    }
    
    /// The current rotation of the guide node
    /// - Note: Only returns the position if the node is placed on a surface
    public var latestRotation: simd_quatf? {
        switch state {
        case .initializing: return nil
        case .detecting(let raycastResult):
            return raycastResult.worldTransform.orientation
        }
    }
    
    // MARK: - Initialization

    /// Create a new placement guide
    /// - Parameter startsHidden: Boolean to indicate if the guide should be hidden after load
    public convenience init(startsHidden: Bool) {
        self.init()
        
        // Add the indicator Node
        addIndicator()
        
        nodeIsHidden = startsHidden
        if startsHidden {
            // Set the current state of the node to be hidden
            opacity = 0
        }
    }
    
    // MARK: - Setup
    
    /// Sets the geometry of the node
    private func addIndicator() {
        // Get the pointer node
        guard let pointerNode = ModelLibrary.pointerNode else { return }
        
        // Set the current location and rotation
        pointerNode.position = SCNVector3Make(0, 0, 0)
        pointerNode.rotation = SCNVector4Make(0, 1, 0, .pi / 2)
        
        // Add the pointer node as the child node
        addChildNode(pointerNode)
    }
    
    // MARK: - Visibility and positioning
    
    /// Hides the node
    public func hide() {
        // Check if the node is not already hidden, and if the fade out action is not currently running
        guard !nodeIsHidden,
              action(forKey: "hide") == nil else { return }
        
        // Set the state
        nodeIsHidden = true
        
        // Run the fade out animation
        runAction(.fadeOut(duration: 0.2), forKey: "hide")
    }
    
    /// Shows (unhides) the node
    public func show() {
        // Check if the node is not already shown, and if the fade in action is not currently running
        guard nodeIsHidden,
              action(forKey: "show") == nil else { return }
        
        // Set the state
        nodeIsHidden = false
        
        // Run the fade out animation
        runAction(.fadeIn(duration: 0.2), forKey: "show")
    }
    
    /// Set the current position of the node using a raycast results
    /// - Parameter raycastResult: The raycast result used to set the new position of the node
    /// - Note: The positions are accumulated and averaged before the node is relocated
    public func setPosition(with raycastResult: ARRaycastResult) {
        // Get the translation from the raycast result
        let newPosition = raycastResult.worldTransform.translation
        
        // Add it to the recent positions list
        recentPositions.append(newPosition)
        
        // Update the position of the node
        updatePosition()
            
        // Update the rotation of the node
        self.simdOrientation = raycastResult.worldTransform.orientation
    }
    
    /// Updates the position of the node
    private func updatePosition() {
        // Get the 10 most recent positions, and cut off others
        recentPositions = Array(recentPositions.suffix(10))

        // Average the 10 most recent positions
        let recentPositionsCount = recentPositions.count
        let averagePosition = recentPositions.reduce([0, 0, 0], { $0 + $1 }) / Float(recentPositionsCount)

        // Set the position
        self.simdPosition = averagePosition
    }
}
