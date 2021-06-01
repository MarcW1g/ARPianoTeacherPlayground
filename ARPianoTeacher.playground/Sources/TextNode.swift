
//
// TextNode.swift
//
// Created by Marc Wiggerman
//

import ARKit

/// SceneKit Node representing text
public class TextNode: SCNNode {
    
    // MARK: - Private Constants
    
    /// A glossy black material
    private let redMaterial: SCNMaterial = {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.systemRed
        material.emission.intensity = 1.0
        material.emission.contents = UIColor.systemRed
        material.lightingModel = .physicallyBased
        return material
    }()
    
    // MARK: - Initialization
    
    /// Set up the text node using a specified text string
    /// - Parameter text: The text for the node
    public convenience init(text: String) {
        self.init()
        
        // Add the text to the node
        addText(text)
    } 
    
    // MARK: - Setup
    
    /// Sets the geometry of the node
    /// - Parameter text: The text that is displayed by the node
    private func addText(_ text: String) {
        // Create the geometry
        let textGeometry = SCNText(string: text, extrusionDepth: 1)
        textGeometry.font = UIFont(name: "Baskerville", size: 15)
        textGeometry.flatness = 0.2
        
        // Set the material
        textGeometry.firstMaterial = redMaterial
        
        // Set the cylinder shape as the main geometry of the node
        geometry = textGeometry
    }
}
