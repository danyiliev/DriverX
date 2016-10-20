//
//  ProfileVC.m
//  UberNewDriver
//
//  Created by My mac on 11/3/14.
//  Copyright (c) 2014 Deep Gami. All rights reserved.
//

#import "ProfileVC.h"
#import "UIImageView+Download.h"
#import "UIView+Utils.h"
#import "UtilityClass.h"

@interface ProfileVC ()
{
    BOOL internet;
    NSMutableString *strUserId;
    NSMutableString *strUserToken;
    NSMutableString *strPassword;
}

@end

@implementation ProfileVC

@synthesize txtAddress,title,txtBio,txtEmail,txtLastName,txtName,txtNumber,txtZip,txtPassword,btnProPic;

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
    [super setBackBarItem];
    [self.profileImage applyRoundedCornersFullWithColor:[UIColor whiteColor]];
    [self.ScrollProfile setScrollEnabled:NO];
    [self.ScrollProfile setContentSize:CGSizeMake(320, 520)];
    
    [self textDisable];
    
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    [pref synchronize];
    strUserId=[pref objectForKey:PREF_USER_ID];
    strUserToken=[pref objectForKey:PREF_USER_TOKEN];
    strPassword=[pref objectForKey:PREF_PASSWORD];
    
    [txtName setTintColor:[UIColor whiteColor]];
    [txtLastName setTintColor:[UIColor whiteColor]];
    
    txtName.text=[arrUser valueForKey:@"first_name"];
    txtLastName.text=[arrUser valueForKey:@"last_name"];
    txtEmail.text=[arrUser valueForKey:@"email"];
    txtNumber.text=[arrUser valueForKey:@"phone"];
    txtAddress.text=[arrUser valueForKey:@"address"];
    txtZip.text=[arrUser valueForKey:@"zipcode"];
    txtBio.text=[arrUser valueForKey:@"bio"];
    txtPassword.text=strPassword;
    [self.profileImage downloadFromURL:[arrUser valueForKey:@"picture"] withPlaceholder:nil];
    
    [self.btnUpdate setHidden:YES];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-
#pragma mark- Custom Font

-(void)customFont
{
    self.txtName.font=[UberStyleGuide fontRegular];
    self.txtLastName.font=[UberStyleGuide fontRegular];
    self.txtEmail.font=[UberStyleGuide fontRegular];
    self.txtAddress.font=[UberStyleGuide fontRegular];
    self.txtBio.font=[UberStyleGuide fontRegular];
    self.txtZip.font=[UberStyleGuide fontRegular];
    
    self.btnMenu.titleLabel.font=[UberStyleGuide fontRegular:9.0f];
    self.btnEdit=[APPDELEGATE setBoldFontDiscriptor:self.btnEdit];
    self.btnUpdate=[APPDELEGATE setBoldFontDiscriptor:self.btnUpdate];
    
}

#pragma mak- 
#pragma mark- TextField Enable and Disable

-(void)textDisable
{
    txtName.enabled = NO;
    txtLastName.enabled = NO;
    txtEmail.enabled = NO;
    txtNumber.enabled = NO;
    txtPassword.enabled = NO;
    txtAddress.enabled = NO;
    txtZip.enabled = NO;
    txtBio.enabled = NO;
    btnProPic.enabled=NO;
}

-(void)textEnable
{
    txtName.enabled = YES;
    txtLastName.enabled = YES;
    txtEmail.enabled = YES;
    txtNumber.enabled = YES;
    txtPassword.enabled = YES;
    txtAddress.enabled = YES;
    txtZip.enabled = YES;
    txtBio.enabled = YES;
    btnProPic.enabled=YES;
}


