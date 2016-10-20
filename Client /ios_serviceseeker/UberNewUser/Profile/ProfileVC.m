//
//  ProfileVC.m
//  UberNew
//
//  Created by Elluminati - macbook on 26/09/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "ProfileVC.h"
#import "UIImageView+Download.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVBase.h>
#import <AVFoundation/AVFoundation.h>
#import "Constants.h"
#import "AppDelegate.h"
#import "AFNHelper.h"
#import "UtilityClass.h"
#import "UIView+Utils.h"

@interface ProfileVC ()
{
    NSString *strForUserId,*strForUserToken;
}

@end

@implementation ProfileVC

#pragma mark -
#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark -
#pragma mark - ViewLife Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[super setNavBarTitle:TITLE_PROFILE];
    [super setBackBarItem];
    [self setDataForUserInfo];
    [self.proPicImgv applyRoundedCornersFullWithColor:[UIColor whiteColor]];
    [self customFont];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.btnEdit.hidden=NO;
    self.btnUpdate.hidden=YES;
    [self.txtFirstName setTintColor:[UIColor whiteColor]];
    [self.txtLastName setTintColor:[UIColor whiteColor]];
    
    [self textDisable];
}
-(void)setDataForUserInfo
{
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictInfo=[pref objectForKey:PREF_LOGIN_OBJECT];
    
    [self.proPicImgv downloadFromURL:[dictInfo valueForKey:@"picture"] withPlaceholder:nil];
    self.txtFirstName.text=[dictInfo valueForKey:@"first_name"];
    self.txtLastName.text=[dictInfo valueForKey:@"last_name"];
    self.txtEmail.text=[dictInfo valueForKey:@"email"];
    self.txtPhone.text=[dictInfo valueForKey:@"phone"];
    self.txtAddress.text=[dictInfo valueForKey:@"address"];
    self.txtZipCode.text=[dictInfo valueForKey:@"zipcode"];
    self.txtBio.text=[dictInfo valueForKey:@"bio"];

}
#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)selectPhotoBtnPressed:(id)sender
{
    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
    UIActionSheet *actionpass;
    
    actionpass = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"SELECT_PHOTO", @""),NSLocalizedString(@"TAKE_PHOTO", @""),nil];
    actionpass.delegate=self;
    [actionpass showInView:window];
}

