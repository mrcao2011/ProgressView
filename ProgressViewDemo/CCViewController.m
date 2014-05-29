//
//  CCViewController.m
//  
//
//  Created by mr.cao on 14-5-27.
//  Copyright (c) 2014年 mrcao. All rights reserved.
//

#import "CCViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CCProgressView.h"
#import "IOPowerSources.h"
#import "IOPSKeys.h"
#import <CoreMotion/CoreMotion.h>
#import "UICountingLabel.h"
#import "UIDevice+ProcessesAdditions.h"
#define EPSILON     1e-6
#define kDuration 1.0   // 动画持续时间(秒)
@interface CCViewController ()
{
    UICountingLabel *_gradeLabel;
    UICountingLabel *_titleLabel;

}
@property (nonatomic, strong) CMMotionManager* motionManager;
@property (nonatomic, strong) CADisplayLink* motionDisplayLink;
@property (nonatomic) float motionLastYaw;

@end

@implementation CCViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading

    self.view.userInteractionEnabled=YES;
    _circleChart = [[CCProgressView alloc] initWithFrame:CGRectMake(30, 100, ViewWidth-30*2,ViewWidth-30*2)];
    _circleChart.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:_circleChart];

    r=_circleChart.frame.size.height;
    
    
    _gradeLabel = [[UICountingLabel alloc] initWithFrame:CGRectMake(_circleChart.frame.origin.x, _circleChart.frame.origin.y, 50.0, 50.0)];
    _titleLabel=[[UICountingLabel alloc]initWithFrame:CGRectMake(_circleChart.frame.origin.x, _circleChart.frame.origin.x, 50.0, 50.0)];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_titleLabel setFont:[UIFont boldSystemFontOfSize:33.0f]];
    [_titleLabel setTextColor:[UIColor whiteColor]];
    _titleLabel.method = UILabelCountingMethodEaseInOut;
    [self.view addSubview:_titleLabel];
    [_titleLabel setHidden:YES];
     [_titleLabel setCenter:CGPointMake(r,r-30)];
    [_gradeLabel setTextAlignment:NSTextAlignmentCenter];
    [_gradeLabel setFont:[UIFont boldSystemFontOfSize:33.0f]];
    [_gradeLabel setTextColor:[UIColor whiteColor]];

    [_gradeLabel setCenter:CGPointMake(r,r-30)];
    _gradeLabel.method = UILabelCountingMethodEaseInOut;
    
    
    [self.view addSubview:_gradeLabel];
    [_gradeLabel setHidden:YES];
    
    

    
    
    
    
    
    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
     // NSLog(@"%.2f", device.batteryLevel);
     NSLog(@"%.2f---%.2f", device.batteryLevel, [self batteryLevel]);
    
    //[device addObserver:self forKeyPath:@"batteryLevel" options:0x0 context:nil];
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    [[NSNotificationCenter defaultCenter]
     addObserverForName:UIDeviceBatteryLevelDidChangeNotification
     object:nil queue:[NSOperationQueue mainQueue]
     usingBlock:^(NSNotification *notification) {
         // Level has changed
         NSLog(@"Battery Level Change");
           NSLog(@"%.2f---%.2f", device.batteryLevel, [self batteryLevel]);
     }];
    [self startGravity];
    currentTransform=_circleChart.transform;
    /*NSArray * processes = [[UIDevice currentDevice] runningProcesses];
    for (NSDictionary * dict in processes){
        NSLog(@"%@- %@ - %@",[dict allKeys], [dict objectForKey:@"ProcessID"], [dict objectForKey:@"ProcessName"]);
    }*/
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UIDevice *device = [UIDevice currentDevice];
    if ([object isEqual:device] && [keyPath isEqual:@"batteryLevel"]) {
       
        NSLog(@"%.2f---%.2f", device.batteryLevel, [self batteryLevel]);
    }  
}
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (double) batteryLevel
{
    CFTypeRef blob = IOPSCopyPowerSourcesInfo();
    CFArrayRef sources = IOPSCopyPowerSourcesList(blob);
    
    CFDictionaryRef pSource = NULL;
    const void *psValue;
    
    int numOfSources = CFArrayGetCount(sources);
    if (numOfSources == 0) {
        NSLog(@"Error in CFArrayGetCount");
        return -1.0f;
    }
    
    for (int i = 0 ; i < numOfSources ; i++)
    {
        pSource = IOPSGetPowerSourceDescription(blob, CFArrayGetValueAtIndex(sources, i));
        if (!pSource) {
            NSLog(@"Error in IOPSGetPowerSourceDescription");
            return -1.0f;
        }
        psValue = (CFStringRef)CFDictionaryGetValue(pSource, CFSTR(kIOPSNameKey));
        
        //int curCapacity = 0;
       // int maxCapacity = 0;
        
        float curCapacity = 0;
        float maxCapacity = 0;
        double percent;
        
        psValue = CFDictionaryGetValue(pSource, CFSTR(kIOPSCurrentCapacityKey));
        CFNumberGetValue((CFNumberRef)psValue, kCFNumberFloat32Type, &curCapacity);
        
        psValue = CFDictionaryGetValue(pSource, CFSTR(kIOPSMaxCapacityKey));
        CFNumberGetValue((CFNumberRef)psValue, kCFNumberFloat32Type, &maxCapacity);
       // NSLog(@"curCapacity:%f-maxCapacity:%f",curCapacity,maxCapacity);
        percent = ((double)(curCapacity)/(double)maxCapacity * 100.0f);
        [_circleChart setProgress:percent/100 animated:YES];
        [_titleLabel setHidden:NO];
        _titleLabel.frame=CGRectMake(0, 0, r, r);
        _titleLabel.text=[NSString stringWithFormat:@"%.0f%%",percent];
        [_titleLabel setCenter:CGPointMake(r/2+_circleChart.frame.origin.x,r+_circleChart.frame.origin.y-80)];
        [_gradeLabel setHidden:NO];
        _gradeLabel.frame=CGRectMake(0, 0, r, r);
        _gradeLabel.text=@"当前电量";
        [_gradeLabel setCenter:CGPointMake(r/2+_circleChart.frame.origin.x,r-40+_circleChart.frame.origin.y)];

        return percent;
    }
    return -1.0f;
}
- (BOOL)isGravityActive
{
    return self.motionDisplayLink != nil;
}

