//
//  MLSettingsViewController.h
//  SocialLubrication
//
//  Created by James Scherer on 5/12/14.
//  Copyright (c) 2014 Mazag Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MLSettingsViewControllerDelegate <NSObject>

@required
-(void)logout;

@end

@interface MLSettingsViewController  : UIViewController

@property (weak, nonatomic) id <MLSettingsViewControllerDelegate> delegate;

@end
