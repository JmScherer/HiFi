//
//  MLLoginViewController.m
//  SocialLubrication
//
//  Created by James Scherer on 2/2/14.
//  Copyright (c) 2014 Mazag Labs. All rights reserved.
//

#import "MLLoginViewController.h"
#import "MLRegistrationUserInfoViewController.h"

@interface MLLoginViewController () <UITextFieldDelegate, MLRegistrationUserInfoViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loginActivityIndicator;


@property (strong, nonatomic) IBOutlet UIButton *createAccountButton;
@property (strong, nonatomic) IBOutlet UIButton *signinButton;

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
	// Do any additional setup after loading the view.
    
    
    
    
    
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    self.loginActivityIndicator.hidden = YES;
    
    //Temp Login
    
    self.usernameTextField.text = @"Jscherer";
    self.passwordTextField.text = @"Homehome1";

    
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Prepare for Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.destinationViewController isKindOfClass:[MLRegistrationUserInfoViewController class]]){
        MLRegistrationUserInfoViewController *registerUserVC = segue.destinationViewController;
        registerUserVC.delegate = self;
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

#pragma mark - Buttons


- (IBAction)createAccountButtonPressed:(UIButton *)sender {
    
    //[self performSegueWithIdentifier:@"loginToRegisterSegue" sender:self];
    
}

- (IBAction)SigninButtonPressed:(UIButton *)sender {
    
    
    
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
        }
        else {
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [errorAlertView show];
        }
    }];
    
}

#pragma mark - MLRegistrationDelegate




@end