- (void)startGravity
{
    if ( ! [self isGravityActive]) {
        self.motionManager = [[CMMotionManager alloc] init];
        self.motionManager.deviceMotionUpdateInterval =0.1;// 0.02; // 50 Hz
        
        self.motionLastYaw = 0;
        //self.motionDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(motionRefresh:)];
       // self.motionDisplayLink.frameInterval=1;
       // [self.motionDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        _theTimer= [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(motionRefresh:) userInfo:nil repeats:YES];
    }
    if ([self.motionManager isDeviceMotionAvailable]) {
        // to avoid using more CPU than necessary we use ``CMAttitudeReferenceFrameXArbitraryZVertical``
        [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical];
    }
}
- (void)motionRefresh:(id)sender
{
    
    // compute the device yaw from the attitude quaternion
    // http://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles
    CMQuaternion quat = self.motionManager.deviceMotion.attitude.quaternion;
    double yaw = asin(2*(quat.x*quat.z - quat.w*quat.y));
    
    // TODO improve the yaw interval (stuck to [-PI/2, PI/2] due to arcsin definition
    
    yaw *= -1;      // reverse the angle so that it reflect a *liquid-like* behavior
    //yaw += M_PI_2;  // because for the motion manager 0 is the calibration value (but for us 0 is the horizontal axis)
    
    if (self.motionLastYaw == 0) {
        self.motionLastYaw = yaw;
    }
    
    // kalman filtering
    static float q = 0.1;   // process noise
    static float s = 0.1;   // sensor noise
    static float p = 0.1;   // estimated error
    static float k = 0.5;   // kalman filter gain
    
    float x = self.motionLastYaw;
    p = p + q;
    k = p / (p + s);
    x = x + k*(yaw - x);
    p = (1 - k)*p;
    
    //NSLog(@"xxxx:%f",x);
    // update starting & ending point of the gradient
   // if(abs(x-self.motionLastYaw)<EPSILON)
   // {
    
    //newTransform=CGAffineTransformRotate(currentTransform,-M_PI/4);
     newTransform=CGAffineTransformRotate(currentTransform,-x);
    _circleChart.transform=newTransform;
   // }
    //[self stopGravity];
    self.motionLastYaw = x;
}

- (void)stopGravity
{
    if ([self isGravityActive]) {
        [self.motionDisplayLink invalidate];
        self.motionDisplayLink = nil;
        self.motionLastYaw = 0;
        [_theTimer invalidate];
        _theTimer=nil;
        
        // reset the gradient orientation
        // [self initialGradientOrientation];
        
        self.motionManager = nil;   // release the motion manager memory
    }
    if ([self.motionManager isDeviceMotionActive])
        [self.motionManager stopDeviceMotionUpdates];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceBatteryLevelDidChangeNotification object:nil];
}


@end
