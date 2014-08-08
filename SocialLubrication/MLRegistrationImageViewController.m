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
@property (strong, nonatomic) IBOutlet UIButton *setImageButtonPressed;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *createAccountBarButtonPressed;

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
    
    /* Setup a placeholder image for user registration */
    self.userImageView.image = [UIImage imageNamed:@"placeholder.jpg"];
    self.userImageView.contentMode = UIViewContentModeScaleAspectFit;
	// Do any additional setup after loading the view.
    
    /* NavBar Bottom Border */
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, 45.0f, self.view.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [[UIColor colorWithRed:241.0/255.0f green:242.0/255.0f blue:242.0/255.0f alpha:1.0] CGColor];
    [self.navigationController.navigationBar.layer addSublayer:bottomBorder];
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/* Dismisses imagepicker and saves the image chosen to an object */

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.userImageView.image = image;
    
    NSData *imageData = UIImagePNGRepresentation(image);
    
    self.userCredentials.userPhoto = imageData;
    
}


#pragma mark - Buttons

/* Brings up the image picker for user to select their profile picture */

- (IBAction)userImageButtonPressed:(UIButton *)sender {
    
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.delegate = self;
    imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self.navigationController presentViewController:imgPicker animated:YES completion:nil];
}

/* Creates the user account, assigns the user attributes to the database on Parse and takes us back to the login page */

- (IBAction)createAccountBarButtonPressed:(UIBarButtonItem *)sender {
    
    /* Start activity indicator */
    
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    
    /* While uploading, make sure the user cannot move away from page */
    
    self.setImageButtonPressed.enabled = NO;
    self.createAccountBarButtonPressed.enabled = NO;
    self.navigationItem.backBarButtonItem.enabled = NO;
    
    /* Creating a new user with all the login credentials */
    
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
                    else{
                        self.setImageButtonPressed.enabled = YES;
                        self.createAccountBarButtonPressed.enabled = YES;
                        self.navigationItem.backBarButtonItem.enabled = YES;
                        self.activityIndicator.hidden = YES;
                        [self.activityIndicator stopAnimating];
                    }
                }];
            }];
        }
    }];

    /* Uncomment to see all account creation values being uploaded */
    
    //    NSLog(@"%@", self.userCredentials.userName);
    //    NSLog(@"%@", self.userCredentials.userPassword);
    //    NSLog(@"%@", self.userCredentials.userEmail);
    //    NSLog(@"%@", self.userCredentials.userBirthday);
    
}

@end