- (IBAction)updateBtnPressed:(id)sender
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        
        
        if([[UtilityClass sharedObject]isValidEmailAddress:self.txtEmail.text])
        {
            
            [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"EDITING", nil)];
            NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
            strForUserId=[pref objectForKey:PREF_USER_ID];
            strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
            
            NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
            [dictParam setValue:self.txtEmail.text forKey:PARAM_EMAIL];
            [dictParam setValue:self.txtFirstName.text forKey:PARAM_FIRST_NAME];
            [dictParam setValue:self.txtLastName.text forKey:PARAM_LAST_NAME];
            [dictParam setValue:self.txtPhone.text forKey:PARAM_PHONE];
            [dictParam setValue:self.txtBio.text forKey:PARAM_BIO];
            [dictParam setValue:strForUserId forKey:PARAM_ID];
            [dictParam setValue:strForUserToken forKey:PARAM_TOKEN];
            
            [dictParam setValue:self.txtAddress.text forKey:PARAM_ADDRESS];
            [dictParam setValue:@"" forKey:PARAM_STATE];
            [dictParam setValue:@"" forKey:PARAM_COUNTRY];
            [dictParam setValue:self.txtZipCode.text forKey:PARAM_ZIPCODE];
            
            
            UIImage *imgUpload = [[UtilityClass sharedObject]scaleAndRotateImage:self.proPicImgv.image];
            
            AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
            [afn getDataFromPath:FILE_UPADTE withParamDataImage:dictParam andImage:imgUpload withBlock:^(id response, NSError *error) {
                
                [[AppDelegate sharedAppDelegate]hideLoadingView];
                if (response)
                {
                    if([[response valueForKey:@"success"] boolValue])
                    {
                        
                        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                        [pref setObject:response forKey:PREF_LOGIN_OBJECT];
                        [pref synchronize];
                        [self setDataForUserInfo];
                        [APPDELEGATE showToastMessage:NSLocalizedString(@"PROFILE_EDIT_SUCESS", nil)];
                        [self textDisable];
                        self.btnUpdate.hidden=YES;
                        self.btnEdit.hidden=NO;
                        
                        // [self.navigationController popViewControllerAnimated:YES];
                    }
                    else
                    {
                        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"ERROR", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                        [alert show];
                    }
                }
                
                NSLog(@"REGISTER RESPONSE --> %@",response);
            }];
        }
        
        
    }
    
    else
    {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Status" message:@"Sorry, network is not available. Please try again later." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

- (IBAction)editBtnPressed:(id)sender
{
    [self textEnable];
    [self.btnEdit setHidden:YES];
    [self.btnUpdate setHidden:NO];
    [self.txtFirstName becomeFirstResponder];
    [APPDELEGATE showToastMessage:@"You Can Edit Your Profile"];

}

#pragma mark-
#pragma mark- Custom Font

-(void)customFont
{
    self.txtFirstName.font=[UberStyleGuide fontRegularBold:18.0f];
    self.txtLastName.font=[UberStyleGuide fontRegularBold:18.0f];
    self.txtPhone.font=[UberStyleGuide fontRegular];
    self.txtEmail.font=[UberStyleGuide fontRegular];
    self.txtAddress.font=[UberStyleGuide fontRegular];
    self.txtBio.font=[UberStyleGuide fontRegular];
    self.txtZipCode.font=[UberStyleGuide fontRegular];
    
    self.btnNavigation.titleLabel.font=[UberStyleGuide fontRegular];
   self.btnEdit.titleLabel.font=[UberStyleGuide fontRegularBold];
    self.btnUpdate.titleLabel.font=[UberStyleGuide fontRegularBold];
}


-(void)textDisable
{
    self.txtFirstName.enabled = NO;
    self.txtLastName.enabled = NO;
    self.txtEmail.enabled = NO;
    self.txtPhone.enabled = NO;
    self.txtAddress.enabled = NO;
    self.txtZipCode.enabled = NO;
    self.txtBio.enabled = NO;
    self.btnProPic.enabled=NO;
}

-(void)textEnable
{
    self.txtFirstName.enabled = YES;
    self.txtLastName.enabled = YES;
    self.txtEmail.enabled = YES;
    self.txtPhone.enabled = YES;
    self.txtAddress.enabled = YES;
    self.txtZipCode.enabled = YES;
    self.txtBio.enabled = YES;
    self.btnProPic.enabled=YES;
}
#pragma mark
#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 1:
        {
            [self takePhoto];
        }
            break;
        case 0:
        {
            [self selectPhotos];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark
#pragma mark - Action to Share


- (void)selectPhotos
{
    // Set up the image picker controller and add it to the view
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:imagePickerController animated:YES completion:^{
        
    }];
}

-(void)takePhoto
{
    // Set up the image picker controller and add it to the view
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:imagePickerController animated:YES completion:^{
        
    }];
}

#pragma mark
#pragma mark - ImagePickerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if([info valueForKey:UIImagePickerControllerOriginalImage]==nil)
    {
        ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
        [assetLibrary assetForURL:[info valueForKey:UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset) {
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            Byte *buffer = (Byte*)malloc(rep.size);
            NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
            NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];//
            UIImage *img=[UIImage imageWithData:data];
            [self setImage:img];
        } failureBlock:^(NSError *err) {
            NSLog(@"Error: %@",[err localizedDescription]);
        }];
    }
    else
    {
        [self setImage:[info valueForKey:UIImagePickerControllerOriginalImage]];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)setImage:(UIImage *)image
{
    self.proPicImgv.image=image;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark
#pragma mark - UItextField Delegate

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    int y=0;
    if(textField==self.txtPhone)
        y=-100;
    else if(textField==self.txtAddress)
        y=-136;
    else if(textField==self.txtBio)
        y=-150;
    else if(textField==self.txtZipCode)
        y=-170;
    
    [UIView animateWithDuration:0.5 animations:^{
        
            self.view.frame=CGRectMake(0, y, self.view.frame.size.width, self.view.frame.size.height);
        
    } completion:^(BOOL finished)
     {
     }];
    
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField==self.txtLastName)
    {
       
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    /*if (textField==self.txtFirstName)
    {
        [self.txtLastName becomeFirstResponder];
    }
    if (textField==self.txtLastName)
    {
         //[[UITextField appearance] setTintColor:[UIColor blackColor]];
        [self.txtEmail becomeFirstResponder];
    }
    if (textField==self.txtEmail)
    {
        [self.txtPhone becomeFirstResponder];
    }
    if (textField==self.txtPhone)
    {
     
        [self.txtAddress becomeFirstResponder];
    }
    if (textField==self.txtAddress)
    {
        [self.txtBio  becomeFirstResponder];
    }
    if (textField==self.txtBio)
    {
        [self.txtZipCode becomeFirstResponder];
    }*/

    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.view.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
    } completion:^(BOOL finished)
     {
     }];
    
    [textField resignFirstResponder];
    return YES;
}
@end
