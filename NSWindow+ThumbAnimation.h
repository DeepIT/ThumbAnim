// COMMON FILE: Common
//
//  NSWindow+ThumbAnimation.h
//  ThumbAnim
//
//  Created by Uncle MiF on 4/12/10.
//  Copyright 2010 Deep IT. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString*		NSWindowAnimationFromFrameDidFinished;


@interface NSWindow (ThumbAnimation)

// window must be configured without deffered creation
// or lockFocus exception will be generated with no animation as a result
-(void)animateFromFrame:(NSRect)fromRect toFrame:(NSRect)toRect;

@end

