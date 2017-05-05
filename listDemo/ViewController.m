//
//  ViewController.m
//  listDemo
//
//  Created by YiChe on 16/8/28.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import "ViewController.h"
#import "ListViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NetViewController.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}

- (IBAction)pustToList:(id)sender {
    ListViewController *listViewController = [[ListViewController alloc]initWithNibName:@"ListViewController" bundle:nil];
    [self.navigationController pushViewController:listViewController animated:YES];
}

- (IBAction)pustToNetList:(id)sender {
    NetViewController *listViewController = [[NetViewController alloc]initWithNibName:@"NetViewController" bundle:nil];
    [self.navigationController pushViewController:listViewController animated:YES];
}

@end
