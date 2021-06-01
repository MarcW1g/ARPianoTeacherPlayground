//
// CurrentNoteLineNode.swift
//
// Created by Marc Wiggerman
//

import ARKit

public class CurrentNoteLineNode: SCNNode {
    
    // MARK: - Private Constants
    
    /// A glowing material for the bar
    private var glowingMaterial: SCNMaterial = {
        let color = UIColor.systemBlue
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.emission.intensity = 1.0
        material.emission.contents = color
        material.lightingModel = .physicallyBased
        return material
    }()
    
    // MARK: - Private Variables
    
    /// The height of the bar
    private var height: CGFloat = 1
    
    /// The radius of the bar
    private var radius: CGFloat = 0.1
    
    /// The cylinder
    private var cylinder: SCNCylinder?
    
    // MARK: - Initialization

    /// Set up the bar with a specified height and radius
    /// - Parameters:
    ///   - height: The height of the geometry
    ///   - radius: The radius of the geometry
    public convenience init(height: CGFloat, radius: CGFloat) {
        self.init()
        
        // Set the height and radius of the object
        self.height = height
        self.radius = radius
        
        // Add the cylinder shape
        addShape()
    }
    
    // MARK: - Setup
    
    /// Adds the shape for the current note line node
    private func addShape() {
        // Create a cylinder and set its material
        cylinder = SCNCylinder(radius: radius, height: 0)
        cylinder!.firstMaterial = glowingMaterial
        
        // Set the geometry of the node
        geometry = cylinder!
    }
    
    /// Animates the cylinder to the full height (animated)
    public func changeShape() {
        guard let cylinder = cylinder else { return }
        SCNTransaction.animationDuration = 1.0
        cylinder.height = height
    }
    
    // MARK: - Color Control
    
    /// Set the material to the basic color
    public func setMaterialDefault() {
        setMaterialToColor(UIColor.systemBlue)
    }
    
    /// Set the material color to green
    public func setMaterialGreen() {
        setMaterialToColor(UIColor.systemGreen)
    }
    
    /// Set the material color to red
    public func setMaterialRed() {
        setMaterialToColor(UIColor.systemRed)
    }
    
    /// Sets the material color to the specified color
    /// - Parameter color: The new color of the bar
    private func setMaterialToColor(_ color: UIColor) {
        geometry?.firstMaterial?.diffuse.contents = color
        geometry?.firstMaterial?.emission.contents = color
    }
}
