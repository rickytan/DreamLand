//
//  DLViewController.m
//  DreamLand
//
//  Created by ricky on 13-5-12.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "DLViewController.h"
#import <CFNetwork/CFNetwork.h>
#if !TARGET_IPHONE_SIMULATOR && USE_BLUETOOTH
#import <btstack/hci_cmds.h>
#import <BTstack/BTDevice.h>
#import <BTstack/BTStackManager.h>
#import <BTstack/BTDiscoveryViewController.h>
#endif
#import "DLDataRecorder.h"
#import "DLDataProvider.h"
#import "RTPulseWaveView.h"
#import "DLHistoryListViewController.h"
#import "DLData.h"
#import "SVProgressHUD.h"

#define BLUETOOTH_DEVICE_UUID @"00001101-0000-1000-8000-00805F9B34FB"

@interface DLViewController ()
<
#if !TARGET_IPHONE_SIMULATOR && USE_BLUETOOTH
BTDiscoveryDelegate,
BTstackManagerDelegate,
BTstackManagerListener,
#endif
CPTAxisDelegate,
CPTPlotDataSource,
CPTPlotDelegate,
CPTPlotSpaceDelegate,
UIActionSheetDelegate,
RTPulseWaveViewDatasource>
{
    double                      xValue,yValue,zValue;
    double                      smoothRatio;
    
    DLDataBuffer               *dataBuffer;
    
    CPTXYGraph                 *graph;
}
@property (nonatomic, assign, getter = isRecording) BOOL recording;
@property (nonatomic, retain) NSMutableArray *xValue;
@property (nonatomic, retain) NSMutableArray *yValue;
@property (nonatomic, retain) NSArray *dataArray;
@property (nonatomic, assign) NSUInteger recordID;
@property (nonatomic, assign) CPTGraphHostingView *graphHostingView;
#if !TARGET_IPHONE_SIMULATOR && USE_BLUETOOTH
@property (nonatomic, retain) BTDevice *selectedDevice;
@property (nonatomic, assign, getter = isBluetoothConnected) BOOL bluetoothConnected;
#endif
- (void)initGraph;
- (BOOL)viewDataOfFile:(NSString*)filePath;
- (BOOL)viewDataOfRecordID:(NSUInteger)record;
@end

@implementation DLViewController
@synthesize xValue = _xValue;
@synthesize yValue = _yValue;
@synthesize graphHostingView = _graphHostingView;


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        dataBuffer = [[DLDataBuffer alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [dataBuffer release];
    
    self.xValue = nil;
    self.yValue = nil;
    
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
    
    self.graphHostingView = [[[CPTGraphHostingView alloc] initWithFrame:self.contentView.bounds] autorelease];
    self.graphHostingView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:self.graphHostingView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    smoothRatio = 0.6;
    self.pulseView.paused = YES;
    
#if !TARGET_IPHONE_SIMULATOR && USE_BLUETOOTH
    [[BTStackManager sharedInstance] setDelegate:self];
    [[BTStackManager sharedInstance] addListener:self];
    
    [[BTStackManager sharedInstance] activate];
#endif
    
    //CIDetector *detector = [[CIDetector detectorOfType:CIDetectorTypeFace
    //                                           context:<#(CIContext *)#> options:<#(NSDictionary *)#>]]
    
    
    [self initGraph];
    self.state = DLViewStateNormal;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        /*
         NSUInteger lastRecord = [DLDataRecorder sharedRecorder].lastestRecordID;
         NSDate *start = [[DLDataProvider sharedProvider] startTimeOfRecord:lastRecord];
         NSDate *end = [[DLDataProvider sharedProvider] endTimeOfRecord:lastRecord];
         
         double min = start.timeIntervalSince1970;
         double max = end.timeIntervalSince1970;
         
         double len = MIN(max - min, 1200);
         
         CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
         plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(min)
         length:CPTDecimalFromDouble(len)];
         //[graph reloadData];
         */
        self.recordID = [DLDataRecorder sharedRecorder].lastestRecordID;
        [self viewDataOfRecordID:self.recordID];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    ((DLHistoryListViewController*)((UINavigationController*)segue.destinationViewController).topViewController).delegate = self;
}

#pragma mark - Actions

- (IBAction)onStart:(UIBarButtonItem*)sender
{
    switch (self.state) {
        case DLViewStateRecording:
            [[DLDataRecorder sharedRecorder] stop];
            self.pulseView.paused = YES;
            self.state = DLViewStatePaused;
            break;
        case DLViewStateNormal:
        case DLViewStatePaused:
            [[DLDataRecorder sharedRecorder] start];
            [self.pulseView clear];
            self.pulseView.paused = NO;
            self.state = DLViewStateRecording;
            break;
        default:
            break;
    }
}

- (IBAction)onDone:(UIBarButtonItem *)sender
{
    switch (self.state) {
        case DLViewStateViewing:    // Reset
            self.xValue = nil;
            self.yValue = nil;
            self.state = DLViewStateNormal;
            [self.pulseView clear];
            break;
        case DLViewStateNormal:     // View History
            [self performSegueWithIdentifier:@"ViewHistory"
                                      sender:sender];
            break;
        case DLViewStatePaused:     // View Current
            self.state = DLViewStateViewing;
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //NSString *filePath = [dataBuffer flushToFile];
                
                //if ([self viewDataOfFile:filePath])
                //    [SVProgressHUD dismiss];
                if ([self viewDataOfRecordID:[DLDataRecorder sharedRecorder].lastestRecordID])
                    [SVProgressHUD dismiss];
                else
                    [SVProgressHUD showErrorWithStatus:@"文件打开错误！"];
            });
            break;
        default:
            break;
    }
}

