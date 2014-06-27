//
//  MLLoginViewController.h
//  SocialLubrication
//
//  Created by James Scherer on 2/2/14.
//  Copyright (c) 2014 Mazag Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLUser.h"
#import "MLRegistrationUserInfoViewController.h"
#import "MLSettingsViewController.h"

@interface MLLoginViewController : UIViewController < MLRegistrationUserInfoViewControllerDelegate, MLSettingsViewControllerDelegate>{
    
    IBOutlet UIScrollView *scroller;
}

@property (strong, nonatomic) MLUser *userObject;

@property (strong, nonatomic) IBOutlet UIButton *awesomeButton;

@end
