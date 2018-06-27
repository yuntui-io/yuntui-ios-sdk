//
//  ViewController.m
//  yuntui-ios-sdk
//
//  Created by leo on 2018/6/26.
//  Copyright © 2018年 ltebean. All rights reserved.
//

#import "ViewController.h"
#import "Yuntui.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)buttonPressed:(id)sender {
    [[Yuntui shared] logEvent:@"button_click" properties:@{@"category": @(1)}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
