//
//  Renderer.swift
//  FingerGod
//
//  Created by Aaron Freytag on 2018-02-21.
//  Copyright © 2018 Ramen Interactive. All rights reserved.
//
import GLKit

// The overall static renderer for the game
public class Renderer {
    public static var perspectiveMatrix: GLKMatrix4 {
        get {
            return Renderer.camera.perspectiveMatrix
        }
    }
    
    // The camera class for the renderer to define various camera-adjusting functions
    public class Camera {
        
        public var perspectiveMatrix : GLKMatrix4!
        public var transform = GLKMatrix4Identity
        public var location: GLKVector3 {
            get {
                return GLKVector3Make(transform.m30, transform.m31, transform.m32)
            }
        }
        
        // Moves the camera relative to world space
        public func move(x: Float, y: Float, z: Float) {
            let tmp = GLKMatrix4Translate(GLKMatrix4Identity, x, y, z)
            transform = GLKMatrix4Multiply(tmp, transform)
        }
        
        // Moves the camera relative to local space
        public func moveRelative(x: Float, y: Float, z: Float) {
            transform = GLKMatrix4Translate(transform, x, y, z)
        }
        
        // Rotates the camera (relative to local space)
        public func rotate(angle: Float, x: Float, y: Float, z: Float) {
            transform = GLKMatrix4Rotate(transform, angle, x, y, z)
        }
        
    }
    
    private struct UniformContainer {
        var mvp: GLint!
        var normal: GLint!
        var pass: GLint!
        var shade: GLint!
        var texture: GLint!
    }
    private static var uniforms = UniformContainer()
    private static var view : GLKView!
    private static var program: GLuint!
    private static var context : EAGLContext?
    public static var camera = Camera()
    
    private static var setupBefore = false;
    
    private static var modelInstances = [ModelInstance]()
    private static var textureIds = [String : Int]()
    
    public static func clear() {
        modelInstances = [ModelInstance]()
        textureIds = [String : Int]()
        camera.transform = GLKMatrix4Identity
    }
    
    // Prepares the renderer for use by linking it with a view, and if necessary, cleaning it from previous use
    public static func setup(view: GLKView) {
        if !setupBefore {
            context = EAGLContext.init(api: EAGLRenderingAPI.openGLES3)
            if context == nil {
                print("Failed to create GLES3 Context")
            }
            view.drawableDepthFormat = GLKViewDrawableDepthFormat.format24
            view.drawableColorFormat = GLKViewDrawableColorFormat.SRGBA8888
            view.context = context!
            
            Renderer.view = view
            EAGLContext.setCurrent(view.context)
            
            setupShaders()
            setupUniforms()
            // Add a simple default texture if we have none so far
            addTexture(ImageReader.read(name: "checker.png"))
            
            glClearColor(0.3, 0.65, 1.0, 1.0)
            glEnable(GLenum(GL_DEPTH_TEST))
            setupBefore = true
        }
        else {
            clear()
            // Add a simple default texture if we have none so far
            addTexture(ImageReader.read(name: "checker.png"))
            
            view.drawableDepthFormat = GLKViewDrawableDepthFormat.format24
            view.drawableColorFormat = GLKViewDrawableColorFormat.SRGBA8888
            view.context = context!
            Renderer.view = view
            EAGLContext.setCurrent(view.context)
        }
    }
    
    // Loads the main shaders and links them
    private static func setupShaders() {
        let vsh = loadShader(filename: "Shader", type: GL_VERTEX_SHADER)
        let fsh = loadShader(filename: "Shader", type: GL_FRAGMENT_SHADER)
        program = glCreateProgram()
        
        glAttachShader(program, vsh)
        glAttachShader(program, fsh)
        glLinkProgram(program)
        
        var linkStatus = GLint(0)
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &linkStatus)
        if (linkStatus == 0) {
            var msg = [GLchar](repeating: 0, count: 1024);
            glGetProgramInfoLog(program, 1024, nil, &msg)
            print("Problem linking shader: ", String(cString: msg))
        }
        
