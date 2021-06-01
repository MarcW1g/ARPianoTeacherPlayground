//
// GameController.swift
//
// Created by Marc Wiggerman
//

import SceneKit
import AVFoundation

/// Protocol implemented by the objecting wanting to receive notifications about the game state
public protocol GameControllable {
    /// Called when the score is updated
    /// - Parameter newScore: The new score of the game
    func scoreDidUpdate(newScore: Int)
    
    /// Called when the player lost one life
    /// - Parameter number: The number (ID) of the lost life
    func didLoseOneLife(number: Int)
    
    /// Called when the game is over
    func gameOver()
}

/// The difficulty level
public enum Difficulty {
    case easy
    case medium
    case hard
}

/// Data Model for the Game Controller
public class GameData {
    /// The current score
    public var score: Int = 0
    
    /// The current number of lives left
    public var lives: Int = 3
}

/// The controller for the game
public class GameController {
    
    /// An enum to represent the current state of the game
    public enum GameState {
        case initializing
        case readyToStart
        case playing
        case gameOver
    }
    
    // MARK: - Private Constants
    
    /// The ARScene used in the game 
    private let sceneView: GameARSCNView
    
    /// The Dispatch Queue used to play audio
    private let audioQueue = DispatchQueue(label: "dev.mwsd.audioplayer", qos: .userInitiated)
    
    // MARK: - Private Variables
    
    /// A timer to keep track of the game
    private var gameTimer: Timer?
    
    /// The current difficulty of the game
    private var difficulty: Difficulty = .hard
    
    /// An audio player to play music notes
    private var audioPlayer: AVAudioPlayer?
    
    // MARK: - Public Variables
    
    /// Holds the current data for the game
    public private(set) var gameData: GameData?
    
    /// The current game state
    public var gameState: GameState = .initializing
    
    /// A delegate notified of game controller notifications
    public var delegate: GameControllable?
    
    // MARK: - Initialization
    
    init(sceneView: GameARSCNView) {
        self.sceneView = sceneView
        gameData = GameData()
    }
    
    // MARK: - Control the state
    
    /// Reset the game data
    public func resetData() {
        // Resets the game to the default properties
        gameData?.lives = 3
        gameData?.score = 0
    }
    
    /// Start the game
    public func start() {
        gameState = .playing
        
        // Start with the default difficulty of easy
        startWithDifficulty(of: .easy, runNoteNow: true)
    }
    