-(void)updatePRofile
{
    NSLog(@"\n\n IN Update PRofile");
    
    [APPDELEGATE showLoadingWithTitle:NSLocalizedString(@"UPDATING_PROFILE", nil)];
    internet=[APPDELEGATE connected];
    
    if(internet)
    {
    
        
        NSMutableDictionary *dictparam;
        dictparam= [[NSMutableDictionary alloc]init];
        
        [dictparam setObject:txtName.text forKey:PARAM_FIRST_NAME];
        [dictparam setObject:txtLastName.text forKey:PARAM_LAST_NAME];
        [dictparam setObject:txtEmail.text forKey:PARAM_EMAIL];
        //[dictparam setObject:txtNumber.text forKey:PARAM_PHONE];
        [dictparam setObject:strPassword forKey:PARAM_PASSWORD];
        [dictparam setObject:txtAddress.text forKey:PARAM_ADDRESS];
       // [dictparam setObject:txtBio.text forKey:PARAM_BIO];
        //[dictparam setObject:txtZip.text forKey:PARAM_ZIPCODE];
        //[dictparam setObject:device_token forKey:PARAM_DEVICE_TOKEN];
        
        [dictparam setObject:strUserId forKey:PARAM_ID];
        [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
        
       
        
        [dictparam setObject:@"" forKey:PARAM_PICTURE];
        
        UIImage *imgUpload = [[UtilityClass sharedObject]scaleAndRotateImage:self.profileImage.image];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_UPDATE_PROFILE withParamDataImage:dictparam andImage:imgUpload withBlock:^(id response, NSError *error)
         {
             
             if (response)
             {
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     arrUser=response;
                     [APPDELEGATE showToastMessage:NSLocalizedString(@"PROFILE_UPDATED", nil)];
                     txtName.text=[arrUser valueForKey:@"first_name"];
                     txtLastName.text=[arrUser valueForKey:@"last_name"];
                     txtEmail.text=[arrUser valueForKey:@"email"];
                     txtNumber.text=[arrUser valueForKey:@"phone"];
                     txtAddress.text=[arrUser valueForKey:@"address"];
                     txtZip.text=[arrUser valueForKey:@"zipcode"];
                     txtBio.text=[arrUser valueForKey:@"bio"];
                     [self.profileImage downloadFromURL:[arrUser valueForKey:@"picture"] withPlaceholder:nil];
                     
                     
                     
                 }
                 else
                 {
                     UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Fail" message:@"Profile Update Fail" delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                     [alert show];
                 }
                 [self.btnEdit setHidden:NO];
                 [self.btnUpdate setHidden:YES];
                 [self textDisable];
             }
             
             [APPDELEGATE hideLoadingView];
             
             NSLog(@"REGISTER RESPONSE --> %@",response);
         }];
        
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Internet" message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alert show];
    }

}
#pragma mark-
#pragma mark- Button Method

- (IBAction)LogOutBtnPressed:(id)sender
{
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    
    [pref synchronize];
    [pref removeObjectForKey:PARAM_REQUEST_ID];
    [pref removeObjectForKey:PARAM_SOCIAL_ID];
    [pref removeObjectForKey:PREF_EMAIL];
    [pref removeObjectForKey:PREF_LOGIN_BY];
    [pref removeObjectForKey:PREF_PASSWORD];
    [pref setBool:NO forKey:PREF_IS_LOGIN];
    
    [self.navigationController.navigationController    popToRootViewControllerAnimated:YES];
}

- (IBAction)editBtnPressed:(id)sender
{
    [self textEnable];
    [APPDELEGATE showToastMessage:@"You Can Edit Your Profile"];
    [self.btnEdit setHidden:YES];
    [self.btnUpdate setHidden:NO];
    [txtName becomeFirstResponder];
    
    
}

- (IBAction)updateBtnPressed:(id)sender
{
    internet=[APPDELEGATE connected];
    [self updatePRofile];
}

- (IBAction)backBtnPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)imgPicBtnPressed:(id)sender
{
    UIActionSheet *action=[[UIActionSheet alloc]initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Select Image", nil];
    action.tag=10001;
    [action showInView:self.view];
    
}


#pragma mark -
#pragma mark - UIActionSheet delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
            [self openCamera];
            break;
        case 1:
            [self chooseFromLibaray];
            break;
        case 2:
            break;
        case 3:
            break;
    }
}

-(void)openCamera
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        
        imagePickerController.delegate =self;
        imagePickerController.allowsEditing=YES;

        imagePickerController.view.tag = 102;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePickerController animated:YES completion:^{
            
        }];
    }
    else
    {
        UIAlertView *alt = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"CAM_NOT_AVAILABLE", nil)delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alt show];
    }
}

