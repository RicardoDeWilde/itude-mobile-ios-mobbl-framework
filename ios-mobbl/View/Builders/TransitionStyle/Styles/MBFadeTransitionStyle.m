//
//  MBFadeTransitionStyle.m
//  itude-mobile-ios-app
//
//  Created by Berry Pleijster on 26-03-13.
//  Copyright (c) 2013 Itude Mobile. All rights reserved.
//

#import "MBFadeTransitionStyle.h"
#import <QuartzCore/QuartzCore.h>

@implementation MBFadeTransitionStyle

-(BOOL)animated {
    return NO;
}

- (void)applyTransitionStyleToViewController:(UIViewController *)viewController forMovement:(MBTransitionMovement)transitionMovement {

    viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    CATransition* transition = [CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionFade;
    transition.subtype = kCATransitionFromTop;
    [viewController.view.layer addAnimation:transition forKey:kCATransition];
}

@end