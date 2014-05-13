//
//  MLRegistrationImageViewController.h
//  SocialLubrication
//
//  Created by James Scherer on 2/4/14.
//  Copyright (c) 2014 Mazag Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLUser.h"

@protocol MLRegistrationImageViewControllerDelegate <NSObject>

-(void)finalizeAccount;

@end

@interface MLRegistrationImageViewController : UIViewController

@property (weak, nonatomic) id <MLRegistrationImageViewControllerDelegate> delegate;
@property (strong, nonatomic) MLUser *userCredentials;

@end
