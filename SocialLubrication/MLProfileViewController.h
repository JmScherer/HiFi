//
//  MLProfileViewController.h
//  SocialLubrication
//
//  Created by James Scherer on 3/3/14.
//  Copyright (c) 2014 Mazag Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLUserListTableViewCell.h"

@interface MLProfileViewController : UIViewController

@property (strong, nonatomic) PFUser *userProfile;

@end
