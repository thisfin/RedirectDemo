//
//  RedirectCenter.h
//  RedirectDemo
//
//  Created by wenyou on 2017/11/6.
//  Copyright © 2017年 wenyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RedirectCenter : NSObject
+ (instancetype)shareInstance;
- (void)pushFrom:(UINavigationController *)navigationController withName:(NSString *)name propertyDict:(NSDictionary<NSString *, NSObject *> *)properties animated:(BOOL)animated;
- (BOOL)openURL:(NSURL *)url;
- (UIViewController *)viewControllerWithName:(NSString *)name propertyDict:(NSDictionary<NSString *, NSObject *> *)properties;
@end
