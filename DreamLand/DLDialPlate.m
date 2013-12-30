//
//  DLDialPlate.m
//  DreamLand
//
//  Created by ricky on 13-12-30.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "DLDialPlate.h"

@implementation DLDialPlate

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.strokeWidth = 18.0;
    }
    return self;
}

- (void)setThumbImage:(UIImage *)image
{
    
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
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(10, 10, 10, 10))];

    
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
    [self drawBackgroundCircle:rect];

    UIColor* color = [UIColor colorWithRed: 0.227 green: 0.749 blue: 0.816 alpha: 1];
    
    //// Oval Drawing
    CGRect ovalRect = UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(10, 10, 10, 10));
    UIBezierPath* ovalPath = [UIBezierPath bezierPath];
    [ovalPath addArcWithCenter: CGPointMake(CGRectGetMidX(ovalRect), CGRectGetMidY(ovalRect))
                        radius: CGRectGetWidth(ovalRect) / 2
                    startAngle: -120 * M_PI/180
                      endAngle: 90 * M_PI/180
                     clockwise: YES];
    [color setStroke];
    ovalPath.lineWidth = self.strokeWidth;
    ovalPath.lineCapStyle = kCGLineCapRound;
    [ovalPath stroke];
}


@end
