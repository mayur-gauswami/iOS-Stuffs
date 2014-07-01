//
//  UIView+Custom.m
//  webviewTest
//
//  Created by Mayur Gosai on 02/07/14.
//  Copyright (c) 2014 Mayur Gosai. All rights reserved.
//

#import "UIView+Custom.h"

@implementation UIView (Custom)

-(void) myAddGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    [self myAddGestureRecognizer:gestureRecognizer];
    NSLog(@"%@ added %@\n",[self class],gestureRecognizer);
}

@end
