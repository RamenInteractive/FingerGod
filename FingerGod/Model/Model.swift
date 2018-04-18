//
//  Renderer.swift
//  FingerGod
//
//  Created by Aaron Freytag on 2018-02-21.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//

import GLKit

// The pure model data.
// Should only be created once if multiple objects use the same model
public class Model {
    public var vertices: [GLfloat]
    public var normals: [GLfloat]
    public var texels: [GLfloat]
    public var faces: [GLint]
    public var texture: Image?
    
    public init(vertices: [GLfloat], normals: [GLfloat], texels: [GLfloat], faces: [GLint], texture: Image?) {
        self.vertices = vertices
        self.normals = normals
        self.texels = texels
        self.faces = faces
        self.texture = texture
    }
}
