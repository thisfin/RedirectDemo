//
//  PurpleViewController.m
//  RedirectDemo
//
//  Created by wenyou on 2017/11/6.
//  Copyright © 2017年 wenyou. All rights reserved.
//

#import "PurpleViewController.h"

#import <Masonry/Masonry.h>

@interface PurpleViewController ()

@end

@implementation PurpleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.purpleColor;

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setTitle:@"back" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    backButton.layer.borderWidth = 1;
    backButton.layer.cornerRadius = 5;
    backButton.clipsToBounds = YES;
    [self.view addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.bottom.equalTo(self.view.mas_bottom).offset(-10);
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
- (void)backButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}
@end