- (IBAction)onScan:(id)sender
{
#if !TARGET_IPHONE_SIMULATOR && USE_BLUETOOTH
    BTDiscoveryViewController *discoveryController = [[BTDiscoveryViewController alloc] init];
    discoveryController.delegate = self;
    discoveryController.showIcons = YES;
    UIBarButtonItem *dismissItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                 target:self
                                                                                 action:@selector(onDismiss:)];
    discoveryController.navigationItem.leftBarButtonItem = dismissItem;
    [dismissItem release];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:discoveryController];
    [self presentModalViewController:nav
                            animated:YES];
    [discoveryController release];
    [nav release];
    
#endif
}

- (void)onDismiss:(id)sender
{
    [self.presentedViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark - Methods

- (BOOL)viewDataOfFile:(NSString *)filePath
{
    FILE *file = fopen(filePath.UTF8String, "r");
    
    if (file) {
        fseek(file, 0, SEEK_END);
        long size = ftell(file);
        
        self.xValue = [NSMutableArray arrayWithCapacity:size / sizeof(Unit)];
        self.yValue = [NSMutableArray arrayWithCapacity:size / sizeof(Unit)];
        
        fseek(file, 0, SEEK_SET);
        
        Unit unit;
        while (!feof(file)) {
            fread(&unit, sizeof(Unit), 1, file);
            [self.xValue addObject:[NSNumber numberWithDouble:unit.timestamp]];
            [self.yValue addObject:[NSNumber numberWithDouble:unit.value]];
        }
        fclose(file);
        
        double min = [[self.xValue objectAtIndex:0] doubleValue];
        double max = [[self.xValue lastObject] doubleValue];
        
        double len = MIN(max - min, 600);
        
        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
        plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(min)
                                                        length:CPTDecimalFromDouble(len)];
        [graph reloadData];
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)viewDataOfRecordID:(NSUInteger)record
{
    if (record == 0)
        return NO;
    
    self.recordID = record;
#if DEBUG
    NSDate *start = [[DLDataProvider sharedProvider] startTimeOfRecord:record];
    NSDate *end = [[DLDataProvider sharedProvider] endTimeOfRecord:record];
    NSLog(@"Start: %@, End: %@", start, end);
    
    double min = start.timeIntervalSince1970;
    double max = end.timeIntervalSince1970;
#else
    double min = [[DLDataProvider sharedProvider] startTimeOfRecord:record].timeIntervalSince1970;
    double max = [[DLDataProvider sharedProvider] endTimeOfRecord:record].timeIntervalSince1970;
#endif
    
    double len = MIN(max - min, 60*60*8);
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(min)
                                                    length:CPTDecimalFromDouble(len)];
    [self reloadPlot];
    return YES;
}

- (void)initGraph
{
    // Create graph from theme
    graph = [[CPTXYGraph alloc] init];
    CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [graph applyTheme:theme];
    CPTGraphHostingView *hostingView =self.graphHostingView;
    hostingView.collapsesLayers = NO; // Setting to YES reduces GPU memory usage, but can slow drawing/scrolling
    hostingView.hostedGraph     = graph;
    
    graph.paddingLeft   = 4.0;
    graph.paddingTop    = 4.0;
    graph.paddingRight  = 4.0;
    graph.paddingBottom = 4.0;
    
    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.delegate = self;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-2.0)
                                                    length:CPTDecimalFromFloat(4.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.5)
                                                    length:CPTDecimalFromFloat(3.0)];
    
    CPTMutableLineStyle *style = nil;
    // Axes
    CPTXYAxisSet *axisSet           = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x                    = axisSet.xAxis;
    x.majorIntervalLength           = CPTDecimalFromFloat(1.0f);
    x.orthogonalCoordinateDecimal   = CPTDecimalFromFloat(0.0f);
    x.minorTicksPerInterval         = 1;
    x.labelingPolicy                = CPTAxisLabelingPolicyAutomatic;
    //x.delegate                      = self;
    x.labelRotation                 = M_PI / 3;
    x.title                         = @"时间";
    
    style                           = [CPTMutableLineStyle lineStyle];
    style.lineColor                 = [CPTColor colorWithGenericGray:0.3];
    style.lineWidth                 = 0.5f;
    x.majorGridLineStyle            = style;
    NSDateFormatter *dateFormatter  = [[[NSDateFormatter alloc] init] autorelease];
    dateFormatter.dateStyle         = kCFDateFormatterShortStyle;
    dateFormatter.dateFormat        = @"HH:mm:ss";
    CPTTimeFormatter *timeFormatter = [[[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter] autorelease];
    //timeFormatter.referenceDate = [NSDate date];
    //x.axisLineCapMin              = CPTLineCapTypeDiamond;
    x.labelFormatter                = timeFormatter;
    CPTMutableTextStyle *textStyle  = [CPTMutableTextStyle textStyle];
    textStyle.color                 = [CPTColor greenColor];
    textStyle.fontSize              = 12.0f;
    x.labelTextStyle                = textStyle;
    
    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength           = CPTDecimalFromFloat(0.5f);
    y.orthogonalCoordinateDecimal   = CPTDecimalFromFloat(0.0f);
    y.minorTicksPerInterval         = 9;
    y.labelingPolicy                = CPTAxisLabelingPolicyAutomatic;
    y.title                         = @"振动强度（G）";
    y.titleOffset                   = 32.0;
    
    y.majorGridLineStyle            = style;
    
    style                           = [CPTMutableLineStyle lineStyle];
    style.lineColor                 = [CPTColor colorWithGenericGray:0.3];
    style.lineWidth                 = 0.25f;
    y.minorGridLineStyle            = style;
    //y.delegate             = self;
    y.axisConstraints               = [CPTConstraints constraintWithLowerOffset:64.0];
    [((NSNumberFormatter*)y.labelFormatter) setMaximumFractionDigits:2];
    
    // Create a blue plot area
    CPTScatterPlot *boundLinePlot   = [[CPTScatterPlot alloc] init];
    CPTMutableLineStyle *lineStyle  = [CPTMutableLineStyle lineStyle];
    lineStyle.miterLimit            = 1.0f;
    lineStyle.lineWidth             = 1.0f;
    lineStyle.lineColor             = [CPTColor blueColor];
    boundLinePlot.dataLineStyle     = lineStyle;
    boundLinePlot.identifier        = @"Blue Plot";
    boundLinePlot.dataSource        = self;
    //boundLinePlot.interpolation    = CPTScatterPlotInterpolationCurved;
    boundLinePlot.delegate          = self;
    [graph addPlot:boundLinePlot];
    [boundLinePlot release];
}

