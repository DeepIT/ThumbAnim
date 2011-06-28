//
//  ThumbAnimAppDelegate.m
//  ThumbAnim
//
//  Created by Uncle MiF on 4/12/10.
//  Copyright 2010 Deep IT. All rights reserved.
//

#import "ThumbAnimAppDelegate.h"
#import "NSWindow+ThumbAnimation.h"

@implementation ThumbAnimAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[self.window setLevel:NSNormalWindowLevel];
	[self.window setAlphaValue:0.0];
	[self.window orderFront:self];
	[[self.window animator] setAlphaValue:1.0];
}

-(IBAction)thumbClick:(id)sender
{
	NSRect fromRect = [thumb frame];
	fromRect.origin.x += [window frame].origin.x;
	fromRect.origin.y += [window frame].origin.y;
	[document animateFromFrame:fromRect toFrame:[document frame]];
	[self performSelector:@selector(hideTmplChooser) withObject:nil afterDelay:0.5];
}

-(void)hideTmplChooser
{
	[[self.window animator] setAlphaValue:0.0];
}

-(BOOL)windowShouldClose:(id)sender
{
	[[self.window animator] setAlphaValue:1.0];
	return YES;
}

@end
