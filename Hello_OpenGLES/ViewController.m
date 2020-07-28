//
//  ViewController.m
//  Hello_OpenGLES
//
//  Created by 李超 on 2020/7/25.
//  Copyright © 2020 yuanfangzhuye. All rights reserved.
//

#import "ViewController.h"
#import "TLbView.h"

@interface ViewController ()

@property(nonnull,strong)TLbView *myView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myView = (TLbView *)self.view;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
