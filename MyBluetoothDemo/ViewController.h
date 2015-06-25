//
//  ViewController.h
//  MyBluetoothDemo
//
//  Created by LaughingZhong on 15/6/9.
//  Copyright (c) 2015年 Laughing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define SericeUUID @"6006"

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,CBCentralManagerDelegate,CBPeripheralDelegate>

@property(nonatomic,strong) IBOutlet UITableView *tableView;

@end

