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
@property (strong, nonatomic) IBOutlet UILabel *profileInterest1;
@property (strong, nonatomic) IBOutlet UILabel *profileInterest2;
@property (strong, nonatomic) IBOutlet UILabel *profileInterest3;
@property (strong, nonatomic) IBOutlet UILabel *profileInterest4;


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
    
    //PFUser *userProfile = self.userProfile[@"user"];
    
    self.profileUserNameLabel.text = self.userProfile.username;
    self.profileTagLineLabel.text = self.userProfile[@"tagLine"];
    self.profileInterest1.text = self.userProfile[@"interest1"];
    self.profileInterest2.text = self.userProfile[@"interest2"];
    self.profileInterest3.text = self.userProfile[@"interest3"];
    self.profileInterest4.text = self.userProfile[@"interest4"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end