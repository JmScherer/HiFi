//
//  MLProfileViewController.m
//  SocialLubrication
//
//  Created by James Scherer on 3/3/14.
//  Copyright (c) 2014 Mazag Labs. All rights reserved.
//

#import "MLProfileViewController.h"

@interface MLProfileViewController ()

@property (strong, nonatomic) IBOutlet UILabel *profileUserNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *profileTagLineLabel;

@end

@implementation MLProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    PFUser *userProfile = self.userProfile[@"user"];
    
    self.profileUserNameLabel.text = userProfile.username;
    self.profileTagLineLabel.text = userProfile[@"tagLine"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
