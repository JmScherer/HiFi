//
//  MLLoginViewController.m
//  SocialLubrication
//
//  Created by James Scherer on 2/2/14.
//  Copyright (c) 2014 Mazag Labs. All rights reserved.
//

#import "MLLoginViewController.h"
#import "MLRegistrationUserInfoViewController.h"
#import "MLUser.h"

@interface MLLoginViewController () <UITextFieldDelegate, MLRegistrationUserInfoViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loginActivityIndicator;

@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;

@property (strong, nonatomic) IBOutlet UIButton *createAccountButton;
@property (strong, nonatomic) IBOutlet UIButton *signinButton;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@end

@implementation MLLoginViewController

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
    
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    self.loginActivityIndicator.hidden = YES;
    
    
    /* Setting up the UIScrollView */
    [scroller setScrollEnabled:YES];
    scroller.contentSize = CGSizeMake(320, 568);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [scroller addGestureRecognizer:tap];
    [self subscribeToKeyboardEvents:YES];
    
    /* Temp login for testing purposes */
    
    self.usernameTextField.text = @"Jscherer";
    self.passwordTextField.text = @"Homehome1";

    /* Making sure the background is the appropriate for the user's screen size */
    
    int x = [[UIScreen mainScreen] bounds].size.width;
    int y = [[UIScreen mainScreen] bounds].size.height;
    
    BOOL isIPhone = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
    BOOL isIPhone5 = isIPhone && ([[UIScreen mainScreen] bounds].size.height > 480.0);
    if (isIPhone5) {
        self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.backgroundImageView.image = [UIImage imageNamed:@"iphone5_register_screen.png"];
    } else {
        self.backgroundImageView.frame = CGRectMake(0, 0, x, y);
        self.backgroundImageView.image = [UIImage imageNamed:@"iphone4_register_screen_2.png"];
    }
    
    /* Conforming text fields to design standards */
    
    self.usernameTextField.layer.cornerRadius=8.0f;
    self.usernameTextField.layer.masksToBounds=YES;
    self.usernameTextField.layer.borderColor=[[UIColor colorWithRed:109.0/255.0f green:110.0/255.0f blue:113.0/255.0f alpha:1.0f]CGColor];
    self.usernameTextField.layer.borderWidth= 1.0f;
    
    self.passwordTextField.layer.cornerRadius=8.0f;
    self.passwordTextField.layer.masksToBounds=YES;
    self.passwordTextField.layer.borderColor=[[UIColor colorWithRed:109.0/255.0f green:110.0/255.0f blue:113.0/255.0f alpha:1.0f]CGColor];
    self.passwordTextField.layer.borderWidth= 1.0f;
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    /* Keep nav bar hidden on login page at all times */
    
    self.navigationController.navigationBar.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    [self subscribeToKeyboardEvents:NO];
}

#pragma mark - Keyboard Events

- (void)subscribeToKeyboardEvents:(BOOL)subscribe{
    
    /* Make sure the keyboard responds to user's request to dismiss the keyboard and scroll the view if needed */
    
    if(subscribe){
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidShow:)
                                                     name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification object:nil];
    }else{
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
}

- (void) keyboardDidShow:(NSNotification *)nsNotification {
    
    /* Make sure the keyboard shows up and pushes the view up so the text field is not being covered by the keyboard */
    
    NSDictionary * userInfo = [nsNotification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect newFrame = [scroller frame];
    
    CGFloat kHeight = kbSize.height;
    
    if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)){
        kHeight = kbSize.width;
    }
    
    newFrame.size.height -= kHeight;
    
    [scroller setFrame:newFrame];
    
}

-(void)keyboardWillHide:(NSNotification *)nsNotification {
    
    /* Reset the view when the keyboard is dismissed */
    
    NSDictionary * userInfo = [nsNotification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect newFrame = [scroller frame];
    
    CGFloat kHeight = kbSize.height;
    
    if(UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)){
        kHeight = kbSize.width;
    }
    
    newFrame.size.height += kHeight;
    
    // save the content offset before the frame change
    CGPoint contentOffsetBefore = scroller.contentOffset;
    
    [scroller setHidden:YES];
    
    // set the new frame
    [scroller setFrame:newFrame];
    
    // get the content offset after the frame change
    CGPoint contentOffsetAfter =  scroller.contentOffset;
    
    // content offset initial state
    [scroller setContentOffset:contentOffsetBefore];
    
    [scroller setHidden:NO];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         [scroller setContentOffset:contentOffsetAfter];
                     }
                     completion:^(BOOL finished){
                         // do nothing for the time being...
                     }
     ];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Prepare for Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    /* If the user enters their username and tries to login to no avail, the username will be carried over to the registration page so they don't have to enter their username twice */
    
    if([segue.destinationViewController isKindOfClass:[MLRegistrationUserInfoViewController class]]){
        MLRegistrationUserInfoViewController *registerUserVC = segue.destinationViewController;
        registerUserVC.delegate = self;
        NSLog(@"Username Before: %@", self.usernameTextField.text);
        
        
        registerUserVC.userText = self.usernameTextField.text;
        NSLog(@"Username After: %@", registerUserVC.userText);
    }
    
}

#pragma mark - Text Field Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    
    return YES;
}

-(void)dismissKeyboard{
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

#pragma mark - Button Methods


- (IBAction)createAccountButtonPressed:(UIButton *)sender {
    
    [self performSegueWithIdentifier:@"loginToRegisterSegue" sender:self];
}

- (IBAction)SigninButtonPressed:(UIButton *)sender {
    
    /* User login method. Spins the activity indicator to show that the data is being sent to the server and the user has to wait. When finished, performs segue to the main page. */
    
    self.loginActivityIndicator.hidden = NO;
    [self.loginActivityIndicator startAnimating];
    self.createAccountButton.enabled = NO;
    self.signinButton.enabled = NO;
    
    [PFUser logInWithUsernameInBackground:self.usernameTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError *error) {
        
        [self.loginActivityIndicator stopAnimating];
        self.loginActivityIndicator.hidden = YES;
        self.createAccountButton.enabled = YES;
        self.signinButton.enabled = YES;
        
        if (user) {
            [self performSegueWithIdentifier:@"loginToInterestSegue" sender:self];
            [MLUser sharedInstance];
        }
        else {
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [errorAlertView show];
        }
    }];
    
}

#pragma mark - MLRegistrationDelegate

/* Test user #2, press button to change the credentials for debugging on separate account */

- (IBAction)awesomeButton:(UIButton *)sender {
    self.usernameTextField.text = @"Awesome";
    self.passwordTextField.text = @"Awesome";
}

@end
