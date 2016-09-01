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
//                                    NSLog(@"data = %@",self.dataArray);
                                    [self.tableView reloadData];
                                }
                                failure:^(NSURLSessionDataTask * _Nullable task, NSError *error){
                                    NSLog(@"ERROR = %@",error);
                                }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSString *cellIdentifier = [info objectForKey:@"cellStyle"];
//    NSLog(@"cellIdentifier = %@",cellIdentifier);
    AutoBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell) {
//        NSLog(@"初始化 cellIdentifier = %@",cellIdentifier);
        cell = [[AutoBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault withCellInfo:info];
    }else{
        [cell cellInfo:info];
    }
    cell.tapBlock = ^(UIView *view, id info){
        NSLog(@"view = %@",NSStringFromClass([view class]));
        NSLog(@"info = %@",info);
        if ([view isMemberOfClass:[UIButton class]]) {
            if (info[@"selectImage"] && [info[@"selectImage"] length]>0) {
                UIButton *button = (UIButton *)view;
                button.selected = !button.selected;
            }
        }
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"点击了%@",NSStringFromClass([view class])] message:[self DataTOjsonString:info] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    };
    return cell;
}

-(NSString*)DataTOjsonString:(id)object {
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *info = self.dataArray[indexPath.row];
    return [AutoBaseTableViewCell cellHeightWithInfo:info];
}
@end
