//
//  LoginViewController.h
//  PixLogin
//
//  Created by Dave Scruton on 5/29/18.
//  Copyright © 2018 huedoku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "spinnerView.h"
#import "UIImageExtras.h"

//REMOVE AT INTEGRATION TIME
#define PORTRAIT_PERCENT 50
#define LOGIN_AVATAR_SIZE 128

#define PL_NO_MODE     @"nada"
#define PL_SIGNUP_MODE @"signup"
#define PL_LOGIN_MODE  @"login"
#define PL_AVATAR_MODE @"avatar"

@interface LoginViewController : UIViewController
        <UINavigationControllerDelegate,  UIImagePickerControllerDelegate , UITextFieldDelegate>
{
    int state,page;
    int lastPage;
    CGRect pixLabelRect;
    int viewWid,viewHit,viewW2,viewH2;
    BOOL animating;
    BOOL returningFromPhotoPicker;
    UIImage *avatarImage;
    float animSpeed;
    BOOL newUser;
    int avatarNum;
    UIActivityIndicatorView *ai;
    int failCount;
    
    UIImage *bkgdGradient;
    
     spinnerView *spv;
    
    BOOL signupError;
    BOOL needPwReset;
    BOOL DBBeingAccessed;
    
    int createAccountStates[8];
    int loginState;
    int resetPasswordStates[2];
    int skipState;

}
@property (weak, nonatomic) IBOutlet UIImageView *obscura;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UILabel *topSmallLabel;


@property (weak, nonatomic) IBOutlet UIImageView *portraitImage;
@property (weak, nonatomic) IBOutlet UILabel *topTextLabel;
@property (weak, nonatomic) IBOutlet UITextField *topTextField;
@property (weak, nonatomic) IBOutlet UILabel *bottomTextLabel;
@property (weak, nonatomic) IBOutlet UITextField *bottomTextField;

@property (weak, nonatomic) IBOutlet UILabel *chooseLabel;
@property (weak, nonatomic) IBOutlet UIView *faceView;
@property (weak, nonatomic) IBOutlet UIView *lsButtonView;
@property (weak, nonatomic) IBOutlet UILabel *orLabel;


@property (weak, nonatomic) IBOutlet UIView *userPwView;

@property (weak, nonatomic) IBOutlet UIView *bottomButtonView;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;

@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UILabel *emailConfLabel;
@property (weak, nonatomic) IBOutlet UIButton *LSTopButton;
@property (weak, nonatomic) IBOutlet UIButton *LSBottomButton;
@property (weak, nonatomic) IBOutlet UIButton *anonymousButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotButton;


@property (strong, nonatomic) NSString *hueName;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *emailString;

@property (strong, nonatomic) NSString *entryMode;
- (IBAction)LSTopSelect:(id)sender;
- (IBAction)LSBottomSelect:(id)sender;
- (IBAction)anonymousSelect:(id)sender;
- (IBAction)textFieldChanged:(id)sender;

- (IBAction)uploadSelect:(id)sender;
- (IBAction)face1Select:(id)sender;
- (IBAction)face2Select:(id)sender;
- (IBAction)face3Select:(id)sender;
- (IBAction)face4Select:(id)sender;
- (IBAction)face5Select:(id)sender;
- (IBAction)face6Select:(id)sender;
- (IBAction)backSelect:(id)sender;
- (IBAction)resetPasswordSelect:(id)sender;


@end