    /// Start the game using a predefined difficulty
    /// - Parameters:
    ///   - of: The difficulty level used to start the game
    ///   - runNoteNow: Run a note directly after calling this method
    private func startWithDifficulty(of difficulty: Difficulty, runNoteNow: Bool) {
        // Set the difficulty of the object
        self.difficulty = difficulty
        
        // Invalidate any running game timers
        gameTimer?.invalidate()
        
        if runNoteNow {
            // Run a node right now (as the timer does not fire until the first duration)
            runRandomNote()
        }
        
        // Restart the timer with a new interval (depending on the difficulty)
        gameTimer = Timer.scheduledTimer(timeInterval: getNoteIntervalTime(), target: self, selector: #selector(runRandomNote), userInfo: nil, repeats: true)
    }
    
    /// Stop the game
    public func stop() {
        gameTimer?.invalidate()
    }
    
    /// Increase the score with a standard value
    private func increaseScore() {
        guard let gameData = gameData else { return }
        gameData.score += 10
        
        // Notify the delegate of the update
        delegate?.scoreDidUpdate(newScore: gameData.score)
        
        // Check if we need to increase the difficulty based on the new score
        checkIfDifficultyIncreaseIsNeeded()
    }
    
    /// Remove one life
    private func loseLife() {
        // Check if the game data exists
        guard let gameData = gameData else { return }
        
        // Remove a life
        gameData.lives -= 1
        
        // Notify the delegate of the update
        delegate?.didLoseOneLife(number: gameData.lives + 1)
        
        // Check if the user is Game Over
        if gameData.lives == 0 {
            // Set the state
            gameState = .gameOver
            
            // Notify the delegate
            delegate?.gameOver()
            
            // Remove all notes currently in the scene
            sceneView.removeAllNoteNodes()
        }
    }
    
    // MARK: - Note Control
    
    /// Adds a node representing a randomly chosen note/octave to the scene
    @objc private func runRandomNote() {
        // Get a random note
        guard let randomNote: Note = Note.allCases.randomElement() else { return }
        
        // Get a random octave between 0 and 1 (inclusive)
        let octave = Int.random(in: 0...1)
                
        // Get the duration belonging to the current difficulty
        let duration = getMoveDuration()
        
        // Add the note to the scene
        if let addedNote = sceneView.runNote(note: randomNote, octave: octave, duration: duration) {
            // Start a timeout to check if the user pressed any key when the note arrives at the start of the bar
            DispatchQueue.main.asyncAfter(deadline: .now() + duration - 0.1) { [weak self] in
                // Notify the scene of the timeout and check if the note is just removed (indicating a wrong answer)
                let removed = self?.sceneView.noteTimeout(noteNode: addedNote)
                
                if removed ?? false {
                    // The user was too late with giving an answer, so he/she loses a life
                    self?.incorrect(withNoteNode: addedNote)
                }
            }
        }
    }
    
    /// The played note is incorrect
    /// - Parameter withNoteNode noteNode: (optional) If provided the note will be removed from the scene. If no value is given, the first note is removed
    private func incorrect(withNoteNode noteNode: NoteNode? = nil) {
        // The note is incorrect, so we play the sound, show it in the scene, and decrease the number of lives
        playWrongAnswerSound()

        if let noteNode = noteNode {
            // Show the correct note in the scene
            sceneView.showCorrectNoteInAR(correctNote: noteNode.note)
            sceneView.noteIncorrect(withNode: noteNode)
        } else {
            // We show the note of the first node
            if let noteOfFirstNode = sceneView.getNoteOfFirstNoteNode() {
                sceneView.showCorrectNoteInAR(correctNote: noteOfFirstNode)
            }
            sceneView.removeFirstNote()
        }
        
        loseLife()
    }
    
    /// The played note is correct
    /// - Parameter withNoteNode noteNode: The note node which is correct
    private func correct(withNoteNode noteNode: NoteNode) {
        // We play the sound, show this to the user in the scene, and increase the score
        playNoteSound(note: noteNode.note, octave: noteNode.octave)
        
        sceneView.noteCorrect(withNode: noteNode)
        
        increaseScore()
    }
    
    // MARK: - Difficulty Control
    
    /// Increases the difficulty of the game if a certain score is achieved
    private func checkIfDifficultyIncreaseIsNeeded() {
        switch gameData?.score ?? 0 {
        case 50:
            startWithDifficulty(of: .medium, runNoteNow: false)
        case 100:
            startWithDifficulty(of: .hard, runNoteNow: false)
        default:
            break 
        }
    }
    
    // MARK: - Sounds
    
    /// Plays the sound belonging to a note in a specified octave
    /// - Parameters:
    ///   - note: The note which should be played
    ///   - octave: The octave of the note which should be used
    private func playNoteSound(note: Note, octave: Int) {
        // Get the file name of the note
        guard let fileName = note.mp3FileName(octave: octave) else { return }
        
        // Play the sound
        playSoundFromFileWithName(fileName)
    }
    
    /// Plays the sound belonging to a wrong answer
    private func playWrongAnswerSound() {
        playSoundFromFileWithName("wrong_sound")
    }
        
    /// Plays a sound from a provided file name
    /// - Parameter fileName: The name of the mp3 file
    /// - Note: The audio is played on another queue to minimize lag. This can however introduce a delay before the sound is played
    private func playSoundFromFileWithName(_ fileName: String) {
        audioQueue.async {
            // Get the audio file (check if it exists)
            if let audioURL = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
                do {
                    // Try to play the contents of the file (once)
                    try self.audioPlayer = AVAudioPlayer(contentsOf: audioURL)
                    self.audioPlayer?.numberOfLoops = 0
                    self.audioPlayer?.play()
                } catch {
                    print("Could not create the audio player \(error)")
                }
            } else {
                print("The audio file could not be found")
            } 
        }
    }
    
    // MARK: - Helper Methods
    
    /// Returns the move duration for a note using the current difficulty
    /// - Returns: The move duration as a TimeInterval
    private func getMoveDuration() -> TimeInterval {
        switch difficulty {
        case .easy:
            return 5
        case .medium:
            return 4
        case .hard:
            return 3
        }
    }
    
    /// Returns the interval time between two notes
    /// - Returns: The interval as a TimeInterval
    private func getNoteIntervalTime() -> TimeInterval {
        switch difficulty {
        case .easy:
            return 5
        case .medium:
            return 3
        case .hard:
            return 2
        }
    }
}

// MARK: - PianoControllable
extension GameController: PianoControllable {
    /// Called when a key is pressed by the user
    /// - Parameter note: The note of the pressed key
    public func pressedKey(note: Note) {
        // Check if the note is close enough to the bar
        if let noteNode = sceneView.noteInCriticalArea() {
            // The note can be sharp or flat, so we have to check if the
            // player played a black key. We have chosen to always assign the 
            // sharp notes to the black ones.
            if Note.sharpNotes.contains(note) {
                // User played a sharp (or flat), so we check if the note equals either type
                if note == noteNode.note || note.flatVersion() == noteNode.note {
                    correct(withNoteNode: noteNode)
                    return
                }
            } else {
                // Check if the played note is correct
                if note == noteNode.note {
                    correct(withNoteNode: noteNode)
                    return
                }
            }

            incorrect(withNoteNode: noteNode)
        } else if sceneView.hasActiveNotes() {
            incorrect()
        }
    }
}