- (void)setState:(DLViewState)state
{
    if (_state == state)
        return;
    
    _state = state;
    switch (_state) {
        case DLViewStateNormal:
            self.startItem.enabled = YES;
            self.startItem.title = @"Start";
            self.startItem.tintColor = [UIColor blueColor];
            self.doneItem.enabled = YES;
            self.doneItem.title = @"View";
            break;
        case DLViewStateRecording:
            self.startItem.enabled = YES;
            self.startItem.title = @"Stop";
            self.startItem.tintColor = [UIColor redColor];
            self.doneItem.enabled = NO;
            break;
        case DLViewStatePaused:
            self.startItem.enabled = YES;
            self.startItem.title = @"Start";
            self.startItem.tintColor = [UIColor blueColor];
            self.doneItem.enabled = YES;
            self.doneItem.title = @"Done";
            break;
        case DLViewStateViewing:
            self.startItem.enabled = NO;
            self.doneItem.enabled = YES;
            self.doneItem.title = @"Reset";
            break;
        default:
            break;
    }
}

#pragma mark - UIActionSheet Delegate


#pragma mark - DLHistory Delegate

- (void)historyList:(DLHistoryListViewController *)controller
    didSelectRecord:(NSUInteger)recordId
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self viewDataOfRecordID:recordId])
            [SVProgressHUD dismiss];
        else
            [SVProgressHUD showErrorWithStatus:@"文件打开错误！"];
    });
    
    [controller dismissModalViewControllerAnimated:YES];
}

