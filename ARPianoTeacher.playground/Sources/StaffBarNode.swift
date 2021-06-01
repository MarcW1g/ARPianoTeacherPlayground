//
// StaffBarNode.swift
//
// Created by Marc Wiggerman
//

import ARKit

/// SceneKit Node representing one bar of the notes staff
public class StaffBarNode: SCNNode {
    
    // MARK: - Private Constants
    
    /// A glossy black material
    private let blackMaterial: SCNMaterial = {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.black
        material.roughness.contents = 0.0
        material.lightingModel = .physicallyBased
        return material
    }()
    
    // MARK: - Private Variables
    
    /// The SCNCylinder used in the node
    private var cylinder: SCNCylinder = SCNCylinder(radius: 0.001, height: 0)
    
    /// The length of the horizontal cylinder
    private var length: CGFloat = 1.0
    
    // MARK: - Initialization
    
    /// Set up the staff bar using a specified length
    /// - Parameter length: The length of the staff bar
    public convenience init(length: CGFloat) {
        self.init()
        
        // Set the length
        self.length = length
        
        // Add the cylinder shape to the node
        addShape()
    } 

    // MARK: - Setup
    
    /// Sets the geometry of the node
    private func addShape() {
        // Set the material to the glossy black
        cylinder.firstMaterial = blackMaterial
        
        // Set the cylinder shape as the main geometry of the node
        geometry = cylinder
        
        // Rotate the node such that is horizontally laid out
        self.rotation = SCNVector4Make(0, 0, 1, .pi / 2)
    }
    
    // MARK: - Visibility
    
    /// Animates the cylinder to the full length (animated)
    public func changeShape() {
        SCNTransaction.animationDuration = 1.0
        cylinder.height = length
    }
}
