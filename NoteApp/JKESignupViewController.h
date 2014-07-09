//
//  JKESignupViewController.h
//  NoteApp
//
// All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JKESignupViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)signup:(id)sender;

@end
