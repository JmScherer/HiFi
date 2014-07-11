//
//  MLUserListTableViewCell.m
//  SocialLubrication
//
//  Created by James Scherer on 3/28/14.
//  Copyright (c) 2014 Mazag Labs. All rights reserved.
//

#import "MLUserListTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation MLUserListTableViewCell

@synthesize usernameLabel = _usernameLabel;
@synthesize interestOneLabel = _interestOneLabel;
@synthesize userFunctionButton = _userFunctionButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
    
    
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
//    _userFunctionButton.layer.borderColor = [UIColor blueColor].CGColor;
//    _userFunctionButton.layer.borderWidth = 1.0;
//    _userFunctionButton.layer.cornerRadius = 5;
}



@end
