//
// Note.swift
//
// Created by Marc Wiggerman
//

/// A note
public enum Note: String, CaseIterable {
    // In order of an octave
    case C = "C"
    case D = "D"
    case E = "E"
    case F = "F"
    case G = "G"
    case A = "A"
    case B = "B"
    
    // All the sharp notes
    case CSharp = "C#"
    case DSharp = "D#"
    case FSharp = "F#"
    case GSharp = "G#"
    case ASharp = "A#"
    
    // All the flat notes
    case DFlat = "Db"
    case EFlat = "Eb"
    case GFlat = "Gb"
    case AFlat = "Ab"
    case BFlat = "Bb"
    
    /// The base notes in order on the piano
    public static var baseNotesInOrder: [Note] = [.C, .D, .E, .F, .G, .A, .B]
    
    /// A set of the sharp notes for fast access
    public static var sharpNotes: Set<Note> = [.CSharp, .DSharp, .FSharp, .GSharp, .ASharp]
    
    /// The sharp notes in order on the piano
    public static var sharpNotesInOrder: [Note] = [.CSharp, .DSharp, .FSharp, .GSharp, .ASharp]
    
    /// A set of the flat notes for fast access
    public static var flatNotes: Set<Note> = [.DFlat, .EFlat, .GFlat, .AFlat, .BFlat]
    
    /// Get the leading note of a sharp note
    /// - Returns: The leading note of the sharp note. Nil if the note is not sharp
    public func leadingNote() -> Note? {
        switch(self) {
        case .CSharp:
            return .C
        case .DSharp:
            return .D
        case .FSharp:
            return .F
        case .GSharp:
            return .G
        case .ASharp:
            return .A
        default:
            return nil
        }
    }
    
    /// Get the training note of a flat note
    /// - Returns: The leading note of the flat note. Nil if the note is not sharp
    public func trailingNote() -> Note? {
        switch(self) {
        case .DFlat:
            return .D
        case .EFlat:
            return .E
        case .GFlat:
            return .G
        case .AFlat:
            return .A
        case .BFlat:
            return .B
        default:
            return nil
        }
    }
    
    /// Get the flat version located on the same key
    /// - Returns: The flat version of a sharp note. Nil if the note is not sharp
    public func flatVersion() -> Note? {
        switch(self) {
        case .CSharp:
            return .DFlat
        case .DSharp:
            return .EFlat
        case .FSharp:
            return .GFlat
        case .GSharp:
            return .AFlat
        case .ASharp:
            return .BFlat
        default:
            return nil
        }
    }
    
    /// Get the sharp version located on the same key
    /// - Returns: The sharp version of a sharp note. Nil if the note is not flat
    public func sharpVersion() -> Note? {
        switch(self) {
        case .DFlat:
            return .CSharp
        case .EFlat:
            return .DSharp
        case .GFlat:
            return .FSharp
        case .AFlat:
            return .GSharp
        case .BFlat:
            return .ASharp
        default:
            return nil
        }
    }
    
    /// Get the index of the note on the staff.
    /// 0 represents the base C and each note above adds one to the index.
    /// - Returns: The index of the note. -1 if the note is sharp or flat
    public func noteIndex() -> Int {
        switch self {
        case .C:
            return 0
        case .D:
            return 1
        case .E:
            return 2
        case .F:
            return 3
        case .G:
            return 4
        case .A:
            return 5
        case .B:
            return 6
        default:
            return -1
        }
        
    }
}

extension Note {
    /// Get the name of the audio file for the note.
    /// - Parameter octave: The octave of the note. 0 represents the octave starting at the middle C
    /// - Returns: The name of the audio file (excluding the extension)
    public func mp3FileName(octave: Int) -> String? {
        var base: String
        
        // Check if the note is either a sharp or a flat note
        // If it is, the file name is a combination of the sharp and the flat note
        if Note.sharpNotes.contains(self) {
            base = (self.flatVersion()?.rawValue ?? "") + self.rawValue
        } else if Note.flatNotes.contains(self) {
            base = self.rawValue + (self.sharpVersion()?.rawValue ?? "")
        } else {
            // Else it is just the raw value of the note
            base = self.rawValue
        }
        
        if octave > 0 {
            base = "\(base)_\(octave)"
        }
        
        return base
    }
}
