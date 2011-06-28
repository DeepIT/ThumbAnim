//
//  ThumbAnimAppDelegate.h
//  ThumbAnim
//
//  Created by Uncle MiF on 4/12/10.
//  Copyright 2010 Deep IT. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ThumbAnimAppDelegate : NSObject <NSApplicationDelegate> 
{
	NSWindow *window;
	IBOutlet id thumb;
	IBOutlet id document;
}

-(IBAction)thumbClick:(id)sender;

@property (assign) IBOutlet NSWindow *window;

@end
