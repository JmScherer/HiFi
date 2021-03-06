//
//  MLRegistrationUserInfoViewController.h
//  SocialLubrication
//
//  Created by James Scherer on 2/3/14.
//  Copyright (c) 2014 Mazag Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLRegistrationImageViewController.h"

@protocol MLRegistrationUserInfoViewControllerDelegate <NSObject>

@end

@interface MLRegistrationUserInfoViewController : UIViewController <MLRegistrationImageViewControllerDelegate>{
    
    IBOutlet UIScrollView *scroller;
}

@property (weak, nonatomic) id <MLRegistrationUserInfoViewControllerDelegate> delegate;
@property (strong, nonatomic) NSString *userText;

@end
