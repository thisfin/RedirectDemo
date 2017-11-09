//
//  RedViewController.h
//  RedirectDemo
//
//  Created by wenyou on 2017/11/6.
//  Copyright © 2017年 wenyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RedirectProtocol.h"

#import "ColorViewController.h"

@interface RedViewController : ColorViewController <RedirectProtocol>
@property(nonatomic, strong) NSString *name;
@property(nonatomic, assign) NSUInteger age;
@property(nonatomic, assign) BOOL sex;
@end
