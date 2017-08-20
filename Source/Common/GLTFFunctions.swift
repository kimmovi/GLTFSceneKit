//
//  GLTFFunctions.swift
//  GLTFSceneKit
//  Utility functions for internal use
//
//  Created by magicien on 2017/08/20.
//  Copyright © 2017年 DarkHorse. All rights reserved.
//

import SceneKit
import SpriteKit

func add(_ v0: SCNVector3, _ v1: SCNVector3) -> SCNVector3 {
    return SCNVector3(v0.x + v1.x, v0.y + v1.y, v0.z + v1.z)
}

func sub(_ v0: SCNVector3, _ v1: SCNVector3) -> SCNVector3 {
    return SCNVector3(v0.x - v1.x, v0.y - v1.y, v0.z - v1.z)
}

func mul(_ v: SCNVector3, _ n: CGFloat) -> SCNVector3 {
    return SCNVector3(v.x * n, v.y * n, v.z * n)
}

func div(_ v: SCNVector3, _ n: CGFloat) -> SCNVector3 {
    return mul(v, 1.0 / n)
}

func cross(_ v0: SCNVector3, _ v1: SCNVector3) -> SCNVector3 {
    return SCNVector3(v0.y * v1.z - v0.z * v1.y, v0.z * v1.x - v0.x * v1.z, v0.x * v1.y - v0.y * v1.x)
}

func length(_ v: SCNVector3) -> CGFloat {
    let l2 = v.x * v.x + v.y * v.y + v.z * v.z
    #if os(macOS)
        // CGFloat = Double
        return sqrt(l2)
    #else
        // CGFloat = Float
        return sqrtf(l2)
    #endif    
}

func normalize(_ v: SCNVector3) -> SCNVector3 {
    return mul(v, 1.0 / length(v))
}

func createNormal(_ v0: SCNVector3, _ v1: SCNVector3, _ v2: SCNVector3) -> SCNVector3 {
    let e1 = sub(v1, v0)
    let e2 = sub(v2, v0)
    let n = cross(e1, e2)
    
    return normalize(n)
}

func createVertexArray(from source: SCNGeometrySource) throws -> [SCNVector3] {
    if source.componentsPerVector != 3 {
        throw GLTFUnarchiveError.NotSupported("createVertexArray: only 3 component vector is supported: \(source.componentsPerVector)")
    }
    if !source.usesFloatComponents || source.bytesPerComponent != 4 {
        throw GLTFUnarchiveError.NotSupported("createVertexArray: only float source is supported")
    }
    
    let dummy = SCNVector3()
    var vertices = [SCNVector3](repeating: dummy, count: source.vectorCount)
    
    source.data.withUnsafeBytes { (p: UnsafePointer<Float32>) in
        var index = source.dataOffset / 4
        let step = source.dataStride / 4
        for i in 0..<source.vectorCount {
            let v0 = p[index + 0]
            let v1 = p[index + 1]
            let v2 = p[index + 2]
            index += step
            vertices[i] = SCNVector3(v0, v1, v2)
        }
    }
    return vertices
}

func createIndexArray(from element: SCNGeometryElement) -> [Int] {
    var indices = [Int](repeating: 0, count: element.primitiveCount)
    if element.bytesPerIndex == 2 {
        element.data.withUnsafeBytes { (p: UnsafePointer<UInt16>) in
            var index = 0
            let step = 2
            for i in 0..<element.primitiveCount {
                indices[i] = Int(p[index])
                index += step
            }
        }
    } else if element.bytesPerIndex == 4 {
        element.data.withUnsafeBytes { (p: UnsafePointer<UInt32>) in
            var index = 0
            let step = 4
            for i in 0..<element.primitiveCount {
                indices[i] = Int(p[index])
                index += step
            }
        }
    } else if element.bytesPerIndex == 8 {
        element.data.withUnsafeBytes { (p: UnsafePointer<UInt64>) in
            var index = 0
            let step = 8
            for i in 0..<element.primitiveCount {
                indices[i] = Int(p[index])
                index += step
            }
        }
    }
    
    return indices
}

func createColor(_ color: [Float]) -> SKColor {
    let c: [CGFloat] = color.map { CGFloat($0) }
    assert(c.count >= 4)
    return SKColor.init(red: c[0], green: c[1], blue: c[2], alpha: c[3])
}

func createGrayColor(white: Float) -> SKColor {
    return SKColor(white: CGFloat(white), alpha: 1.0)
}

func createVector3(_ vector: [Float]) -> SCNVector3 {
    let v: [CGFloat] = vector.map { CGFloat($0) }
    assert(v.count >= 3)
    return SCNVector3(x: v[0], y: v[1], z: v[2])
}

func createVector4(_ vector: [Float]) -> SCNVector4 {
    let v: [CGFloat] = vector.map { CGFloat($0) }
    assert(v.count >= 4)
    return SCNVector4(x: v[0], y: v[1], z: v[2], w: v[3])
}

func createMatrix4(_ matrix: [Float]) -> SCNMatrix4 {
    let m: [CGFloat] = matrix.map { CGFloat($0) }
    assert(m.count >= 16)
    return SCNMatrix4(
        m11: m[0], m12: m[1], m13: m[2], m14: m[3],
        m21: m[4], m22: m[5], m23: m[6], m24: m[7],
        m31: m[8], m32: m[9], m33: m[10], m34: m[11],
        m41: m[12], m42: m[13], m43: m[14], m44: m[15])
}
