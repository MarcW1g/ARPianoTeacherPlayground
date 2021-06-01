//
// NoteNode.swift
//
// Created by Marc Wiggerman
//

import ARKit

/// SceneKit Node representing text
public class NoteNode: SCNNode {
    
    // MARK: - Public Constants
        
    /// The note for the node
    public private(set) var note: Note = .C
    
    /// The octave for the node
    public private(set) var octave: Int = 0
    
    // MARK: - Initialization
    
    /// Set up the Note Node
    /// - Parameters:
    ///   - note: The note of the node
    ///   - octave: The octave of the node
    public convenience init(note: Note, octave: Int) {
        self.init()
        
        // Set the node and octave
        self.note = note
        self.octave = octave
        
        // Add the Note nodes to the node
        addNoteNodes()
    }
    
    // MARK: - Setup
    
    /// Sets the child nodes of this node
    private func addNoteNodes() {
        // Clone a note Node from the note scene
        guard let noteNode = ModelLibrary.noteNode?.clone() else { return }
        
        // Add the note
        noteNode.position = SCNVector3Make(0, 0, 0)
        addChildNode(noteNode)
        
        // Check if a sign should be added (O(1) lookup due to set)
        if Note.sharpNotes.contains(note),
           let sharpNode = ModelLibrary.sharpNode?.clone() {
            // Add a sharp icon node
            sharpNode.position = SCNVector3Make(-0.01, 0, 0)
            addChildNode(sharpNode)
        } else if Note.flatNotes.contains(note),
                  let flatNode = ModelLibrary.flatNode?.clone() {
            // Add a flat icon node
            flatNode.position = SCNVector3Make(-0.01, 0, 0)
            addChildNode(flatNode)
        }
    }
}
