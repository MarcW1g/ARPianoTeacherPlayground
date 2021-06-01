//
// GameARSCNView.swift
//
// Created by Marc Wiggerman
//

import ARKit

public class GameARSCNView: ARSCNView {
    
    // MARK: - Private View Constants
    
    /// An AR Coaching Overlay
    private let coachingOverlay: ARCoachingOverlayView = {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.activatesAutomatically = true
        return coachingOverlay
    }()
    
    // MARK: - Private Constants
        
    /// A Dispatch Queue used to update the placement guide
    private let updateQueue = DispatchQueue(label: "dev.mwsd.updatequeue")
    
    /// The spacing between the staff bars
    private let spacingBetweenStaffBars: CGFloat = 0.01
    
    /// The delay between adding the staff nodes
    private let delayBetweenAddingNodes: TimeInterval = 0.5
    
    /// The number of bars on the staff
    private let numberOfStaffBars = 5
    
    /// The standard length of the staff bars
    private let staffLength: CGFloat = 0.5
    
    /// The maximum difference between a node and the current line when the note is played
    private let criticalDistance: Float = 0.015
    
    // MARK: - Private Variables
    
    /// The placement guide used to help the user with placing the AR Content
    private var placementGuide: PlacementGuide?
    
    /// The main node of the staff
    private var staffAnchorNode: SCNNode?
    
    /// The node indicating where the user should have given answer
    private var currentLineNode: CurrentNoteLineNode?
    
    /// The notes currently shown in the scene
    private var currentNotes = [NoteNode]()
    
    // MARK: - Initialization
    
