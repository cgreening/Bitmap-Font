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
