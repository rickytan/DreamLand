//
//  DLDetailDataViewController.m
//  DreamLand
//
//  Created by ricky on 14-3-3.
//  Copyright (c) 2014年 ricky. All rights reserved.
//

#import "DLDetailDataViewController.h"
#import "DLChartView.h"
#import <CorePlot/CorePlot.h>

@interface DLSegmentButton : UIButton
@end

@implementation DLSegmentButton

- (void)awakeFromNib
{
    self.layer.cornerRadius = self.frame.size.height / 2;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.backgroundColor = self.isSelected ? [UIColor colorWithRed:61.0/255
                                                             green:4.0/255
                                                              blue:60.0/255
                                                             alpha:0.6]: [UIColor clearColor];
}

@end

@interface DLDetailDataViewController () <UIScrollViewDelegate, CPTPlotSpaceDelegate, CPTPlotDataSource>
@property (nonatomic, assign) IBOutlet UIScrollView  * scrollView;
@property (nonatomic, assign) IBOutlet UIPageControl * pageControl;
@property (nonatomic, assign) IBOutlet CPTGraphHostingView * chartView0;
@property (nonatomic, assign) IBOutlet UIButton * daysButton, * monthsButton, * allButton;
- (IBAction)onDismiss:(id)sender;
@end

@implementation DLDetailDataViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    //[self setupChart0];
    self.monthsButton.selected = YES;
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.scrollView.contentSize = CGSizeMake(3 * self.scrollView.frame.size.width, 0);

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onDismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES
                             completion:^{

                             }];
}

- (IBAction)onButton:(UIButton *)sender
{
    if (sender.isSelected)
        return;
    
    self.daysButton.selected = NO;
    self.monthsButton.selected = NO;
    self.allButton.selected = NO;
    sender.selected = YES;
}

- (void)setupChart0
{
    // Create graph from theme
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.chartView0.bounds];

    self.chartView0.collapsesLayers = NO;
    self.chartView0.allowPinchScaling = NO;
    self.chartView0.hostedGraph = graph;

    graph.plotAreaFrame.paddingBottom += 30.0;
    graph.plotAreaFrame.paddingLeft += 30.0;

    // Add plot space for bar charts
    CPTXYPlotSpace *barPlotSpace = [[[CPTXYPlotSpace alloc] init] autorelease];

    barPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.0f) length:CPTDecimalFromFloat(7.0f)];
    barPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.0f) length:CPTDecimalFromFloat(7.0f)];
    [graph addPlotSpace:barPlotSpace];

    // Create grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 1.0f;
    majorGridLineStyle.lineColor = [CPTColor whiteColor];

    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = .5f;
    minorGridLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:0.25];

    // Create axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    {
        x.majorIntervalLength         = CPTDecimalFromInteger(1);
        x.minorTicksPerInterval       = 0;
        x.orthogonalCoordinateDecimal = CPTDecimalFromInteger(0);
        x.majorGridLineStyle          = majorGridLineStyle;
        x.minorGridLineStyle          = minorGridLineStyle;
        x.axisLineStyle               = nil;
        x.majorTickLineStyle          = nil;
        x.minorTickLineStyle          = nil;
        x.labelOffset                 = 10.0;
        CPTMutableTextStyle *style    = [CPTMutableTextStyle textStyle];
        style.fontName                = @"HelveticaNeue";
        style.fontSize                = 12;
        style.color                   = [CPTColor colorWithCGColor:THEME_COLOR.CGColor];
        x.labelTextStyle              = style;
        x.visibleRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-0.5f) length:CPTDecimalFromFloat(7.0f)];
        x.gridLinesRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(7.0f)];


        x.title       = @"X Axis";
        x.titleOffset = 30.0f;

        x.titleLocation = CPTDecimalFromInteger(5);

        x.plotSpace = barPlotSpace;
    }

    CPTXYAxis *y = axisSet.yAxis;
    {
        y.majorIntervalLength         = CPTDecimalFromInteger(10);
        y.minorTicksPerInterval       = 9;
        y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(-0.5);

        y.preferredNumberOfMajorTicks = 8;
        y.majorGridLineStyle          = majorGridLineStyle;
        y.minorGridLineStyle          = minorGridLineStyle;
        y.axisLineStyle               = nil;
        y.majorTickLineStyle          = nil;
        y.minorTickLineStyle          = nil;
        y.labelOffset                 = 10.0;
        y.labelRotation               = 0;

        NSNumberFormatter *formatter  = [[[NSNumberFormatter alloc] init] autorelease];
        y.labelFormatter              = formatter;

        CPTMutableTextStyle *style    = [CPTMutableTextStyle textStyle];
        style.fontName                = @"HelveticaNeue-Light";
        style.fontSize                = 12;
        style.color                   = [CPTColor colorWithCGColor:THEME_COLOR.CGColor];
        y.labelTextStyle              = style;

        y.visibleRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(7.0f)];
        y.gridLinesRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(7.0f)];


        y.title       = @"Y Axis";
        y.titleOffset = 30.0f;
        y.titleLocation = CPTDecimalFromInteger(55);

        y.plotSpace = barPlotSpace;
    }

    // Set axes
    graph.axisSet.axes = [NSArray arrayWithObjects:x, y, nil];

    // Create a bar line style
    CPTMutableLineStyle *barLineStyle = [[[CPTMutableLineStyle alloc] init] autorelease];
    barLineStyle.lineWidth = 1.0;
    barLineStyle.lineColor = [CPTColor whiteColor];

    // Create first bar plot
    CPTBarPlot *barPlot = [[[CPTBarPlot alloc] init] autorelease];
    barPlot.lineStyle       = barLineStyle;
    barPlot.fill            = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:1.0f green:0.0f blue:0.5f alpha:0.5f]];
    barPlot.barBasesVary    = YES;
    barPlot.barWidth        = CPTDecimalFromFloat(0.5f); // bar is 50% of the available space
    barPlot.barCornerRadius = 10.0f;

    barPlot.barsAreHorizontal = NO;

    CPTMutableTextStyle *whiteTextStyle = [CPTMutableTextStyle textStyle];
    whiteTextStyle.color   = [CPTColor whiteColor];
    barPlot.labelTextStyle = whiteTextStyle;

    barPlot.delegate   = self;
    barPlot.dataSource = self;
    barPlot.identifier = @"Bar Plot 1";

    [graph addPlot:barPlot toPlotSpace:barPlotSpace];

    // Create second bar plot
    CPTBarPlot *barPlot2 = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blueColor] horizontalBars:NO];

    barPlot2.lineStyle    = barLineStyle;
    barPlot2.fill         = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:0.0f green:1.0f blue:0.5f alpha:0.5f]];
    barPlot2.barBasesVary = YES;

    barPlot2.barWidth = CPTDecimalFromFloat(1.0f); // bar is full (100%) width
    //	barPlot2.barOffset = -0.125f; // shifted left by 12.5%
    barPlot2.barCornerRadius = 2.0f;
