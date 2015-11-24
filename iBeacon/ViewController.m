//
//  ViewController.m
//  iBeacon
//
//  Created by qinlin on 15/10/16.
//  Copyright © 2015年 qinlin.com.www. All rights reserved.
//

#import "ViewController.h"
//C4ABB7C7-B7B2-A3BA-D6A5-C2E9BFAAC3C5
//#define BEACONUUID @"C4ABB7C7-B7B2-A3BA-D6A5-C2E9BFAAC3C5"//常态 UUID
//#define BEACONUUID @"C4ABB7C7-B7B2-A3AD-D6A5-C2E9BFAAC3C5"//按钮按下的 UUID
#define BEACONUUID @"8492E75F-4FD6-469D-B132-043FE94921D8"//手机发射器
@interface ViewController ()

@property (nonatomic,strong)UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"iBeacon";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    
    self.tableView.delegate = self;
    
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
    
    self.beaconArr = [[NSArray alloc] init];
    
    self.beacon1 = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:BEACONUUID] identifier:@"beacon"];//初始化监测的iBeacon信息
    
    self.beacon1.notifyEntryStateOnDisplay = YES;

    [self.locationmanager requestAlwaysAuthorization];//设置location是一直允许
    
    self.locationmanager = [[CLLocationManager alloc] init];
    self.locationmanager.delegate = self;
    
    if(![CLLocationManager isRangingAvailable]){
        NSLog(@"Couldn't turn on ranging: Ranging is not available.");
        return;
    }
    if (self.locationmanager.rangedRegions.count > 0) {
        NSLog(@"Didn't turn on ranging: Ranging already on.");
        return;
    }
    
    if ([self.locationmanager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationmanager requestWhenInUseAuthorization];
    }
    
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:BEACONUUID];
    self.beacon1 = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:@"SomeIdentifier"];
    self.beacon1.notifyEntryStateOnDisplay = YES;
    
    [self.locationmanager startMonitoringForRegion:self.beacon1];
    
}

#pragma mark - Location manager delegate methods
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [CLLocationManager authorizationStatus];
    [self.locationmanager startRangingBeaconsInRegion:self.beacon1];
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    //[self.locationmanager startRangingBeaconsInRegion:self.beacon1];//开始RegionBeacons
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"Failed monitoring region: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location manager failed: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    //如果存在不是我们要监测的iBeacon那就停止扫描他
    if (![[region.proximityUUID UUIDString] isEqualToString:BEACONUUID]){
        [self.locationmanager stopMonitoringForRegion:region];
        [self.locationmanager stopRangingBeaconsInRegion:region];
    }
    //打印所有iBeacon的信息
    for (CLBeacon* beacon in beacons) {
        NSLog(@"rssi is :%ld",beacon.rssi);
        NSLog(@"beacon.proximity %ld",beacon.proximity);
        NSString * info_4 = [NSString stringWithFormat:@"accuracy:%0.4f米",beacon.accuracy];
        NSLog(@"%@",info_4);
    }
    self.beaconArr = beacons;
    [self.tableView reloadData];
}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region
{
    [[[UIAlertView alloc]initWithTitle:@"提示" message:@"信号已消失在天际。。。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil, nil] show];
    NSLog(@"didExitRegion");

    [self sendExitLocalNotification];
}

- (void)sendExitLocalNotification
{
    UILocalNotification *notice = [[UILocalNotification alloc] init];
    notice.alertBody = @"sorry，你离开了 iSS iBeacon region";
    notice.alertAction = @"Open";
    notice.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:notice];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.beaconArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ident = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ident];
    }
    CLBeacon *beacon = [self.beaconArr objectAtIndex:indexPath.row];
    cell.textLabel.text = [beacon.proximityUUID UUIDString];
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    NSString *str;
    switch (beacon.proximity) {
        case CLProximityNear:
            str = @"近";
            break;
        case CLProximityImmediate:
            str = @"超近";
            break;
        case CLProximityFar:
            str = @"远";
            break;
        case CLProximityUnknown:
            str = @"不见了";
            break;
        default:
            break;
    }
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ rssi=%ld majon=%@ minor=%@     %.3f米",str,beacon.rssi,beacon.major,beacon.minor,beacon.accuracy];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