- (void)reloadPlot
{
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CPTPlotRange *range = ((CPTXYPlotSpace*)graph.defaultPlotSpace).xRange;
        self.dataArray = [[DLDataProvider sharedProvider] dataOfRecord:self.recordID inRangeStartDate:[NSDate dateWithTimeIntervalSince1970:range.locationDouble]
                                                               endDate:[NSDate dateWithTimeIntervalSince1970:range.locationDouble + range.lengthDouble]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [graph reloadData];
            [SVProgressHUD dismiss];
        });
    });
}

#pragma mark - RTPulseWave Datasource

- (double)pulseWaveView:(RTPulseWaveView *)waveview
            valueOfTime:(NSTimeInterval)time
{
    return [DLDataRecorder sharedRecorder].currentZ;
}

#pragma mark - Space Delegate

-(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space
     willChangePlotRangeTo:(CPTPlotRange *)newRange
             forCoordinate:(CPTCoordinate)coordinate
{
    CPTPlotRange *updatedRange = nil;
    
    switch ( coordinate ) {
        case CPTCoordinateX:
        {
            if (newRange.lengthDouble < 3.) {
                CPTMutablePlotRange *rang = [[newRange mutableCopy] autorelease];
                rang.length = CPTDecimalFromDouble(3.);
                updatedRange = rang;
            }
            else
                updatedRange = newRange;
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                     selector:@selector(reloadPlot)
                                                       object:nil];
            [self performSelector:@selector(reloadPlot)
                       withObject:nil
                       afterDelay:1.0];
        }
            break;
        case CPTCoordinateY:
            updatedRange = ((CPTXYPlotSpace *)space).yRange;
            break;
        default:
            break;
    }
    return updatedRange;
}

#pragma mark - Plot Datasource

#define DATA_SAMPLES        100

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return self.dataArray.count;// DATA_SAMPLES;// [self.xValue count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot
                     field:(NSUInteger)fieldEnum
               recordIndex:(NSUInteger)index
{
    //NSLog(@"Start Date:%@", [NSDate dateWithTimeIntervalSince1970:((CPTXYPlotSpace*)plot.plotSpace).xRange.locationDouble]);
    if (fieldEnum == CPTScatterPlotFieldX)
        return [NSNumber numberWithDouble:((DLData*)self.dataArray[index]).date.timeIntervalSince1970];
    else
        return ((DLData*)self.dataArray[index]).value;
    /*
     CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)plot.plotSpace;
     double time = plotSpace.xRange.locationDouble + plotSpace.xRange.lengthDouble * index / DATA_SAMPLES;
     if (fieldEnum == CPTScatterPlotFieldX)
     return [NSNumber numberWithDouble:time];
     else {
     if (self.recordID == 0)
     return [NSNumber numberWithDouble:0.0];
     return [NSNumber numberWithFloat:[[DLDataProvider sharedProvider] valueForTime:[NSDate dateWithTimeIntervalSince1970:time]
     ofRecord:self.recordID]];
     }
     */
}

#pragma mark - Axis Delegate

