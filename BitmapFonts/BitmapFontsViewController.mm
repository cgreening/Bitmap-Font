//Copyright 2011 CMG Research Ltd.
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

#import <QuartzCore/QuartzCore.h>

#import "BitmapFontsViewController.h"
#import "EAGLView.h"
#import "texture_support.h"
#import "Font.h"

// Attribute index.
enum {
    ATTRIB_POSITION,
	ATTRIB_TEXCOORD
};

@interface BitmapFontsViewController ()
@property (nonatomic, retain) EAGLContext *context;
- (void) setupView;
- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation BitmapFontsViewController

@synthesize animating, context;

- (void)awakeFromNib
{
  EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
  if (!aContext)
  {
    aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
  }
    
  if (!aContext)
    NSLog(@"Failed to create ES context");
  else if (![EAGLContext setCurrentContext:aContext])
    NSLog(@"Failed to set ES context current");
    
	self.context = aContext;
	[aContext release];
	
  [(EAGLView *)self.view setContext:context];
  [(EAGLView *)self.view setFramebuffer];
    
  if ([context API] == kEAGLRenderingAPIOpenGLES2) {
    [self loadShaders];
	}
    
  [self setupView];
  animating = FALSE;
  displayLinkSupported = FALSE;
  animationFrameInterval = 1;
  displayLink = nil;
  animationTimer = nil;
	
	// create the font
  NSString *path = [[NSBundle mainBundle] pathForResource:@"font" ofType:@"fnt"];
  font = new Font([path UTF8String]);
	// load up the fonr texture
	textureId=loadTexture("font.png", -1, -1);
  // create a string
  numberIndices = font->createVerticesAndTexCoordsForString("CMG Research Ltd", &verticeAndTextureCoords, &indices, 50);
  textWidth=font->getWidthOfString("CMG Research Ltd", 50);
  
  // Use of CADisplayLink requires iOS version 3.1 or greater.
	// The NSTimer object is used as fallback when it isn't available.
  NSString *reqSysVer = @"3.1";
  NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
  if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
    displayLinkSupported = TRUE;
}

- (void)dealloc
{
    if (simpleProgram)
    {
        glDeleteProgram(simpleProgram);
        simpleProgram = 0;
    }
    
    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
    
    [context release];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self startAnimation];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopAnimation];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
    if (simpleProgram)
    {
        glDeleteProgram(simpleProgram);
        simpleProgram = 0;
    }
	
    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	self.context = nil;	
}

- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    /*
	 Frame interval defines how many display frames must pass between each time the display link fires.
	 The display link will only fire 30 times a second when the frame internal is two on a display that refreshes 60 times a second. The default frame interval setting of one will fire 60 times a second when the display refreshes at 60 times a second. A frame interval setting of less than one results in undefined behavior.
	 */
    if (frameInterval >= 1)
    {
        animationFrameInterval = frameInterval;
        
        if (animating)
        {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{
    if (!animating)
    {
        if (displayLinkSupported)
        {
            /*
			 CADisplayLink is API new in iOS 3.1. Compiling against earlier versions will result in a warning, but can be dismissed if the system version runtime check for CADisplayLink exists in -awakeFromNib. The runtime check ensures this code will not be called in system versions earlier than 3.1.
			 */
            displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawFrame)];
            [displayLink setFrameInterval:animationFrameInterval];
            
            // The run loop will retain the display link on add.
            [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
        else
            animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(drawFrame) userInfo:nil repeats:TRUE];
        
        animating = TRUE;
    }
}

- (void)stopAnimation
{
    if (animating)
    {
        if (displayLinkSupported)
        {
            [displayLink invalidate];
            displayLink = nil;
        }
        else
        {
            [animationTimer invalidate];
            animationTimer = nil;
        }
        
        animating = FALSE;
    }
}

- (void)drawFrame
{	
    [(EAGLView *)self.view setFramebuffer];
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
	
    // rotate the objects
    angle-=1.0;
    
    if ([context API] == kEAGLRenderingAPIOpenGLES2)
    {
      // ES2.0 rendering
      esMatrixLoadIdentity(&modelView);                   // reset our modelview to identity
      esRotate(&modelView, angle, 0.0, 0.0, 1.0);         // rotate the text
      esTranslate(&modelView, -textWidth/2, 0.0f, 0.0f);  // center the text
      // flip the text right way up
      esScale(&modelView, 1.0, -1.0, 1.0);
      glUseProgram(simpleProgram);                        // tell the GPU we want to use our program
      esMatrixMultiply(&mvp, &modelView, &projection );   // create our new mvp matrix
      glUniformMatrix4fv(uniformMvp, 1, GL_FALSE, (GLfloat*) &mvp.m[0][0] ); // set the mvp uniform
      glActiveTexture(GL_TEXTURE0);
      glBindTexture(GL_TEXTURE_2D, textureId);  // bind our texture to texture0
      glUniform1i(uniformTexture, 0);           // tell the program to use texture 0
      // set the position vertex attribute with our text's vertices
      glVertexAttribPointer(ATTRIB_POSITION, 2, GL_FLOAT, false, sizeof(float)*4, verticeAndTextureCoords);
      glEnableVertexAttribArray(ATTRIB_POSITION);
      // set the texture coords
      glVertexAttribPointer(ATTRIB_TEXCOORD, 2, GL_FLOAT, false, sizeof(float)*4, verticeAndTextureCoords+2);
      glEnableVertexAttribArray(ATTRIB_TEXCOORD);
      // and finally tell the GPU to draw our triangles!
      glEnable(GL_BLEND);
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
      glDrawElements(GL_TRIANGLES, numberIndices, GL_UNSIGNED_SHORT, indices);
      glDisable(GL_BLEND);
    }
    else
    {
      glMatrixMode(GL_MODELVIEW);
      glLoadIdentity();
      glEnable(GL_BLEND);
      glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
      glEnable(GL_TEXTURE_2D);
      glEnableClientState(GL_VERTEX_ARRAY);
      glEnableClientState(GL_TEXTURE_COORD_ARRAY);
      glBindTexture(GL_TEXTURE_2D, textureId);
      glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
      glVertexPointer(2, GL_FLOAT, sizeof(GL_FLOAT)*4, verticeAndTextureCoords);
      glTexCoordPointer(2, GL_FLOAT, sizeof(GL_FLOAT)*4, verticeAndTextureCoords+2);
      glRotatef(angle, 0.0, 0.0, 1.0);         // rotate the text
      glTranslatef(-textWidth/2, 0.0f, 0.0f);  // center the text
      // flip the text right way up - not this could be removed by modifiying the way the vertices are generated
      glScalef(1.0, -1.0, 1.0);
      glDrawElements(GL_TRIANGLES, numberIndices, GL_UNSIGNED_SHORT, indices);
      glDisable(GL_BLEND);
      glDisable(GL_TEXTURE_2D);
      glDisableClientState(GL_VERTEX_ARRAY_POINTER);
      glDisableClientState(GL_TEXTURE_COORD_ARRAY_POINTER);
      glBindTexture(GL_TEXTURE_2D, 0);
    }
	
    [(EAGLView *)self.view presentFramebuffer];
}



- (void) setupView {
  if ([context API] == kEAGLRenderingAPIOpenGLES2)
  {
    esMatrixLoadIdentity(&projection);
    esOrtho(&projection, -self.view.frame.size.width/2.0, self.view.frame.size.width/2.0, -self.view.frame.size.height/2.0, self.view.frame.size.height/2.0, -5, 1);
    esMatrixLoadIdentity(&modelView);
    glViewport(0, 0, self.view.frame.size.width, self.view.frame.size.height);  
  } else {
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrthof(-self.view.frame.size.width/2.0, self.view.frame.size.width/2.0, -self.view.frame.size.height/2.0, self.view.frame.size.height/2.0, -5, 1);  
    glViewport(0, 0, self.view.frame.size.width, self.view.frame.size.height);  
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
  }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source)
    {
        NSLog(@"Failed to load vertex shader");
        return FALSE;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
        glDeleteShader(*shader);
        return FALSE;
    }
    
    return TRUE;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0)
        return FALSE;
    
    return TRUE;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0)
        return FALSE;
    
    return TRUE;
}

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    simpleProgram = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader_texture" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname])
    {
        NSLog(@"Failed to compile vertex shader");
        return FALSE;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader_texture" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname])
    {
        NSLog(@"Failed to compile fragment shader");
        return FALSE;
    }
    
    // Attach vertex shader to program.
    glAttachShader(simpleProgram, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(simpleProgram, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(simpleProgram, ATTRIB_POSITION, "position");
    
	glBindAttribLocation(simpleProgram, ATTRIB_TEXCOORD, "texcoord");
	
    // Link program.
    if (![self linkProgram:simpleProgram])
    {
        NSLog(@"Failed to link program: %d", simpleProgram);
        
        if (vertShader)
        {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader)
        {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (simpleProgram)
        {
            glDeleteProgram(simpleProgram);
            simpleProgram = 0;
        }
        
        return FALSE;
    }
    
    // Get uniform locations.
	uniformMvp = glGetUniformLocation(simpleProgram, "mvp");
    uniformTexture = glGetUniformLocation(simpleProgram, "texture");
    // Release vertex and fragment shaders.
    if (vertShader)
        glDeleteShader(vertShader);
    if (fragShader)
        glDeleteShader(fragShader);
    
    return TRUE;
}

@end
