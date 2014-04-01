//
//  MLInterestViewController.m
//  SocialLubrication
//
//  Created by James Scherer on 2/26/14.
//  Copyright (c) 2014 Mazag Labs. All rights reserved.
//

#import "MLInterestViewController.h"

@interface MLInterestViewController ()

//@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;


@end

@implementation MLInterestViewController

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
    
    PFUser *user = [PFUser currentUser];
    
    NSLog(@"%@", user.username);
    
    self.usernameLabel.text = user.username;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
    
}

@end
