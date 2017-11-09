//
//  RedViewController.m
//  RedirectDemo
//
//  Created by wenyou on 2017/11/6.
//  Copyright © 2017年 wenyou. All rights reserved.
//

#import "RedViewController.h"

#import <objc/runtime.h>
#import <Masonry/Masonry.h>

@interface RedViewController ()
@end


@implementation RedViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.redColor;
    self.edgesForExtendedLayout = UIRectEdgeNone;

    unsigned int count;
    __unsafe_unretained Protocol **protocols = class_copyProtocolList(RedViewController.class, &count);
    for (unsigned int i = 0; i < count; i++) {
        const char *name = protocol_getName(protocols[i]);

        if (@protocol(RedirectProtocol) == protocols[i]) {
            printf("%s\n",name);
        }
    }

    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.top.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
    }];
    nameLabel.text = [NSString stringWithFormat:@"name: %@", _name];

    UILabel *ageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:ageLabel];
    [ageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLabel.mas_bottom).offset(10);
        make.left.equalTo(nameLabel);
        make.right.equalTo(nameLabel);
    }];
    ageLabel.text = [NSString stringWithFormat:@"age: %tu", _age];

    UILabel *colorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:colorLabel];
    [colorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(ageLabel.mas_bottom).offset(10);
        make.left.equalTo(nameLabel);
        make.right.equalTo(nameLabel);
    }];
    colorLabel.text = [NSString stringWithFormat:@"color : %@", super.color];

    UILabel *sexLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:sexLabel];
    [sexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(colorLabel.mas_bottom).offset(10);
        make.left.equalTo(nameLabel);
        make.right.equalTo(nameLabel);
    }];
    sexLabel.text = [NSString stringWithFormat:@"sex : %@", _sex ? @"YES" : @"NO"];
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

- (void)setName:(NSString *)name {
    _name = name;
    NSLog(@"name: %@ property set function did run", _name);
}

+ (NSString *)redirectName {
    return @"blood";
}
@end
