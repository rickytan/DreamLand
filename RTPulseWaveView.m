//
//  RTPulseWaveView.m
//  DreamLand
//
//  Created by ricky on 13-5-18.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "RTPulseWaveView.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

@interface RTPulseWaveView ()
@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, retain) CADisplayLink *displayLink;
@property (nonatomic, retain) NSRunLoop *updateLoop;
@property (nonatomic, assign) NSTimeInterval framesPerSecond;   // Default is 60.0
- (void)update:(id)sender;
- (void)setupGL;
- (void)tearDownGL;
@end

@implementation RTPulseWaveView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (void)setupGL
{
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    
    eaglLayer.opaque = YES;
    eaglLayer.backgroundColor = [UIColor blackColor].CGColor;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,
                                    kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    
    
    self.context = [[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1] autorelease];
    
    if (!self.context || ![EAGLContext setCurrentContext:self.context]) {
        NSAssert(NO, @"GL Context Init fail!");
    }
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    // Enable use of the texture
    glEnable(GL_TEXTURE_2D);
    // Enable blending
    glEnable(GL_BLEND);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	glEnable(GL_DEPTH_TEST);
	glEnable(GL_LINE_SMOOTH);
	glEnable(GL_POINT_SMOOTH);
	
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrthof(-1.0f, 1.0f, -1.2f, 1.2f, -1.0f, 1.0f);

    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClearDepthf(1.0);
}

- (void)tearDownGL
{
    
}

- (void)commonInit
{
    
    self.contentScaleFactor = [UIScreen mainScreen].scale;
    [self setupGL];
    
    self.updateLoop = [NSRunLoop currentRunLoop];

    self.displayLink = [CADisplayLink displayLinkWithTarget:self
                                                   selector:@selector(update:)];
    self.displayLink.frameInterval = 1.0;
    [self.displayLink addToRunLoop:self.updateLoop
                           forMode:NSDefaultRunLoopMode];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.displayLink invalidate];
    [self.displayLink removeFromRunLoop:self.updateLoop
                                forMode:NSDefaultRunLoopMode];
    self.displayLink = nil;
    self.updateLoop = nil;
    [self tearDownGL];
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (void)applicationDidEnterBackground:(NSNotification*)notification
{
    self.displayLink.paused = YES;
}

- (void)applicationWillEnterForeground:(NSNotification*)notification
{
    self.displayLink.paused = NO;
}

- (void)render
{
    // Drawing code
    
    [EAGLContext setCurrentContext:self.context];
    
	//float currLevel = curve[(MAX_CURVE_POINT_NO + curveStart - 1) % MAX_CURVE_POINT_NO];
	
	for (int i = 0; i < MAX_CURVE_POINT_NO; i++) {
		lineVertices[i].x = 2.0 * i / MAX_CURVE_POINT_NO - 1.0; // X
		lineVertices[i].y = curve[(i + curveStart) % MAX_CURVE_POINT_NO]; // Y
	}

    

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
	
    
	glTranslatef(-0.05, 0, 0);
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    /*
	glEnable(GL_TEXTURE_2D);
     glVertexPointer(2, GL_FLOAT, 0, spriteVertices);
     glEnableClientState(GL_VERTEX_ARRAY);
     glTexCoordPointer(2, GL_SHORT, 0, spriteTexcoords);
     glEnableClientState(GL_TEXTURE_COORD_ARRAY);
     
    
	glPushMatrix();
	glTranslatef(1.0, currLevel, -0.01);
	glColor4f(0.0, 0.5, 1.0, 1.0);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glPopMatrix();
     */
	
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_DEPTH_TEST);
	
    glVertexPointer(2, GL_FLOAT, 0, lineVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    
    
	glLineWidth(9.0 * self.contentScaleFactor);
	glPointSize(9.0 * self.contentScaleFactor);
	glColor4f(0.0, 0.5, 1.0, 0.2);
    glDrawArrays(GL_LINE_STRIP, 0, MAX_CURVE_POINT_NO);
	glPointSize(13.0 * self.contentScaleFactor);
	glDrawArrays(GL_POINTS, MAX_CURVE_POINT_NO-1, 1);
    
	glTranslatef(0, 0, .01);
	
	glLineWidth(5.0 * self.contentScaleFactor);
	glPointSize(5.0 * self.contentScaleFactor);
	glColor4f(0.0, 0.5, 1.0, 0.7);
    glDrawArrays(GL_LINE_STRIP, 0, MAX_CURVE_POINT_NO);
	glPointSize(7.0 * self.contentScaleFactor);
	glDrawArrays(GL_POINTS, MAX_CURVE_POINT_NO-1, 1);
    
	glTranslatef(0, 0, .01);
    
	glLineWidth(1.0 * self.contentScaleFactor);
	glPointSize(1.0 * self.contentScaleFactor);
	glColor4f(1.0, 1.0, 1.0, 1.0);
    glDrawArrays(GL_LINE_STRIP, 0, MAX_CURVE_POINT_NO);
	glPointSize(3.0 * self.contentScaleFactor);
	glDrawArrays(GL_POINTS, MAX_CURVE_POINT_NO - 1, 1);
    
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [self.context presentRenderbuffer:GL_RENDERBUFFER_OES];
	
    static double lastValue = 0.0;
    if (self.dataSource && !self.displayLink.isPaused) {
        double value = [self.dataSource pulseWaveView:self
                                        valueOfTime:self.displayLink.timestamp];
        self.value = (value - lastValue) / self.displayLink.duration;
        self.value = MIN(MAX(self.value, -1), 1);
        lastValue = value;
    }
	curve[curveStart] = self.value;
	curveStart = (curveStart + 1) % MAX_CURVE_POINT_NO;
    curve[curveStart] = 0.0;
}


- (void)layoutSubviews {
    [EAGLContext setCurrentContext:self.context];
    [self destroyFramebuffer];
    [self createFramebuffer];
    [self render];
}


- (BOOL)createFramebuffer {
    
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    [self.context renderbufferStorage:GL_RENDERBUFFER_OES
                         fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glViewport(0, 0, backingWidth, backingHeight);
    
    glClearColor(0.0, 0.0, 0.0, 0.0);
    
    glGenRenderbuffersOES(1, &depthRenderbuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
    glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    return YES;
}


- (void)destroyFramebuffer {
    
    glDeleteFramebuffersOES(1, &viewFramebuffer);
    viewFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &viewRenderbuffer);
    viewRenderbuffer = 0;
    
    if(depthRenderbuffer) {
        glDeleteRenderbuffersOES(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
}

- (void)update:(id)sender
{
    [self render];
}

- (void)setFramesPerSecond:(NSTimeInterval)framesPerSecond
{
    if (_framesPerSecond != framesPerSecond) {
        _framesPerSecond = framesPerSecond;
        [self.displayLink invalidate];
        self.displayLink = [CADisplayLink displayLinkWithTarget:self
                                                       selector:@selector(update:)];
        self.displayLink.frameInterval = 60.0 / _framesPerSecond;
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop]
                               forMode:NSRunLoopCommonModes];
    }
}

- (void)setPaused:(BOOL)paused
{
    self.displayLink.paused = paused;
}

- (BOOL)isPaused
{
    return self.displayLink.isPaused;
}

- (void)clear
{
    self.value = 0.0;
    memset(curve, 0, sizeof(CGFloat) * MAX_CURVE_POINT_NO);
    [self render];
}

@end
