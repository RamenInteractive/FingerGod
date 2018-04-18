//
//  ModelReader.swift
//  FingerGod
//
//  Created by Aaron Freytag on 2018-02-21.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import Foundation
import GLKit

public class ModelReader {
    enum ModelReaderError : Error {
        case ResourceNotFound(file: String)
    }
    public static func read(objPath: String) throws -> Model {
        let path = Bundle.main.path(forResource: objPath, ofType: "obj")
        if (path == nil) {
            throw ModelReaderError.ResourceNotFound(file: objPath)
        }
        let objFile = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        
        var baseVertices = [GLfloat]()
        var faceNormals = [GLfloat]()
        var texels = [GLfloat]()
        var faces = [[Int]]()

        objFile.enumerateLines { line, _ in
            switch (line.prefix(2)) {
            case "v ":
                baseVertices += parseVertex(line: line)
            case "vt":
                texels += parseTexel(line: line)
            case "vn":
                faceNormals += parseNormal(line: line)
            case "f ":
                let ind = line.components(separatedBy: " ")
                let ind2 = ind[1].components(separatedBy: "/")
                if (ind2.count == 3) {
                    if ind2[1] == "" {
                        faces += parseFace(line: line, hasNormals: true, hasTexels: false)
                    }
                    else {
                        faces += parseFace(line: line, hasNormals: true, hasTexels: true)
                    }
                }
                else if (ind2.count == 2) {
                    faces += parseFace(line: line, hasNormals: false, hasTexels: true)
                }
                else {
                    faces += parseFace(line: line, hasNormals: false, hasTexels: false)
                }
            default:
                break
            }
        }
        
        if (faceNormals.count == 0) {
            faceNormals.append(0.0)
            faceNormals.append(0.0)
            faceNormals.append(1.0)
        }
        
        if (texels.count == 0) {
            texels.append(0.0)
            texels.append(0.0)
        }
        
        // Now that we have the data from the file, we need to convert it into a format OpenGL can use
        // Basically, this just involves duplicating vertices that have multiple normals
        
        var vertices = [GLfloat]()
        var normals = [GLfloat]()
        var texCoords = [GLfloat]()
        var indices = [GLint]()
        
        var indexDictionary = [String:Int]()
        for f in faces {
            let txt = String("\(f[0])/\(f[1])/\(f[2])")
            if (indexDictionary[txt] == nil) {
                // This vertex-normal pair has never been used before, so make the vertex and put it in the dictionary
                let ind = vertices.count / 3
                vertices.append(baseVertices[f[0] * 3])
                vertices.append(baseVertices[f[0] * 3 + 1])
                vertices.append(baseVertices[f[0] * 3 + 2])
                texCoords.append(texels[f[1] * 2])
                texCoords.append(texels[f[1] * 2 + 1])
                normals.append(faceNormals[f[2] * 3])
                normals.append(faceNormals[f[2] * 3 + 1])
                normals.append(faceNormals[f[2] * 3 + 2])
                indexDictionary[txt] = ind
            }
            indices.append(GLint(indexDictionary[txt]!))
        }
        
        return Model(vertices: vertices, normals: normals, texels: texCoords, faces: indices, texture: nil)
    }
    
    private static func parseVertex(line: String) -> [GLfloat] {
        let sc = Scanner(string: line)
        sc.charactersToBeSkipped = CharacterSet(charactersIn: "v ")
        var dec = Float(0.0)
        var vals = [GLfloat]()
        sc.scanFloat(&dec)
        vals.append(dec)
        sc.scanFloat(&dec)
        vals.append(dec)
        sc.scanFloat(&dec)
        vals.append(dec)
        return vals;
    }
    
    private static func parseTexel(line: String) -> [GLfloat] {
        let sc = Scanner(string: line)
        sc.charactersToBeSkipped = CharacterSet(charactersIn: "vt ")
        var dec = Float(0.0)
        var vals = [GLfloat]()
        sc.scanFloat(&dec)
        vals.append(dec)
        sc.scanFloat(&dec)
        vals.append(1 - dec)
        return vals;
    }
    
    private static func parseNormal(line: String) -> [GLfloat] {
        let sc = Scanner(string: line)
        sc.charactersToBeSkipped = CharacterSet(charactersIn: "vn ")
        var dec = Float(0.0)
        var vals = [GLfloat]()
        sc.scanFloat(&dec)
        vals.append(dec)
        sc.scanFloat(&dec)
        vals.append(dec)
        sc.scanFloat(&dec)
        vals.append(dec)
        return vals;
    }
    
    private static func parseFace(line: String, hasNormals : Bool, hasTexels : Bool) -> [[Int]] {
        let sc = Scanner(string: line)
        sc.charactersToBeSkipped = CharacterSet(charactersIn: "f/ ")
        var vec : Int = 0
        var nor : Int = 0
        var tex : Int = 0
        var vals = [[Int]]()
        
        for _ in 0..<3 {
            sc.scanInt(&vec)
            if (hasTexels) {
                sc.scanInt(&tex)
            }
            else {
                tex = 1
            }
            if (hasNormals) {
                sc.scanInt(&nor)
            }
            else {
                nor = 1
            }
            vals.append([vec - 1, tex - 1, nor - 1])
        }

        return vals
    }
}
