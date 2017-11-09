//
//  WhiteViewController.m
//  RedirectDemo
//
//  Created by wenyou on 2017/11/6.
//  Copyright © 2017年 wenyou. All rights reserved.
//

#import "WhiteViewController.h"
#import "RedirectProtocol.h"
#import "RedirectCenter.h"
#import <Masonry/Masonry.h>

@interface WhiteViewController () <RedirectProtocol>
@end

@implementation WhiteViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"white";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = UIColor.whiteColor;

    UIButton *redButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [redButton setTitle:@"red" forState:UIControlStateNormal];
    [redButton addTarget:self action:@selector(redButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [redButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    redButton.layer.borderWidth = 1;
    redButton.layer.cornerRadius = 5;
    redButton.clipsToBounds = YES;
    [self.view addSubview:redButton];
    [redButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.top.equalTo(self.view).offset(10);
        make.width.mas_equalTo(100);
    }];

    UIButton *blueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [blueButton setTitle:@"blue" forState:UIControlStateNormal];
    [blueButton addTarget:self action:@selector(blueButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [blueButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    blueButton.layer.borderWidth = 1;
    blueButton.layer.cornerRadius = 5;
    blueButton.clipsToBounds = YES;
    [self.view addSubview:blueButton];
    [blueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.top.equalTo(redButton.mas_bottom).offset(10);
        make.width.mas_equalTo(100);
    }];

    UIButton *purpleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [purpleButton setTitle:@"purple" forState:UIControlStateNormal];
    [purpleButton addTarget:self action:@selector(purpleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [purpleButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    purpleButton.layer.borderWidth = 1;
    purpleButton.layer.cornerRadius = 5;
    purpleButton.clipsToBounds = YES;
    [self.view addSubview:purpleButton];
    [purpleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.top.equalTo(blueButton.mas_bottom).offset(10);
        make.width.mas_equalTo(100);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)redButtonClicked:(id)sender {
    [[RedirectCenter shareInstance] pushFrom:self.navigationController withName:@"blood" propertyDict:nil animated:YES];
}

- (void)blueButtonClicked:(id)sender {
    [[RedirectCenter shareInstance] pushFrom:self.navigationController withName:@"blue" propertyDict:nil animated:YES];
}

- (void)purpleButtonClicked:(id)sender {
    UIViewController *viewController = [[RedirectCenter shareInstance] viewControllerWithName:@"purple" propertyDict:@{@"name": @"purple",
                                                                                                                       @"color": @"purple",
                                                                                                                       @"sex": @YES,
                                                                                                                       @"age": @"5"}];
    [self presentViewController:viewController animated:YES completion:^{
    }];
}

#pragma mark - RedirectProtocol
+ (NSString *)redirectName {
    return @"white";
}
@end
