//
//  Tutorial6ViewController.h
//  Tutorial6
//
//  Created by Chris Greening on 28/09/2010.
//

#import <UIKit/UIKit.h>

#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "esUtil.h"

class Font;

@interface BitmapFontsViewController : UIViewController
{
  // the font
  Font *font;
	// data to draw
  float textWidth;
  float *verticeAndTextureCoords;
  uint16_t *indices;
  int numberIndices;
	GLuint textureId;
	// angle for rotations
	float angle;
  EAGLContext *context;
  GLuint simpleProgram;
	GLuint uniformMvp;
	GLuint uniformTexture;
	
	ESMatrix modelView;
	ESMatrix projection;
	ESMatrix mvp;
	
  BOOL animating;
  BOOL displayLinkSupported;
  NSInteger animationFrameInterval;
  /*
  Use of the CADisplayLink class is the preferred method for controlling your animation timing.
  CADisplayLink will link to the main display and fire every vsync when added to a given run-loop.
  The NSTimer object is used only as fallback when running on a pre-3.1 device where CADisplayLink isn't available.
  */
  id displayLink;
  NSTimer *animationTimer;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

- (void)startAnimation;
- (void)stopAnimation;

@end
