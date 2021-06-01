//
// Float4x4+extensions.swift
//
// Created by Marc Wiggerman
//


import Foundation
import ARKit 

public extension float4x4 {
    /// The translation values in the matrix
    var translation: SIMD3<Float> {
        get {
            let translation = columns.3
            return [translation.x, translation.y, translation.z]
        } set(newValue) {
            columns.3 = [newValue.x, newValue.y, newValue.z, columns.3.w]
        }
    }
    
    /// The orientation value in the matrix
    var orientation: simd_quatf {
        return simd_quaternion(self)
    }
}