#if HORIZONTAL
    barPlot2.barsAreHorizontal = YES;
#else
    barPlot2.barsAreHorizontal = NO;
#endif
    barPlot2.delegate   = self;
    barPlot2.dataSource = self;
    barPlot2.identifier = @"Bar Plot 2";

    [graph addPlot:barPlot2 toPlotSpace:barPlotSpace];

    // Add legend
    CPTLegend *theLegend = [CPTLegend legendWithGraph:graph];
    theLegend.numberOfRows    = 2;
    theLegend.fill            = [CPTFill fillWithColor:[CPTColor colorWithGenericGray:0.15]];
    theLegend.borderLineStyle = barLineStyle;
    theLegend.cornerRadius    = 10.0;
    theLegend.swatchSize      = CGSizeMake(20.0, 20.0);
    whiteTextStyle.fontSize   = 16.0;
    theLegend.textStyle       = whiteTextStyle;
    theLegend.rowMargin       = 10.0;
    theLegend.paddingLeft     = 12.0;
    theLegend.paddingTop      = 12.0;
    theLegend.paddingRight    = 12.0;
    theLegend.paddingBottom   = 12.0;


    NSArray *plotPoint = [NSArray arrayWithObjects:[NSNumber numberWithInteger:0], [NSNumber numberWithInteger:7], nil];

    CPTPlotSpaceAnnotation *legendAnnotation = [[[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:barPlotSpace anchorPlotPoint:plotPoint] autorelease];
    legendAnnotation.contentLayer = theLegend;

    legendAnnotation.contentAnchorPoint = CGPointMake(0.0, 1.0);
    [graph.plotAreaFrame.plotArea addAnnotation:legendAnnotation];
    
    [graph release];
}

- (void)updatePageControl
{
    self.pageControl.currentPage = (NSInteger)floorf(self.scrollView.contentOffset.x / self.scrollView.frame.size.width + 0.5);
}

#pragma mark - UIScroll Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updatePageControl];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
        [self updatePageControl];
}

#pragma mark - Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return 7;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot
                     field:(NSUInteger)fieldEnum
               recordIndex:(NSUInteger)index
{
    NSNumber *num = nil;

    if ( fieldEnum == CPTBarPlotFieldBarLocation ) {
        // location
        if ( [plot.identifier isEqual:@"Bar Plot 2"] ) {
            num = [NSDecimalNumber numberWithInt:index];
        }
        else {
            num = [NSDecimalNumber numberWithInt:index];
        }
    }
    else if ( fieldEnum == CPTBarPlotFieldBarTip ) {
        // length
        if ( [plot.identifier isEqual:@"Bar Plot 2"] ) {
            num = [NSDecimalNumber numberWithInt:index];
        }
        else {
            num = [NSDecimalNumber numberWithInt:(index + 1) * (index + 1)];
        }
    }
    else {
        // base
        if ( [plot.identifier isEqual:@"Bar Plot 2"] ) {
            num = [NSDecimalNumber numberWithInt:0];
        }
        else {
            num = [NSDecimalNumber numberWithInt:index];
        }
    }

    return num;
}

@end
