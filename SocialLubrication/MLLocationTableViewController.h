//
//  MLLocationTableViewController.h
//  SocialLubrication
//
//  Created by James Scherer on 4/14/14.
//  Copyright (c) 2014 Mazag Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLCoreLocation.h"

@interface MLLocationTableViewController : UITableViewController <CoreLocationControllerDelegate>{
    MLCoreLocation *CLController;
}

@property (strong, nonatomic) MLCoreLocation *CLController;

@end
