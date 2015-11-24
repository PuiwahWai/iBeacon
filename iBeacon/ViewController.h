//
//  ViewController.h
//  iBeacon
//
//  Created by qinlin on 15/10/16.
//  Copyright © 2015年 qinlin.com.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import<CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate>

@property (nonatomic, strong) NSArray *beaconArr;//存放扫描到的iBeacon

@property (strong, nonatomic) CLBeaconRegion *beacon1;//被扫描的iBeacon

@property (strong, nonatomic) CLLocationManager * locationmanager;

@end

