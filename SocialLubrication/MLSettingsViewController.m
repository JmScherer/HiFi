//
//  MLSettingsViewController.m
//  SocialLubrication
//
//  Created by James Scherer on 5/12/14.
//  Copyright (c) 2014 Mazag Labs. All rights reserved.
//

#import "MLSettingsViewController.h"
#import "MLUser.h"

@interface MLSettingsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *userPhotoImageView;

@end

@implementation MLSettingsViewController

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
    
    /* NavBar Bottom Border */
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, 45.0f, self.view.frame.size.width, 1.0f);
    
    bottomBorder.backgroundColor = [[UIColor colorWithRed:241.0/255.0f green:242.0/255.0f blue:242.0/255.0f alpha:1.0] CGColor];
    
    [self.navigationController.navigationBar.layer addSublayer:bottomBorder];
    
    // Do any additional setup after loading the view.
    PFQuery *userImage = [PFQuery queryWithClassName:@"Photo"];
    [userImage whereKey:@"user" equalTo:[PFUser currentUser]];
    
    [userImage getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        PFFile *imageFile = object[@"image"];
        
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            self.userPhotoImageView.image = [UIImage imageWithData:data];
            self.userPhotoImageView.contentMode = UIViewContentModeScaleAspectFit;
        }];
        
    }];


    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)setUserImage:(UIButton *)sender {
}


- (IBAction)logoutButtonPressed:(UIButton *)sender {
    [PFUser logOut];
}

@end
