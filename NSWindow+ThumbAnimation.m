// COMMON FILE: Common
//
//  NSWindow+ThumbAnimation.m
//  ThumbAnim
//
//  Created by Uncle MiF on 4/12/10.
//  Copyright 2010 Deep IT. All rights reserved.
//

#import "NSWindow+ThumbAnimation.h"
#import <QuartzCore/QuartzCore.h>

NSString*		NSWindowAnimationFromFrameDidFinished = @"NSWindowAnimationFromFrameDidFinished";


static NSMutableDictionary * _storage = nil;

@implementation NSWindow (ThumbAnimation)

-(NSMutableDictionary*)_ta_storage
{
	if (!_storage)
		@synchronized(@"ta_storage")
		{
			if (!_storage)
				_storage = [NSMutableDictionary new];
		}
	return _storage;
}

-(id)_ta_storageObjectForKey:(NSString*)key
{
	NSMutableDictionary* storage = [self _ta_storage];
	id obj = nil;
	@synchronized(storage)
	{
		obj = [[[storage objectForKey:key] retain] autorelease];
	}
	return obj;
}

-(void)_ta_setStorageObject:(id)object forKey:(NSString*)key
{
	NSMutableDictionary* storage = [self _ta_storage];
	@synchronized(storage)
	{
		if (!object)
			[storage removeObjectForKey:key];
		else
			[storage setObject:object forKey:key];
	}
}

#define TACachedView @"cachedView"
-(NSView*)_ta_cachedView
{
	return [self _ta_storageObjectForKey:TACachedView];
}

#define TAOldContent @"oldContent"
-(NSView*)_ta_oldContent
{
	return [self _ta_storageObjectForKey:TAOldContent];
}

-(void)_ta_setCachedView:(NSView*)view
{
	[self _ta_setStorageObject:view forKey:TACachedView];
}

-(void)_ta_setOldContent:(NSView*)view
{
	[self _ta_setStorageObject:view forKey:TAOldContent];
}

-(void)animateFromFrame:(NSRect)fromRect toFrame:(NSRect)toRect
{
	NSView* windowView = [[self contentView] opaqueAncestor];		
	NSBitmapImageRep* bitmap = nil;
	NSRect windowRect = [windowView frame];
	@try
	{
		if ([self isVisible])
			[self orderOut:self];
		[self setFrame:toRect display:NO];
		[self display];
				
		[windowView lockFocus];			
		@try
		{
			bitmap = [[[NSBitmapImageRep alloc] initWithFocusedViewRect: windowRect] autorelease];
		}
		@catch(id universal){}			
		[windowView unlockFocus];			
		if (!bitmap)
			@throw(@"No bitmap");
	}
	@catch(id universal)
	{
		[self makeKeyAndOrderFront:self];
		return;
	}
	
	NSImage* image = [[[NSImage alloc] initWithSize: [bitmap size]] autorelease];
	
	NSImageView * imageView = nil;
	if (image)
	{
		
		[image addRepresentation: bitmap];
		
		imageView = [[[NSImageView alloc] initWithFrame: windowRect] autorelease];
		[imageView setAutoresizingMask: 
		 NSViewMinYMargin | NSViewMaxYMargin | NSViewMinXMargin | NSViewMaxXMargin | 
		 NSViewHeightSizable | NSViewWidthSizable];
		[imageView setImage: image];
		[imageView setImageScaling:NSScaleToFit];
	}
	
	if (imageView)
	{
		[self _ta_setOldContent:[self contentView]];
		
		NSView * emptyView = [[[NSView alloc] initWithFrame:[[self contentView] frame]] autorelease];
		[emptyView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
		[self setContentView:emptyView];
		
		[windowView addSubview:imageView];
		
		[self _ta_setCachedView:imageView];
		
		if ([self isVisible])
			[self orderOut:self];
		[self setFrame:fromRect display:NO];
		[self setAlphaValue:0.4];
		[self orderFront:self];
		
		CABasicAnimation * frameAnimation = [CABasicAnimation animationWithKeyPath:@"frame"];
		frameAnimation.delegate = self;
		frameAnimation.duration = .5;
		frameAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
		
		CABasicAnimation * alphaValueAnimation = [CABasicAnimation animationWithKeyPath:@"alphaValue"];
		alphaValueAnimation.duration = .5;
		alphaValueAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
		
		[self setAnimations:[NSDictionary dictionaryWithObjectsAndKeys:
							 frameAnimation,@"frame",
							 alphaValueAnimation,@"alphaValue",
							 nil]];
		
		[NSAnimationContext beginGrouping];
		[[self	animator] setFrame:toRect display:NO];
		[[self	animator] setAlphaValue:1.0];
		[NSAnimationContext endGrouping];
	}
	else
		[self makeKeyAndOrderFront:self];
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag
{
#pragma unused(flag)
	[animation setDelegate:nil];
	
	[self setContentView:[self _ta_oldContent]];
	[self _ta_setOldContent:nil];
	
	[[self _ta_cachedView] removeFromSuperview];
	[self _ta_setCachedView:nil];
		
	[self setToolbar:[self toolbar]];
	[self makeKeyAndOrderFront:self];
	[self flushWindow];
	[self display];
	
	if ([self respondsToSelector:@selector(animationFromFrameDidFinished)])
		[self performSelector:@selector(animationFromFrameDidFinished)];
	
	if ([[self windowController] respondsToSelector:@selector(animationFromFrameDidFinished)])
		[[self windowController] performSelector:@selector(animationFromFrameDidFinished)];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NSWindowAnimationFromFrameDidFinished object:self];
}

@end
