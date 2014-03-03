//
//  DLDataCurverView.m
//  DreamLand
//
//  Created by ricky on 14-3-3.
//  Copyright (c) 2014年 ricky. All rights reserved.
//

#import "DLDataCurveView.h"
#import <CorePlot/CorePlot.h>

@implementation DLDataCurveView
{
    int                granularity;
    CAGradientLayer * _gradientLayer;
    CAShapeLayer    * _overlayShapeLayer;
}

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib
{
    granularity = 16;

    self.backgroundColor = [UIColor clearColor];
    CAShapeLayer *shape = (CAShapeLayer *)self.layer;
    shape.fillColor = [UIColor clearColor].CGColor;
    shape.strokeColor = THEME_COLOR.CGColor;
    shape.lineWidth = 2.0;
    shape.masksToBounds = YES;

    CAShapeLayer *shapeCopy = [CAShapeLayer layer];
    shapeCopy.fillColor = [UIColor clearColor].CGColor;
    shapeCopy.strokeColor = [UIColor whiteColor].CGColor;
    shapeCopy.lineWidth = 2.0;
    shapeCopy.frame = shape.bounds;
    shapeCopy.masksToBounds = YES;
    [self.layer addSublayer:shapeCopy];
    _overlayShapeLayer = shapeCopy;

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.colors = @[(id)[UIColor whiteColor].CGColor, (id)[UIColor clearColor].CGColor];
    gradient.locations = @[[NSNumber numberWithFloat:0], [NSNumber numberWithFloat:1]];
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint = CGPointMake(0, 1);
    gradient.frame = self.layer.bounds;
    shapeCopy.mask = gradient;
    _gradientLayer = gradient;

    self.data = @[[NSValue valueWithCGPoint:CGPointMake(0, 4)],
                  [NSValue valueWithCGPoint:CGPointMake(8, 4)],
                  [NSValue valueWithCGPoint:CGPointMake(10, 5)],
                  [NSValue valueWithCGPoint:CGPointMake(16, 90)],
                  [NSValue valueWithCGPoint:CGPointMake(30, 68)],
                  [NSValue valueWithCGPoint:CGPointMake(48, 92)],
                  [NSValue valueWithCGPoint:CGPointMake(54, 94)],
                  [NSValue valueWithCGPoint:CGPointMake(60, 78)],
                  [NSValue valueWithCGPoint:CGPointMake(68, 66)],
                  [NSValue valueWithCGPoint:CGPointMake(100, 50)],
                  [NSValue valueWithCGPoint:CGPointMake(125, 80)],
                  [NSValue valueWithCGPoint:CGPointMake(140, 20)],
                  [NSValue valueWithCGPoint:CGPointMake(155, 40)],
                  [NSValue valueWithCGPoint:CGPointMake(160, 100)],
                  [NSValue valueWithCGPoint:CGPointMake(168, 78)],
                  [NSValue valueWithCGPoint:CGPointMake(174, 66)],
                  [NSValue valueWithCGPoint:CGPointMake(180, 50)],
                  [NSValue valueWithCGPoint:CGPointMake(200, 80)],
                  [NSValue valueWithCGPoint:CGPointMake(210, 20)],
                  [NSValue valueWithCGPoint:CGPointMake(255, 2)],
                  [NSValue valueWithCGPoint:CGPointMake(280, 100)],
                  [NSValue valueWithCGPoint:CGPointMake(284, 78)],
                  [NSValue valueWithCGPoint:CGPointMake(289, 26)],
                  [NSValue valueWithCGPoint:CGPointMake(298, 50)],
                  [NSValue valueWithCGPoint:CGPointMake(310, 80)]];
}

- (void)setData:(NSArray *)data
{
    if (_data != data) {
        [_data release];
        _data = [data retain];
        [self updateShape];
    }
}

- (void)updateShape
{
    CAShapeLayer *shape = (CAShapeLayer *)self.layer;
    shape.path = [self buildPath];
    _overlayShapeLayer.path = shape.path;

    CGFloat min = self.frame.size.height, max = 0;
    for (NSValue *v in self.data) {
        CGFloat y = [v CGPointValue].y;
        if (y < min)
            min = y;
        if (y > max)
            max = y;
    }
    _gradientLayer.frame = CGRectMake(0, min - 2, self.frame.size.width, max - min + 4);
}

- (CGPathRef)buildPath
{
    if (self.data.count < 2)
        return NULL;

    UIBezierPath *path = [UIBezierPath bezierPath];
    if (self.data.count == 2) {
        [path moveToPoint:[self.data.firstObject CGPointValue]];
        [path addLineToPoint:[self.data.lastObject CGPointValue]];
    }
    else if (self.data.count == 3) {
        [path moveToPoint:[self.data.firstObject CGPointValue]];
        [path addQuadCurveToPoint:[self.data.lastObject CGPointValue]
                     controlPoint:[self.data[1] CGPointValue]];
    }
    else {
        NSMutableArray *points = (NSMutableArray*)[self.data mutableCopy];

        // Add control points to make the math make sense
        [points insertObject:[points objectAtIndex:0] atIndex:0];
        [points addObject:[points lastObject]];

#define POINT(__i) ([points[(__i)] CGPointValue])

        [path moveToPoint:POINT(0)];

        for (NSUInteger index = 1; index < points.count - 2; index++)
        {
            CGPoint p0 = POINT(index - 1);
            CGPoint p1 = POINT(index);
            CGPoint p2 = POINT(index + 1);
            CGPoint p3 = POINT(index + 2);

            // now add n points starting at p1 + dx/dy up until p2 using Catmull-Rom splines
            for (int i = 1; i < granularity; i++)
            {
                float t = (float) i * (1.0f / (float) granularity);
                float tt = t * t;
                float ttt = tt * t;

                CGPoint pi; // intermediate point
                pi.x = 0.5 * (2*p1.x+(p2.x-p0.x)*t + (2*p0.x-5*p1.x+4*p2.x-p3.x)*tt + (3*p1.x-p0.x-3*p2.x+p3.x)*ttt);
                pi.y = 0.5 * (2*p1.y+(p2.y-p0.y)*t + (2*p0.y-5*p1.y+4*p2.y-p3.y)*tt + (3*p1.y-p0.y-3*p2.y+p3.y)*ttt);
                [path addLineToPoint:pi];
            }

            // Now add p2
            [path addLineToPoint:p2];
        }

        // finish by adding the last point
        [path addLineToPoint:POINT(points.count - 1)];
    }
    return path.CGPath;
}

@end
