//
//  DLDialPlate.m
//  DreamLand
//
//  Created by ricky on 13-12-30.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "DLDialPlate.h"

#define kImageThumbTag      113

@implementation DLDialPlate

- (void)commonInit
{
    self.strokeWidth = 4.0;
    self.strokeColor = [UIColor blackColor];
    self.strokeBackgroundColor = [UIColor whiteColor];
    self.startAngle = self.endAngle = 0;
    self.clockWise = YES;
    self.radius = (MIN(self.bounds.size.width, self.bounds.size.height) - self.strokeWidth) / 2;
    self.exclusiveTouch = YES;
    self.clipsToBounds = NO;
    
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"big dot.png"]];
    //image.userInteractionEnabled = YES;
    image.tag = kImageThumbTag;
    [self addSubview:image];
    [image release];
    
    [self putThumb];
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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)setThumbImage:(UIImage *)image
{
    UIImageView *imageView = (UIImageView *)[self viewWithTag:kImageThumbTag];
    imageView.image = image;
    [imageView sizeToFit];
    [self putThumb];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat radius = MIN(self.bounds.size.width, self.bounds.size.height);
    return CGSizeMake(radius, radius);
}

- (void)setStartAngle:(CGFloat)startAngle
{
    _startAngle = startAngle;
    [self setNeedsDisplay];
}

- (void)setEndAngle:(CGFloat)endAngle
{
    _endAngle = endAngle;
    [self putThumb];
    [self setNeedsDisplay];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self putThumb];
}

- (void)putThumb
{
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    [self viewWithTag:kImageThumbTag].center = CGPointMake(center.x + self.radius * cosf(self.endAngle), center.y + self.radius * sinf(self.endAngle));
}

- (void)drawBackgroundCircle:(CGRect)rect
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* fillColor = [UIColor colorWithRed: 0.114 green: 0.118 blue: 0.153 alpha: 1];
    UIColor* strokeColor = [UIColor colorWithRed: 0.129 green: 0.137 blue: 0.188 alpha: 1];
    
    //// Shadow Declarations
    UIColor* shadow = [UIColor grayColor];
    CGSize shadowOffset = CGSizeMake(0.0, 2.0);
    CGFloat shadowBlurRadius = 8;
    UIColor* shadow2 = [UIColor blackColor];
    CGSize shadow2Offset = CGSizeMake(0.0, -2.0);
    CGFloat shadow2BlurRadius = 4.;
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectInset(rect, self.strokeWidth / 2, self.strokeWidth / 2)];

    
    CGContextSaveGState(context);
    {
        CGContextSetShadowWithColor(context, shadow2Offset, shadow2BlurRadius, shadow2.CGColor);
        
        
        ////// Oval Inner Shadow
        CGRect ovalBorderRect = CGRectInset([ovalPath bounds],
                                            -shadowBlurRadius,
                                            -shadowBlurRadius);
        ovalBorderRect = CGRectOffset(ovalBorderRect, -shadowOffset.width, -shadowOffset.height);
        ovalBorderRect = CGRectInset(CGRectUnion(ovalBorderRect, [ovalPath bounds]), -1, -1);
        
        UIBezierPath* ovalNegativePath = [UIBezierPath bezierPathWithOvalInRect:ovalBorderRect];
        [ovalNegativePath appendPath: ovalPath];
        ovalNegativePath.usesEvenOddFillRule = YES;
        
        CGContextSaveGState(context);
        {
            CGFloat xOffset = shadowOffset.width + round(ovalBorderRect.size.width);
            CGFloat yOffset = shadowOffset.height;
            CGContextSetShadowWithColor(context,
                                        CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                        shadowBlurRadius,
                                        shadow.CGColor);
            
            [ovalPath addClip];
            CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(ovalBorderRect.size.width), 0);
            [ovalNegativePath applyTransform: transform];
            [[UIColor grayColor] setFill];
            [ovalNegativePath fill];
        }
        CGContextRestoreGState(context);
    }
    CGContextRestoreGState(context);
    
    
    [fillColor setFill];
    [ovalPath fill];
    [strokeColor setStroke];
    ovalPath.lineWidth = self.strokeWidth;
    [ovalPath stroke];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //[self drawBackgroundCircle:rect];
    
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPath];
    [ovalPath addArcWithCenter: CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2)
                        radius: self.radius
                    startAngle: self.startAngle
                      endAngle: self.endAngle
                     clockwise: self.endAngle > self.startAngle];
    ovalPath.lineWidth = self.strokeWidth;
    ovalPath.lineCapStyle = kCGLineCapRound;

    [self.backgroundImage drawInRect:UIEdgeInsetsInsetRect(rect, self.contentInsets)];
    [self.strokeColor setStroke];
    [ovalPath stroke];
    [self.shadowImage drawInRect:UIEdgeInsetsInsetRect(rect, self.contentInsets)];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch
                     withEvent:(UIEvent *)event
{
    CGPoint p = [touch locationInView:self];
    if (CGRectContainsPoint(CGRectInset([self viewWithTag:kImageThumbTag].frame, -self.strokeWidth, -self.strokeWidth), p)) {
        
        return YES;
    }
    return NO;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch
                        withEvent:(UIEvent *)event
{
    CGPoint p = [touch locationInView:self];
    p.x -= self.bounds.size.width / 2;
    p.y -= self.bounds.size.height / 2;
    CGFloat v = atan2f(p.y, p.x);
    self.endAngle = v;
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch
                   withEvent:(UIEvent *)event
{
    CGPoint p = [touch locationInView:self];
    p.x -= self.bounds.size.width / 2;
    p.y -= self.bounds.size.height / 2;
    CGFloat v = atan2f(p.y, p.x);
    self.endAngle = v;
}


@end
