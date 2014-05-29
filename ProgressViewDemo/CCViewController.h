//
//  CCViewController.h
//
//
//  Created by mr.cao on 14-5-27.
//  Copyright (c) 2014年 mrcao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CCProgressView;
@interface CCViewController : UIViewController
{
    CGAffineTransform currentTransform;
    CGAffineTransform newTransform;
    double r;
}
@property (nonatomic , strong)  NSTimer *theTimer;
@property(nonatomic,strong)CCProgressView * circleChart;

@end
