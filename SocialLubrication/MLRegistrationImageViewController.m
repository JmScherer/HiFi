//
//  MLRegistrationImageViewController.m
//  SocialLubrication
//
//  Created by James Scherer on 2/4/14.
//  Copyright (c) 2014 Mazag Labs. All rights reserved.
//

#import "MLRegistrationImageViewController.h"


@interface MLRegistrationImageViewController () <UIImagePickerControllerDelegate, UINavigationBarDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation MLRegistrationImageViewController

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
    
    self.activityIndicator.hidden = YES;
    
    self.userImageView.image = [UIImage imageNamed:@"placeholder.jpg"];
	// Do any additional setup after loading the view.
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)userImageButtonPressed:(UIButton *)sender {
    
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.delegate = self;
    imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
 
    
    [self.navigationController presentViewController:imgPicker animated:YES completion:nil];
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.userImageView.image = image;
    
    NSData *imageData = UIImagePNGRepresentation(image);
    
    self.userCredentials.userPhoto = imageData;
    
}


#pragma mark - 

- (IBAction)createAccountBarButtonPressed:(UIBarButtonItem *)sender {
    
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    
    NSLog(@"%@", self.userCredentials.userName);
    NSLog(@"%@", self.userCredentials.userPassword);
    NSLog(@"%@", self.userCredentials.userEmail);
    NSLog(@"%@", self.userCredentials.userBirthday);
    
    PFUser *user = [PFUser user];
    
        user.username = self.userCredentials.userName;
        user.password = self.userCredentials.userPassword;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(!error){
            user.email = self.userCredentials.userEmail;
            user[@"birthday"] = self.userCredentials.userBirthday;
            user[@"gender"] = self.userCredentials.userGender;
            
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                PFFile *photoFile = [PFFile fileWithData:self.userCredentials.userPhoto];
                
                [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if(succeeded){
                        PFObject *photo = [PFObject objectWithClassName:@"Photo"];
                        [photo setObject:user forKey:@"user"];
                        [photo setObject:photoFile forKey:@"image"];
                        [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            NSLog(@"Photo Saved Successfully");
                            self.activityIndicator.hidden = YES;
                            [self.activityIndicator stopAnimating];
                            [self.navigationController popToRootViewControllerAnimated:YES];
                            PFObject *userDefaultLocation = [PFObject objectWithClassName:@"Location"];
                            [userDefaultLocation setObject:[PFUser currentUser] forKey:@"user"];
                            [userDefaultLocation setObject:@"Home" forKey:@"location"];
                            [userDefaultLocation saveInBackground];
                        }];
                    }
                }];
            }];
        }
    }];

}

@end
