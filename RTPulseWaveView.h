//
//  RTPulseWaveView.h
//  DreamLand
//
//  Created by ricky on 13-5-18.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#define MAX_CURVE_POINT_NO 120

@class RTPulseWaveView;

@protocol RTPulseWaveViewDatasource <NSObject>
@required
- (double)pulseWaveView:(RTPulseWaveView*)waveview
            valueOfTime:(NSTimeInterval)time;
@end

@interface RTPulseWaveView : UIView
{
@private
    /* The pixel dimensions of the backbuffer */
    GLint backingWidth;
    GLint backingHeight;
    
    /* OpenGL names for the renderbuffer and framebuffers used to render to this view */
    GLuint viewRenderbuffer, viewFramebuffer;
    
    GLuint msaaRenderbuffer, msaaDepthbuffer, msaaFramebuffer;
    
    /* OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist) */
    GLuint depthRenderbuffer;
	GLuint texture;
    
    CGPoint lineVertices[MAX_CURVE_POINT_NO];
    
	CGFloat curve[MAX_CURVE_POINT_NO];
	int curveStart;

}
@property (nonatomic, readonly) EAGLContext *context;
@property (nonatomic, assign, getter = isPaused) BOOL paused;   // Default is NO
@property (nonatomic, retain) UIColor *waveColor;
/*
 * You must use one of the following to method to set value
 */
@property (nonatomic, assign) IBOutlet id<RTPulseWaveViewDatasource> dataSource;
@property (nonatomic, assign) double value;    // The value better in range [-1.0, 1.0]
- (void)clear;
@end
