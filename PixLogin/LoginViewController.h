//
//  LoginViewController.h
//  PixLogin
//
//  Created by Dave Scruton on 5/29/18.
//  Copyright © 2018 huedoku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageExtras.h"
#import <Parse/Parse.h>

//REMOVE AT INTEGRATION TIME
#define PORTRAIT_PERCENT 50
#define LOGIN_AVATAR_SIZE 128

@interface LoginViewController : UIViewController
        <UINavigationControllerDelegate,  UIImagePickerControllerDelegate , UITextFieldDelegate>
{
    int page;
    int lastPage;
    CGRect pixLabelRect;
//    CGRect halationLabelRect;
//    CGRect bcRowFrame;
    
    int viewWid,viewHit,viewW2,viewH2;
    BOOL animating;
    BOOL returningFromPhotoPicker;
    UIImage *avatarImage;
    float animSpeed;
    BOOL newUser;
    int avatarNum;
    UIActivityIndicatorView *ai;
    int failCount;
    
    UIImage *bkgdTropo;
    UIImage *bkgdTilt;

}
@property (weak, nonatomic) IBOutlet UIImageView *obscura;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *portraitImage;
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UITextField *pwText;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet UILabel *chooseLabel;
@property (weak, nonatomic) IBOutlet UIView *faceView;
@property (weak, nonatomic) IBOutlet UIView *lsButtonView;
@property (weak, nonatomic) IBOutlet UIView *userPwView;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UIButton *resetPasswordButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet UIButton *anonymousButton;
- (IBAction)anonymousSelect:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *pwLabel;
@property (weak, nonatomic) IBOutlet UIView *activityView;


- (IBAction)resetPasswordSelect:(id)sender;

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *emailString;

@property (strong, nonatomic) NSString *entryMode;


- (IBAction)uploadSelect:(id)sender;
- (IBAction)facesSelect:(id)sender;
- (IBAction)face1Select:(id)sender;
- (IBAction)face2Select:(id)sender;
- (IBAction)face3Select:(id)sender;
- (IBAction)face4Select:(id)sender;
- (IBAction)face5Select:(id)sender;
- (IBAction)face6Select:(id)sender;
- (IBAction)loginSelect:(id)sender;
- (IBAction)signupSelect:(id)sender;
- (IBAction)leftSelect:(id)sender;
- (IBAction)rightSelect:(id)sender;


@end
