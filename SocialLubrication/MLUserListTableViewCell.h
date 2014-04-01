//
//  MLUserListTableViewCell.h
//  SocialLubrication
//
//  Created by James Scherer on 3/28/14.
//  Copyright (c) 2014 Mazag Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLUserListTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *interestOneLabel;
@property (strong, nonatomic) IBOutlet UILabel *interestTwoLabel;
@property (strong, nonatomic) IBOutlet UILabel *interestThreeLabel;


@property (strong, nonatomic) IBOutlet UIButton *userFunctionButton;

@end