        glDeleteShader(vsh)
        glDeleteShader(fsh)
    }
    
    private static func setupUniforms() {
        uniforms.mvp = glGetUniformLocation(program, "modelViewProjectionMatrix")
        uniforms.normal = glGetUniformLocation(program, "normalMatrix")
        uniforms.pass = glGetUniformLocation(program, "passThrough")
        uniforms.shade = glGetUniformLocation(program, "shadeInFrag")
        uniforms.texture = glGetUniformLocation(program, "texSampler")
    }

    // Loads a single shader
    private static func loadShader(filename: String, type: Int32) -> GLuint {
        do {
            let path = Bundle.main.path(forResource: filename, ofType: (type == GL_VERTEX_SHADER ? "vsh" : "fsh"))!
            let shadeSrc = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
            
            let shader = glCreateShader(GLenum(type))
            if (shader == 0) {
                print("Failed to create shader")
            }
            
            var src = (shadeSrc as NSString).utf8String
            
            glShaderSource(shader, GLsizei(1), &src, nil)
            glCompileShader(shader)
            
            var compileStatus = GLint(0)
            glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &compileStatus)
            if (compileStatus == 0) {
                var msg = [GLchar](repeating: 0, count: 1024);
                glGetShaderInfoLog(shader, 1024, nil, &msg)
                print("Problem compiling shader: ", String(cString: msg))
            }
            
            return shader
            
        } catch {
            print("There was a problem: \(error)");
        }
        
        return 0
    }
    
    public static func draw(drawRect: CGRect) {
        // We do this in multiple draw calls for now
        // Eventually it may be a good idea to make less draw calls
        
        glViewport(0, 0, GLsizei(view.drawableWidth), GLsizei(view.drawableHeight))
        
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        
        glUseProgram(program)
        
        camera.perspectiveMatrix = GLKMatrix4MakePerspective(Float(60.0 * Double.pi / 180.0), Float(view.drawableWidth) / Float(view.drawableHeight), 1.0, 300.0)
        
        let cameraMatrix = GLKMatrix4Invert(camera.transform, nil)
        
        for inst in modelInstances {
            var mvpMatrix = inst.transform
            var normMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(mvpMatrix), nil)
            mvpMatrix = GLKMatrix4Multiply(cameraMatrix, mvpMatrix)
            mvpMatrix = GLKMatrix4Multiply(perspectiveMatrix, mvpMatrix)
            
            let vertices = inst.model.vertices
            let normals = inst.model.normals
            let texCoords = inst.model.texels
            let indices = inst.model.faces
            
            glUniformMatrix4fv(uniforms.mvp, 1, 0, &mvpMatrix.m.0)
            glUniformMatrix3fv(uniforms.normal, 1, 0, &normMatrix.m.0)
            
            glUniform1i(uniforms.pass, GL_FALSE)
            glUniform1i(uniforms.shade, GL_TRUE)
            
            var texId = 0
            
            // If we don't have a texture for the model, just set it to the default texture we loaded earlier
            if (inst.model.texture != nil) {
                texId = textureIds[inst.model.texture!.name]!
            }
            
            glUniform1i(uniforms.texture, GLint(texId))
            
            glVertexAttribPointer(0, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(3 * MemoryLayout<GLfloat>.size), vertices)
            glEnableVertexAttribArray(0)
            
            glVertexAttrib4f(1, inst.color[0], inst.color[1], inst.color[2], inst.color[3])
            
            glVertexAttribPointer(2, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(3 * MemoryLayout<GLfloat>.size), normals)
            glEnableVertexAttribArray(2)
            
            glVertexAttribPointer(3, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(2 * MemoryLayout<GLfloat>.size), texCoords)
            glEnableVertexAttribArray(3)
            
            glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.count), GLenum(GL_UNSIGNED_INT), indices)
        }
    }
    
    public static func addInstance(inst: ModelInstance) {
        modelInstances.append(inst)
        if (inst.model.texture != nil && textureIds[inst.model.texture!.name] == nil) {
            addTexture(inst.model.texture!)
        }
        setupLists()
    }
    
    public static func removeInstance(inst: ModelInstance) {
        let ind = modelInstances.index{$0 === inst};
        if (ind != nil) {
            modelInstances.remove(at: ind!)
            setupLists()
        }
    }
    
    private static func addTexture(_ texture: Image) {
        let w = texture.img.width
        let h = texture.img.height
        
        let spriteData = calloc(w * h * 4, MemoryLayout<GLubyte>.size)
        let spriteContext = CGContext(data: spriteData, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4, space: texture.img.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        spriteContext!.draw(texture.img, in: CGRect(x: 0, y: 0, width: w, height: h))

        var texName : GLuint = 0
        glGenTextures(1, &texName)
        
        let val = textureIds.count
        
        glActiveTexture(GLenum(Int(GL_TEXTURE0) + val))
        glBindTexture(GLenum(GL_TEXTURE_2D), texName)
        
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_NEAREST)
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, GLsizei(w), GLsizei(h), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), spriteData)
        free(spriteData)
        
        print("Texture " + String(texture.name) + " loaded into slot " + String(val))
        
        textureIds[texture.name] = val
    }
    
    // Sets up all of the necessary lists for rendering
    // Not currently used, but eventually may be useful for putting all of the vertices in one buffer and etc
    private static func setupLists() {
        
    }
}