-(BOOL)axis:(CPTAxis *)axis
shouldUpdateMinorAxisLabelsAtLocations:(NSSet *)locations
{
    static CPTTextStyle *positiveStyle = nil;
    static CPTTextStyle *negativeStyle = nil;
    
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"0.SSS"];
    }
    
    CGFloat labelOffset    = axis.labelOffset;
    NSDecimalNumber *zero  = [NSDecimalNumber zero];
    
    NSMutableSet *newLabels = [NSMutableSet set];
    
    for ( NSDecimalNumber *tickLocation in locations ) {
        CPTTextStyle *theLabelTextStyle = nil;
        
        if ( [tickLocation isGreaterThanOrEqualTo:zero] ) {
            if ( !positiveStyle ) {
                CPTMutableTextStyle *newStyle = [axis.labelTextStyle mutableCopy];
                newStyle.color = [CPTColor greenColor];
                newStyle.fontSize = 10.0;
                positiveStyle  = newStyle;
            }
            theLabelTextStyle = positiveStyle;
        }
        else {
            if ( !negativeStyle ) {
                CPTMutableTextStyle *newStyle = [axis.labelTextStyle mutableCopy];
                newStyle.color = [CPTColor redColor];
                newStyle.fontSize = 10.0;
                negativeStyle  = newStyle;
            }
            theLabelTextStyle = negativeStyle;
        }
        
        NSString *labelString       = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[tickLocation doubleValue]]];
        CPTTextLayer *newLabelLayer = [[CPTTextLayer alloc] initWithText:labelString
                                                                   style:theLabelTextStyle];
        
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithContentLayer:newLabelLayer];
        newLabel.tickLocation = tickLocation.decimalValue;
        newLabel.offset       = labelOffset;
        
        [newLabels addObject:newLabel];
        [newLabel release];
        [newLabelLayer release];
    }
    
    
    axis.minorTickAxisLabels = newLabels;
    
    return NO;
}

-(BOOL)axis:(CPTAxis *)axis
shouldUpdateAxisLabelsAtLocations:(NSSet *)locations
{
    static CPTTextStyle *positiveStyle = nil;
    static CPTTextStyle *negativeStyle = nil;
    
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"hh:mm:ss"];
    }
    
    CGFloat labelOffset    = axis.labelOffset;
    NSDecimalNumber *zero  = [NSDecimalNumber zero];
    
    NSMutableSet *newLabels = [NSMutableSet set];
    
    for ( NSDecimalNumber *tickLocation in locations ) {
        CPTTextStyle *theLabelTextStyle;
        
        if ( [tickLocation isGreaterThanOrEqualTo:zero] ) {
            if ( !positiveStyle ) {
                CPTMutableTextStyle *newStyle = [axis.labelTextStyle mutableCopy];
                newStyle.color = [CPTColor greenColor];
                positiveStyle  = newStyle;
            }
            theLabelTextStyle = positiveStyle;
        }
        else {
            if ( !negativeStyle ) {
                CPTMutableTextStyle *newStyle = [axis.labelTextStyle mutableCopy];
                newStyle.color = [CPTColor redColor];
                negativeStyle  = newStyle;
            }
            theLabelTextStyle = negativeStyle;
        }
        
        NSString *labelString       = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:tickLocation.doubleValue]];
        CPTTextLayer *newLabelLayer = [[CPTTextLayer alloc] initWithText:labelString
                                                                   style:theLabelTextStyle];
        
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithContentLayer:newLabelLayer];
        newLabel.tickLocation = tickLocation.decimalValue;
        newLabel.offset       = labelOffset;
        newLabel.rotation     = M_PI / 3;
        
        [newLabels addObject:newLabel];
        [newLabel release];
        [newLabelLayer release];
    }
    
    axis.axisLabels = newLabels;
    
    return YES;
}

#if !TARGET_IPHONE_SIMULATOR && USE_BLUETOOTH
#pragma mark - BTDiscoveryDelegate

- (void)discoveryView:(BTDiscoveryViewController *)discoveryView
      didSelectDevice:(BTDevice *)device
{
    self.selectedDevice = device;
    [discoveryView dismissModalViewControllerAnimated:YES];
    [[BTStackManager sharedInstance] stopDiscovery];
}

-(void) statusCellSelectedDiscoveryView:(BTDiscoveryViewController*)discoveryView
{
    if (![[BTStackManager sharedInstance] isDiscoveryActive]) {
        self.selectedDevice = nil;
        [[BTStackManager sharedInstance] startDiscovery];
    }
    else
        [[BTStackManager sharedInstance] stopDiscovery];
}

#pragma mark - BTstackManagerDelegate

// Activation callbacks
-(BOOL) disableSystemBluetoothBTstackManager:(BTStackManager*) manager
{
    return YES;
}

// Connection events
-(NSString*) btstackManager:(BTStackManager*) manager
              pinForAddress:(bd_addr_t)addr
{
    return @"0000";
}

