//
//  JKELoginViewController.h
//  NoteApp
//
// All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JKELoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)login:(id)sender;

@end
