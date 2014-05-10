//
//  MLPeopleViewController.h
//  SocialLubrication
//
//  Created by James Scherer on 2/26/14.
//  Copyright (c) 2014 Mazag Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MLPeopleViewControllerDelegate <NSObject>

@required
-(void)userInviteApproval:(BOOL)userSelection;
-(void)cancelInvite;

@end

@interface MLPeopleViewController : UIViewController

@property (weak, nonatomic) id <MLPeopleViewControllerDelegate> delegate;
@property (strong, nonatomic) PFUser *selectedUser;


@end
