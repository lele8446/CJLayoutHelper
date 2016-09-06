//
//  ListTableViewController.m
//  listDemo
//
//  Created by YiChe on 16/8/28.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import "ListTableViewController.h"
#import "AutoBaseTableViewCell.h"
#import "AFNetworking.h"
#import "ConfigurationTool.h"

@interface ListTableViewController ()
@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation ListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"配置UI";
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    
    [[AFHTTPSessionManager manager]POST:@"http://7xnrwl.com1.z0.glb.clouddn.com/mydata.json"
                             parameters:nil
                               progress:^(NSProgress * uploadProgress){
                                   
                               }
                                success:^(NSURLSessionDataTask *task, id _Nullable responseObject){
                                    self.dataArray = [(NSDictionary*)responseObject objectForKey:@"data"];
                                    [self.tableView reloadData];
                                }
                                failure:^(NSURLSessionDataTask * _Nullable task, NSError *error){
                                    NSLog(@"ERROR = %@",error);
                                }];
    
    UIBarButtonItem *finishItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(finishClick)];
    self.navigationItem.rightBarButtonItem = finishItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)finishClick {
    UITextField *xydmField = [self.view viewWithIdDescription:@"TextField_xydm"];
    UITextField *zczbField = [self.view viewWithIdDescription:@"TextField_zczb"];
    UITextView *addressTextView = [self.view viewWithIdDescription:@"CJUITextView_dz"];
    NSString *description = [NSString stringWithFormat:@"信用代码:%@\n注册资本:%@\n地址:%@",xydmField.text,zczbField.text,addressTextView.text];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"点击完成" message:description preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Table view data source

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *info = self.dataArray[indexPath.row];
    AutoBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[ConfigurationLayoutHelper configurationViewStyleIdentifier:info]];
    if (nil == cell) {
        cell = [[AutoBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault withCellInfo:info];
    }else{
        [cell cellInfo:info];
    }
    __weak typeof(self)wSelf = self;
    cell.tapBlock = ^(UIView *view, id info){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"点击了%@",NSStringFromClass([view class])] message:info preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:cancelAction];
        [wSelf presentViewController:alertController animated:YES completion:nil];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *info = self.dataArray[indexPath.row];
    return [AutoBaseTableViewCell cellHeightWithInfo:info];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
