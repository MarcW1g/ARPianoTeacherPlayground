//
// ModelLibrary.swift
//
// Created by Marc Wiggerman
//

import ARKit

/// A class containing all the custom nodes available in the Notes Scene
public class ModelLibrary {
    /// The scene containing all the custom nodes
    public static let noteScene = SCNScene(named: "NotesScene.scn")
    
    /// A node representing a G Clef
    public static let gClefNode = noteScene?.rootNode.childNode(withName: "gClef", recursively: true)
    
    /// A node representing a simple note
    public static let noteNode = noteScene?.rootNode.childNode(withName: "note", recursively: true)
    
    /// A node representing a sharp icon
    public static let sharpNode = noteScene?.rootNode.childNode(withName: "sharp", recursively: true)
    
    /// A node representing a flat icon
    public static let flatNode = noteScene?.rootNode.childNode(withName: "flat", recursively: true)
    
    /// A node representing a pointer telling the user "Tap to Add"
    public static let pointerNode = noteScene?.rootNode.childNode(withName: "pointer", recursively: true)
}
