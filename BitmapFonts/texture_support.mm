/*
 *  texture_support.cpp
 *  Tanks
 *
 *  Created by Chris Greening on 11/09/2010.
 *
 */

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