// direct access
-(void) btstackManager:(BTStackManager*) manager
  handlePacketWithType:(uint8_t) packet_type
			forChannel:(uint16_t) channel
			   andData:(uint8_t *)packet
			   withLen:(uint16_t) size
{
    static uint8_t rfcomm_channel = 1;
    bd_addr_t event_addr;
	uint16_t wiiMoteConHandle = 0;
    uint16_t hidControl = 0;
    uint16_t hidInterrupt = 0;
    uint16_t rfcomm_channel_nr;
    uint16_t rfcomm_channel_id;
    uint16_t mtu = 0;
    
    static const char HEX[] = {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};
    NSMutableString *hexStr = [NSMutableString stringWithCapacity:size * 2];
    for (int i=0; i < size; i++) {
        const char ch = packet[i];
        [hexStr appendFormat:@"%c",HEX[(ch & 0xF0) >> 4]];
        [hexStr appendFormat:@"%c",HEX[(ch & 0x0F)     ]];
    }
    NSLog(@"Packet Type:%02x, Data: %@",packet_type, hexStr);
    
	switch (packet_type) {
			
		case L2CAP_DATA_PACKET:
            NSLog(@"%s",packet);
			break;
        case RFCOMM_DATA_PACKET:
            
            break;
        case DAEMON_EVENT_PACKET:
            
            break;
		case HCI_EVENT_PACKET:
			switch (packet[0]){
                case BTSTACK_EVENT_STATE:   // Bluetooth Ready !
                    
                    break;
				case HCI_EVENT_COMMAND_COMPLETE:
					if ( COMMAND_COMPLETE_EVENT(packet, hci_write_authentication_enable) ) {
                        // connect to device
                        //bt_send_cmd(&l2cap_create_channel, [self.selectedDevice address], PSM_RFCOMM);
                        bt_send_cmd(&rfcomm_create_channel, [self.selectedDevice address], rfcomm_channel);
                        
					}
                    else if ( COMMAND_COMPLETE_EVENT(packet, hci_pin_code_request_reply) ) {
                        
                    }
                    
					break;
                    
				case HCI_EVENT_PIN_CODE_REQUEST:
					bt_flip_addr(event_addr, &packet[2]);
					if (BD_ADDR_CMP([self.selectedDevice address], event_addr)) // Not seleceted Device
                        break;
                    
					// inform about pin code request
					NSLog(@"HCI_EVENT_PIN_CODE_REQUEST\n");
					//bt_send_cmd(&hci_pin_code_request_reply, event_addr, 6,  &packet[2]); // use inverse bd_addr as PIN
                    bt_send_cmd(&hci_pin_code_request_reply, event_addr, 4, "1234");
					break;
                case RFCOMM_EVENT_CHANNEL_CLOSED:
                    NSLog(@"RFCOMM_EVENT_CHANNEL_CLOSED");
                    break;
				case RFCOMM_EVENT_INCOMING_CONNECTION:
					// data: event (8), len(8), address(48), channel (8), rfcomm_cid (16)
					bt_flip_addr(event_addr, &packet[2]);
					rfcomm_channel_nr = packet[8];
					rfcomm_channel_id = READ_BT_16(packet, 9);
					//printf("RFCOMM channel %u requested for %s\n", rfcomm_channel_nr, bd_addr_to_str(event_addr));
					//bt_send_cmd(&rfcomm_accept_connection, rfcomm_channel_id);
					break;
					
				case RFCOMM_EVENT_OPEN_CHANNEL_COMPLETE:
					// data: event(8), len(8), status (8), address (48), handle(16), server channel(8), rfcomm_cid(16), max frame size(16)
					if (packet[2]) {
						printf("RFCOMM channel open failed, status %u\n", packet[2]);
					} else {
						rfcomm_channel_id = READ_BT_16(packet, 12);
						mtu = READ_BT_16(packet, 14);
						printf("RFCOMM channel open succeeded. New RFCOMM Channel ID %u, max frame size %u\n", rfcomm_channel_id, mtu);
                        uint8_t str[] = "1";
                        bt_send_rfcomm(rfcomm_channel_id, str, 1);
					}
					break;
					
				case HCI_EVENT_DISCONNECTION_COMPLETE:
					// connection closed -> quit test app
					printf("Basebank connection closed\n");
					break;
				case L2CAP_EVENT_CHANNEL_OPENED:
                    // data: event (8), len(8), status (8), address(48), handle (16), psm (16), local_cid(16), remote_cid (16), local_mtu(16), remote_mtu(16)
					if (packet[2] == 0) {
						// inform about new l2cap connection
						bt_flip_addr(event_addr, &packet[3]);
						wiiMoteConHandle = READ_BT_16(packet, 9);
						uint16_t psm = READ_BT_16(packet, 11);
						uint16_t source_cid = READ_BT_16(packet, 13);
                        uint16_t dest_cid   = READ_BT_16(packet, 15);
						NSLog(@"Channel successfully opened: handle 0x%02x, psm 0x%02x, source cid 0x%02x, dest cid 0x%02x",
							  wiiMoteConHandle, psm, source_cid, dest_cid);
						if (psm == PSM_HID_CONTROL) {
							// control channel openedn succesfully, now open interrupt channel, too.
                            hidControl = source_cid;
							bt_send_cmd(&l2cap_create_channel, event_addr, PSM_SDP);
						} else if (psm == PSM_HID_INTERRUPT) {
							// request acceleration data..
                            hidInterrupt = source_cid;
							uint8_t setMode31[] = { 0xa2, 0x12, 0x00, 0x31 };
							bt_send_l2cap( hidInterrupt, setMode31, sizeof(setMode31));
							uint8_t setLEDs[] = { 0xa2, 0x11, 0x10 };
							bt_send_l2cap( hidInterrupt, setLEDs, sizeof(setLEDs));
							// start demo
							
						}
                        else if (psm == PSM_SDP) {
                            //bt_send_cmd(&sdp_client_query_rfcomm_services);
                        }
                        else if (psm == PSM_RFCOMM) {
                            uint8_t str[] = "1";
                            //bt_send_l2cap(source_cid, str, 1);
                            bt_send_rfcomm(source_cid, str, 1);
                        }
					}
					break;
                case L2CAP_EVENT_TIMEOUT_CHECK:
                    bt_send_cmd(&l2cap_decline_connection);
                    break;
				default:
					break;
			}
			break;
			
		default:
			break;
	}
	
}

