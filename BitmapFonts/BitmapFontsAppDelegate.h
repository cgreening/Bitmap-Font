//
//  BitmapFontsAppDelegate.h
//  BitmapFonts
//
//  Created by Chris Greening on 14/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BitmapFontsViewController;

@interface BitmapFontsAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet BitmapFontsViewController *viewController;

@end