-(void)chooseFromLibaray
{
    // Set up the image picker controller and add it to the view
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
   
    imagePickerController.delegate =self;
    
     imagePickerController.allowsEditing=YES;
    imagePickerController.view.tag = 102;
    
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:^{
    }];
}

#pragma mark -
#pragma mark - UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.profileImage.image=[info objectForKey:UIImagePickerControllerOriginalImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark-
#pragma mark- Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField     //Hide the keypad when we pressed return
{
    /*if (textField==txtName)
    {
        [self.txtLastName becomeFirstResponder];
    }
    if (textField==txtLastName)
    {
        [self.txtEmail becomeFirstResponder];
    }
    if (textField==txtEmail)
    {
        [self.txtNumber becomeFirstResponder];
    }
    if (textField==txtNumber)
    {
        [self.txtAddress becomeFirstResponder];
    }
    if (textField==txtAddress)
    {
        [self.txtBio  becomeFirstResponder];
    }
    if (textField==txtBio)
    {
        [self.txtZip becomeFirstResponder];
    }*/
    
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField

{
    if(textField == self.txtPassword)
    {
        UITextPosition *beginning = [self.txtPassword beginningOfDocument];
        [self.txtPassword setSelectedTextRange:[self.txtPassword textRangeFromPosition:beginning
                                                                            toPosition:beginning]];
        [UIView animateWithDuration:0.3 animations:^{
            
            self.view.frame = CGRectMake(0, -35, 320, 480);
            
        } completion:^(BOOL finished) { }];
    }
    if(textField == self.txtAddress)
    {
        UITextPosition *beginning = [self.txtAddress beginningOfDocument];
        [self.txtAddress setSelectedTextRange:[self.txtAddress textRangeFromPosition:beginning
                                                                          toPosition:beginning]];
        [UIView animateWithDuration:0.3 animations:^{
            
            self.view.frame = CGRectMake(0, -75, 320, 480);
            
        } completion:^(BOOL finished) { }];
    }
    if(textField == self.txtBio)
    {
        UITextPosition *beginning = [self.txtBio beginningOfDocument];
        [self.txtBio setSelectedTextRange:[self.txtBio textRangeFromPosition:beginning
                                                                  toPosition:beginning]];
        [UIView animateWithDuration:0.3 animations:^{
            
            self.view.frame = CGRectMake(0, -115, 320, 480);
            
        } completion:^(BOOL finished) { }];
    }
    else if(textField == self.txtZip)
    {
        [UIView animateWithDuration:0.3 animations:^{
            
            self.view.frame = CGRectMake(0, -128, 320, 480);
            
        } completion:^(BOOL finished) { }];
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    UIDevice *thisDevice=[UIDevice currentDevice];
    if(thisDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        
        if (iOSDeviceScreenSize.height == 568)
        {
            if(textField == self.txtPassword)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    
                    self.view.frame = CGRectMake(0, 0, 320, 568);
                    
                } completion:^(BOOL finished) { }];
            }
            else if(textField == self.txtAddress)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    
                    self.view.frame = CGRectMake(0, 0, 320, 568);
                    
                } completion:^(BOOL finished) { }];
            }
            else if(textField == self.txtBio)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    
                    self.view.frame = CGRectMake(0, 0, 320, 568);
                    
                } completion:^(BOOL finished) { }];
            }
            else if (textField == self.txtZip)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    
                    self.view.frame = CGRectMake(0, 0, 320, 568);
                    
                } completion:^(BOOL finished) { }];
            }
            
        }
        else
        {
            
            if(textField == self.txtPassword)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    
                    self.view.frame = CGRectMake(0, 0, 320, 480);
                    
                } completion:^(BOOL finished) { }];
            }
            else if(textField == self.txtAddress)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    
                    self.view.frame = CGRectMake(0, 0, 320, 480);
                    
                } completion:^(BOOL finished) { }];
            }
            else if(textField == self.txtBio)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    
                    self.view.frame = CGRectMake(0, 0, 320, 480);
                    
                } completion:^(BOOL finished) { }];
            }
            else if (textField == self.txtZip)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    
                    self.view.frame = CGRectMake(0, 0, 320, 480);
                    
                } completion:^(BOOL finished) { }];
            }
            
        }
    }
}
@end