#pragma mark - BTstackManagerListener

// Activation events
-(void) activatedBTstackManager:(BTStackManager*) manager
{
    
}

-(void) btstackManager:(BTStackManager*)manager
      activationFailed:(BTstackError)error
{
    
}

-(void) deactivatedBTstackManager:(BTStackManager*) manager
{
    
}

// Power management events
-(void) sleepModeEnterBTstackManager:(BTStackManager*) manager
{
    
}

-(void) sleepModeExtitBTstackManager:(BTStackManager*) manager
{
    
}

// Discovery events: general
-(void) btstackManager:(BTStackManager*)manager
            deviceInfo:(BTDevice*)device
{
    
}

-(void) btstackManager:(BTStackManager*)manager
discoveryQueryRemoteName:(int)deviceIndex
{
    
}

-(void) discoveryStoppedBTstackManager:(BTStackManager*) manager
{
    if (self.selectedDevice) {
        bt_send_cmd(&hci_write_authentication_enable, 0);
    }
}

-(void) discoveryInquiryBTstackManager:(BTStackManager*) manager
{
    
}

// Connection
-(void) l2capChannelCreatedAtAddress:(bd_addr_t)addr
                             withPSM:(uint16_t)psm
                                asID:(uint16_t)channelID
{
    
}

-(void) l2capChannelCreateFailedAtAddress:(bd_addr_t)addr
                                  withPSM:(uint16_t)psm
                                    error:(BTstackError)error
{
    
}

-(void) l2capChannelClosedForChannelID:(uint16_t)channelID
{
    
}

-(void) l2capDataReceivedForChannelID:(uint16_t)channelID
                             withData:(uint8_t *)packet
                                ofLen:(uint16_t)size
{
    
}

-(void) rfcommConnectionCreatedAtAddress:(bd_addr_t)addr
                              forChannel:(uint16_t)channel
                                    asID:(uint16_t)connectionID
{
    
}

-(void) rfcommConnectionCreateFailedAtAddress:(bd_addr_t)addr
                                   forChannel:(uint16_t)channel
                                        error:(BTstackError)error
{
    
}

-(void) rfcommConnectionClosedForConnectionID:(uint16_t)connectionID
{
    
}

-(void) rfcommDataReceivedForConnectionID:(uint16_t)connectionID
                                 withData:(uint8_t *)packet
                                    ofLen:(uint16_t)size
{
    
}

#endif

@end
