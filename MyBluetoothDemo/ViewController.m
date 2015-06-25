//
//  ViewController.m
//  MyBluetoothDemo
//
//  Created by LaughingZhong on 15/6/9.
//  Copyright (c) 2015年 Laughing. All rights reserved.
//

#import "ViewController.h"
#import "TableViewCell.h"
#import "PeripheralViewController.h"

#define ScanTimeInterval 1.0

@interface ViewController ()

@property (nonatomic,strong) NSMutableArray *devicesArray;
@property (nonatomic,strong) CBCentralManager *centralManager;
@property (nonatomic,strong) CBPeripheral *selectedPeripheral;
@property (nonatomic,strong) NSTimer *scanTimer;

@end

@implementation ViewController

- (void)dealloc
{
    _devicesArray = nil;
    _centralManager = nil;
    _selectedPeripheral = nil;
    _scanTimer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _devicesArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    [self initWithLeftBarButton];
    [self initWithRightBarButton];
    [self initWithTableView];
    [self initWithCBCentralManager];
}

#pragma mark - UI
- (void)initWithLeftBarButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake(0.0, 0.0, 60.0, 40.0)];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitle:@"搜索" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(startScanPeripherals) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:item];
}

- (void)initWithRightBarButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake(0.0, 0.0, 60.0, 40.0)];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitle:@"停止" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(stopScan) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setRightBarButtonItem:item];
}

- (void)initWithTableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setBackgroundColor:[UIColor clearColor]];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [_tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    if (_tableView && _tableView.superview != self.view) {
        [self.view addSubview:_tableView];
        
        NSArray *h = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)];
        NSArray *v = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_tableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)];
        [self.view addConstraints:h];
        [self.view addConstraints:v];
    }
}

#pragma mark - ScanTimer
- (void)startScanPeripherals
{
    if (!_scanTimer) {
        _scanTimer = [NSTimer timerWithTimeInterval:ScanTimeInterval target:self selector:@selector(scanForPeripherals) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_scanTimer forMode:NSDefaultRunLoopMode];
    }
    if (_scanTimer && !_scanTimer.valid) {
        [_scanTimer fire];
    }
}

- (void)stopScan
{
    if (_scanTimer && _scanTimer.valid) {
        [_scanTimer invalidate];
        _scanTimer = nil;
    }
    [_centralManager stopScan];
}

#pragma mark - CBCentralManager
- (void)initWithCBCentralManager
{
    if (!_centralManager) {
        dispatch_queue_t queue = dispatch_get_main_queue();
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:queue options:@{CBCentralManagerOptionShowPowerAlertKey:@YES}];
        [_centralManager setDelegate:self];
    }
}

- (void)scanForPeripherals
{
    if (_centralManager.state == CBCentralManagerStateUnsupported) {//设备不支持蓝牙
        
    }else {//设备支持蓝牙连接
        if (_centralManager.state == CBCentralManagerStatePoweredOn) {//蓝牙开启状态
            //[_centralManager stopScan];
            [_centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:[NSNumber numberWithBool:NO]}];
        }
    }
}

- (void)connectPeripheral
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Datasource && Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _devicesArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Peripherals Nearby";
    }else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    NearbyPeripheralInfo *info = [_devicesArray objectAtIndex:indexPath.row];
    [cell setPeripheral:info];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_centralManager.state == CBCentralManagerStateUnsupported) {//设备不支持蓝牙
        
    }else {//设备支持蓝牙连接
        if (_centralManager.state == CBCentralManagerStatePoweredOn) {//蓝牙开启状态
            //连接设备
            NearbyPeripheralInfo *info = [_devicesArray objectAtIndex:indexPath.row];
            [_centralManager connectPeripheral:info.peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,CBConnectPeripheralOptionNotifyOnNotificationKey:@YES,CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES}];
        }
    }
}

#pragma mark - CBCentralManager Delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            NSLog(@"CBCentralManagerStatePoweredOff");
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@"CBCentralManagerStatePoweredOn");
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"CBCentralManagerStateResetting");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"CBCentralManagerStateUnauthorized");
            break;
        case CBCentralManagerStateUnknown:
            NSLog(@"CBCentralManagerStateUnknown");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"CBCentralManagerStateUnsupported");
            break;
            
        default:
            break;
    }
}
//发现蓝牙设备
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
//    NSLog(@"\nperipheral is :\n%@\nadvertisementData is :\n%@\nRSSI is :%d",peripheral,advertisementData,[RSSI intValue]);
    
    
    BOOL isExist = NO;
    NearbyPeripheralInfo *info = [[NearbyPeripheralInfo alloc] init];
    info.peripheral = peripheral;
    info.advertisementData = advertisementData;
    info.RSSI = RSSI;
    
    if (_devicesArray.count == 0) {
        [_devicesArray addObject:info];
        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
        [_tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
    }else {
        for (int i = 0;i < _devicesArray.count;i++) {
            NearbyPeripheralInfo *originInfo = [_devicesArray objectAtIndex:i];
            CBPeripheral *per = originInfo.peripheral;
            if ([peripheral.identifier.UUIDString isEqualToString:per.identifier.UUIDString]) {
                isExist = YES;
                [_devicesArray replaceObjectAtIndex:i withObject:info];
                [_tableView reloadData];
            }
        }
        if (!isExist) {
            [_devicesArray addObject:info];
            NSIndexPath *path = [NSIndexPath indexPathForRow:(_devicesArray.count - 1) inSection:0];
            [_tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}
//连接蓝牙设备成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"%s",__FUNCTION__);
    [self stopScan];
    _selectedPeripheral = peripheral;
    PeripheralViewController *viewController = [[PeripheralViewController alloc] initWithNibName:nil bundle:nil];
    viewController.currentPeripheral = _selectedPeripheral;
    [self.navigationController pushViewController:viewController animated:YES];
}
//连接蓝牙设备失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"%s",__FUNCTION__);
}
//断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"%s",__FUNCTION__);
}

@end