    init() {
        super.init(frame: .zero, options: nil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Setup
    
    /// Sets up the view
    private func setup() {
        // Set the delegate to be self
        delegate = self
        
        // Add the coaching overlay
        addCoachingOverlay()
    }
    
    /// Add the placement guide to the scene
    private func addPlacementGuide() {
        // Add the placement guide
        let placementGuide = PlacementGuide(startsHidden: true)
        scene.rootNode.addChildNode(placementGuide)
        self.placementGuide = placementGuide
    }
    
    /// Add the coaching overlay to the view
    private func addCoachingOverlay() {
        addSubview(coachingOverlay)
        
        // Set the resizing
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Set the session, and activate the overlay
        coachingOverlay.session = session
    }
    
    /// Adds the staff anchor node to the view
    /// - Parameters:
    ///   - position: The position of the staff
    ///   - rotation: The rotation of the staff
    private func addStaffAnchor(position: SCNVector3, rotation: simd_quatf) {
        // Create an empty node
        let staffAnchorNode = SCNNode()
        
        // Set the position and orientation
        staffAnchorNode.position = position
        staffAnchorNode.simdOrientation = rotation
    
        // Add it to the scene
        scene.rootNode.addChildNode(staffAnchorNode)
        
        // Set the variable on the object
        self.staffAnchorNode = staffAnchorNode
    }
    
    /// Adds the staff bars to the staff node
    /// - Parameter completion: Called when the bars are added
    private func addBarsToStaff(completion: @escaping () -> Void) {
        // Check if the staff node is available
        guard let staffAnchorNode = staffAnchorNode else { return }
        
        // Add the 5 bars to the staff node
        var yPosition: CGFloat = 0.0
        var delay: TimeInterval = 0
        let xOffset: CGFloat = staffLength * (1.0 / CGFloat(numberOfStaffBars))
        
        for i in 0..<numberOfStaffBars {
            // Use a small (increasing) delay
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                // Create a new staff node
                let staff = StaffBarNode(length: self?.staffLength ?? 0)
                
                // Set the position and add it to the staff anchor node
                staff.position = SCNVector3(xOffset, yPosition, 0)
                staffAnchorNode.addChildNode(staff)
                
                // Animate the shape appearing
                staff.changeShape()
                
                // Increase the y position
                yPosition += self?.spacingBetweenStaffBars ?? 0
                
                // Call completion when the final bar is added
                if i == (self?.numberOfStaffBars ?? 1) - 1 {
                    completion()
                }
            }
            // Increase the delay
            delay += delayBetweenAddingNodes
        }
    }
    
    /// Adds the vertical line to the scene
    private func addVerticalLine() {
        // Check if the staff node is available
        guard let staffAnchorNode = staffAnchorNode else { return }
        
        // Create the vertical line
        let currentLineNode = CurrentNoteLineNode(height: 0.1, radius: 0.002)
        
        // Set the position and add it to the staff anchor node
        currentLineNode.position = SCNVector3(0, (2 * spacingBetweenStaffBars), 0)
        staffAnchorNode.addChildNode(currentLineNode)
        
        // Animate the shape appearing
        currentLineNode.changeShape()
        
        // Set the variable on the object
        self.currentLineNode = currentLineNode
    }
    
    /// Adds a node representing the G Clef to the staff
    private func addGClef() {        
        // Check if the staff node is available
        guard let staffAnchorNode = staffAnchorNode,
              let gClefNode = ModelLibrary.gClefNode else { return }

        // Set the positioning and rotation properties on the node 
        let yPosition = Float(2 * spacingBetweenStaffBars)
        let xPosition = Float(-0.27 * staffLength)
        gClefNode.position = SCNVector3Make(xPosition, yPosition, 0)
        gClefNode.rotation = SCNVector4(0, 1, 0, -Float.pi/2)
        
        // Let the node be hidden when it is added
        gClefNode.opacity = 0
        
        // Add the node to the scene
        staffAnchorNode.addChildNode(gClefNode)
        
        // Run a fade in action
        let fadeInAction = SCNAction.fadeIn(duration: 0.5)
        gClefNode.runAction(fadeInAction, forKey: "gClefFadeIn")
    }
    
    // MARK: - Public Setup
    
    /// Starts the coaching overlay and adds the placement guide
    public func startAR() {
        // Start coaching
        coachingOverlay.setActive(true, animated: true)
        
        // Add the placement guide
        addPlacementGuide()
    }
    
    /// Add all the initial nodes to the scene if the placement guide is able to get a proper location
    /// - Parameter completion: The completion called notifying the caller if the nodes are added
    public func tryAddingMainARElements(completion: @escaping (_ added: Bool) -> Void) {
        // Get the current position and orientation of the placement guide
        guard let position = placementGuide?.latestPosition,
              let rotation = placementGuide?.latestRotation else {
            completion(false)
            return
        }
        
        // Remove placement guide from the scene
        placementGuide?.removeFromParentNode()
        placementGuide = nil
        
        // Add the basic nodes (staff and vertical line)
        addStaffAnchor(position: SCNVector3Make(position.x, position.y + 0.1, position.z), rotation: rotation)
        addVerticalLine()
        
        // Add the staff bars (after a delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.addBarsToStaff(completion: { [weak self] in
                self?.addGClef()
                completion(true)
            })
        }
    }
    
    // MARK: - Public Note Controls
    
    /// Add a note with an octave to the scene and move it using the provided duration.
    /// - Parameters:
    ///   - note: The note used to create the node
    ///   - octave: The octave used to create the node
    ///   - duration: The duration of the move animation
    /// - Returns: The added node
    public func runNote(note: Note, octave: Int, duration: TimeInterval) -> NoteNode? {
        // Check if the staff node is present
        guard let staffAnchorNode = staffAnchorNode else { return nil }
        
        // Create the node
        let noteNode = NoteNode(note: note, octave: octave)
        
        // Position the note at the end of the staff, and at the appropriate height
        let xPosition: CGFloat = staffLength * 3 / 5
        let yPosition: CGFloat = getYPositionForNote(note, octave: octave)
        noteNode.position = SCNVector3(xPosition, yPosition, 0.003)

        // Add the note node to the staff
        staffAnchorNode.addChildNode(noteNode)
        
        // Start the move animation
        startMoveNote(noteNode: noteNode, duration: duration)
        
        // Add the node to the list of current nodes
        currentNotes.append(noteNode)
        
        return noteNode
    }
    
    /// Check if the first note is near the vertical bar
    /// - Returns: The note, octave and the node of the first note if it is in the critical area. Nil otherwise
    public func noteInCriticalArea() -> NoteNode? {
        if let noteNode = currentNotes.first,
           let horizontalDistance = distanceWithCurrentLine(noteNode) {
            
            // Get the distance
            let absDistance: Float = abs(horizontalDistance)
            
            // Check the distance
            if absDistance < criticalDistance {
                return noteNode
            }
        }
        
        return nil
    }
    
    /// Note has timed out and should be removed if necessary
    /// - Parameter noteNode: The note node which has to be removed
    /// - Returns: True if the node it removed. False otherwise
    public func noteTimeout(noteNode: NoteNode) -> Bool {
        // Check if the node has not already been removed (note: it can only be the first one)
        guard currentNotes.count > 0,
              currentNotes[0] == noteNode else { return false }
        
        // Remove it
        removeNote(noteNode: noteNode)
        return true
    }
    
    // MARK: - Private Note Controls
    
    /// Start moving the note in the scene
    /// - Parameters:
    ///   - noteNode: The note node which should be moved
    ///   - duration: The duration with which to move the note
    private func startMoveNote(noteNode: NoteNode, duration: TimeInterval) {
        // Create the end position for the node
        var newPosition = noteNode.position
        newPosition.x = Float(-1 * (staffLength * 1 / 5))

        // Create a move action and run it on the given node
        let moveToStart = SCNAction.move(to: newPosition, duration: duration)
        moveToStart.timingMode = .linear
        noteNode.runAction(moveToStart)
    }
    
    /// Remove a specific note from the scene
    /// - Parameter noteNode: The note node which has to be removed
    private func removeNote(noteNode: NoteNode) {
        // Get the index of the note node in the current notes array
        guard let index = currentNotes.firstIndex(where: { $0 == noteNode}) else { return }
        
        // Remove the note from the array
        currentNotes.remove(at: index)

        // Fade out the node and remove it from the parent node
        let fadeOut = SCNAction.fadeOut(duration: 0.5)
        fadeOut.timingMode = .easeIn
        noteNode.runAction(fadeOut) {
            noteNode.removeFromParentNode()
        }
    }
    
    /// Removes all notes from the scene
    public func removeAllNoteNodes() {
        for noteNode in currentNotes {
            removeNote(noteNode: noteNode)
        }
    }
    
    /// Removes the note from the scene which is added first
    public func removeFirstNote() {
        if let firstNoteNode = currentNotes.first {
            removeNote(noteNode: firstNoteNode)
        }
    }
    
    // MARK: - Note Text Node Actions
    
    /// Uses a text node to present the correct note in the scene
    /// - Parameter correctNote: The note which had to be pressed by the user
    public func showCorrectNoteInAR(correctNote: Note) {
        guard let staffAnchorNode = staffAnchorNode else { return }
        
        // Add the note as text
        let textNode = TextNode(text: correctNote.rawValue)
        
        // Set the position of the text
        let staffPosition = staffAnchorNode.position
        let yPosition: Float = staffPosition.y + 0.05
        let textPosition = SCNVector3Make(staffPosition.x, yPosition, staffPosition.z - 0.05)
        
        textNode.position = textPosition
        textNode.orientation = staffAnchorNode.orientation
        textNode.scale = SCNVector3Make(0.01, 0.01, 0.01)
        
        // Add it to the scene
        scene.rootNode.addChildNode(textNode)
        
        // Move and fade action
        let actionDuration: TimeInterval = 2
        let moveAndFadeAction = SCNAction.group([
            .fadeIn(duration: 0.5),
            .move(to: SCNVector3Make(staffPosition.x, staffPosition.y, staffPosition.z - 0.05), duration: actionDuration),
            .sequence([
                .wait(duration: 1.5),
                .fadeOut(duration: 0.5)
            ])
        ])
        
        // Run the move/fade action
        textNode.runAction(moveAndFadeAction)
        
        // Remove the node
        DispatchQueue.main.asyncAfter(deadline: .now() + actionDuration) {
            textNode.removeFromParentNode()
        }
    }
    
    
    // MARK: - Private Helpers
    
    /// Get the horizontal distance between a node and the vertical line
    /// - Parameter noteNode: The node of the note for which the distance has to be calculated
    /// - Returns: The horizontal distance as a float
    private func distanceWithCurrentLine(_ noteNode: NoteNode) -> Float? {
        guard let currentLineNode = currentLineNode else { return nil }
        return noteNode.position.x - currentLineNode.position.x
    }
    
    /// Returns the start Y position for a node depending on the note and octave
    /// - Parameters:
    ///   - note: The note
    ///   - octave: The octave of the note
    /// - Returns: The Y position for the note node
    private func getYPositionForNote(_ note: Note, octave: Int) -> CGFloat {
        // We have to check if the note is sharp or flat. In that case we get the base
        // note to use as the start position.
        let baseNote: Note
        if Note.sharpNotes.contains(note),
           let leading = note.leadingNote() {
            baseNote = leading
        } else if Note.flatNotes.contains(note),
            let trailing = note.trailingNote() {
            baseNote = trailing
        } else {
            baseNote = note
        }
        
        // Get the index of the note, and add an offset of 7 for each increasing octave
        let position: CGFloat = CGFloat(baseNote.noteIndex() + (7 * octave))
        
        // Index 0 is 2 below bottom bar
        // Each additional index adds 0.5 * bar spacing
        let stepHeight: CGFloat = spacingBetweenStaffBars / 2
        let yPosition = -spacingBetweenStaffBars + (position * stepHeight)

        return yPosition
    }
    
    
    // MARK: - Public Helpers
    
    /// Check if there are active notes
    /// - Returns: True if there are active notes
    public func hasActiveNotes() -> Bool {
        return !currentNotes.isEmpty
    }
    
    /// Returns the note of the first note node
    /// - Returns: A note. Nil if there aren't any nodes
    public func getNoteOfFirstNoteNode() -> Note? {
        return currentNotes.first?.note
    }

    // MARK: - State Control
    
    /// Shows the user that the answer is correct, and removes the note from the scene
    /// - Parameter withNode node: The node which has to be removed
    public func noteCorrect(withNode node: NoteNode) {
        if let _ = distanceWithCurrentLine(node) {
            currentLineNode?.setMaterialGreen()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.currentLineNode?.setMaterialDefault()
            }
            removeNote(noteNode: node)
        }
    }
    
    /// Shows the user that the answer is incorrect, and removes the note from the scene
    /// - Parameter withNode node: The node which has to be removed
    public func noteIncorrect(withNode node: NoteNode) {
        if let _ = distanceWithCurrentLine(node) {
            currentLineNode?.setMaterialRed()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.currentLineNode?.setMaterialDefault()
            }
            removeNote(noteNode: node)
        }
    }
    
    // MARK: - Placement Guide
    
    /// Returns a standard raycast query originating from the center of the screen to a horizontal plane
    /// - Returns: A raycast query
    private func getRaycastQuery() -> ARRaycastQuery? {
        let centerOfScreen = CGPoint(x: bounds.midX, y: bounds.midY)
        return self.raycastQuery(from: centerOfScreen, allowing: .estimatedPlane, alignment: .horizontal)
    }
    
    /// Updates the placement guide using a raycast
    private func updatePlacementGuide() {
        // Check if there is a placement guide
        guard let placementGuide = placementGuide else { return }
        
        // Get a camera and check if the state is normal
        // Then, we get the raycast query and execute it
        if let camera = session.currentFrame?.camera,
           case .normal = camera.trackingState,
           let raycastQuery = getRaycastQuery(),
           let raycastResult = session.raycast(raycastQuery).first {

            // Set the state of the placement guide using the raycast result
            updateQueue.async {
                placementGuide.state = .detecting(raycastResult: raycastResult)
            }
        } else {
            // We did not find anything using the raycast, so we set the state
            // of the placement guide to be initializing
            updateQueue.async {
                placementGuide.state = .initializing
            }
        }
    }
}

// MARK: - ARSCNViewDelegate
extension GameARSCNView: ARSCNViewDelegate {
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Update the placement guide on each new rendering
        DispatchQueue.main.async { [weak self] in
            self?.updatePlacementGuide()
        }
    }
}
