//
//  JMViewController.m
//  JMStarter
//
//  Created by jianmei on 04/13/2023.
//  Copyright (c) 2023 jianmei. All rights reserved.
//

#import "JMViewController.h"
#import "ModuleService/ModuleAProtocol.h"
#import <JMStarter/JMModuleMediator.h>

@interface JMViewController ()

@end

@implementation JMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    self.title = @"首页";
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[JMModuleMediator implObjForProtocol: @protocol(ModuleAProtocol)] testFun];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
