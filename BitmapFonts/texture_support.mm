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

#include "texture_support.h"

GLuint loadTexture(const char *inFileName, int inWidth, int inHeight) {
	glEnable(GL_TEXTURE_2D);
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);  
	GLuint texture;
	glGenTextures(1, &texture);
	glBindTexture(GL_TEXTURE_2D, texture);
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_MIRRORED_REPEAT_OES);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_MIRRORED_REPEAT_OES);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); 
	glBlendFunc(GL_ONE, GL_SRC_COLOR);
	
	NSString *fname=[NSString stringWithUTF8String:inFileName];
	NSString *extension = [fname pathExtension];
	NSString *baseFilenameWithExtension = [fname lastPathComponent];
	NSString *baseFilename = [baseFilenameWithExtension substringToIndex:[baseFilenameWithExtension length] - [extension length] - 1];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:baseFilename ofType:extension];
	NSData *texData = [[NSData alloc] initWithContentsOfFile:path];
	
	// Assumes pvr4 is RGB not RGBA, which is how texturetool generates them
	if ([extension isEqualToString:@"pvr4"])
		glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG, inWidth, inHeight, 0, (inWidth * inHeight) / 2, [texData bytes]);
	else if ([extension isEqualToString:@"pvr2"])
		glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG, inWidth, inHeight, 0, (inWidth * inHeight) / 2, [texData bytes]);
	else
	{
		UIImage *image = [[UIImage alloc] initWithData:texData];
		if (image == nil)
			return 0;
		
		GLuint width = CGImageGetWidth(image.CGImage);
		GLuint height = CGImageGetHeight(image.CGImage);
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		void *imageData = malloc( height * width * 4 );
		CGContextRef context = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
		CGColorSpaceRelease( colorSpace );
		CGContextClearRect( context, CGRectMake( 0, 0, width, height ) );
		CGContextDrawImage( context, CGRectMake( 0, 0, width, height ), image.CGImage );
		
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
		//			glGenerateMipmapEXT(GL_TEXTURE_2D);  //Generate mipmaps now!!!
		//GLuint errorcode = glGetError();
		CGContextRelease(context);
		
		free(imageData);
		[image release];
	}
	return texture;
}
