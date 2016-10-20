//
//  PaymentVC.m
//  UberNew
//
//  Created by Elluminati - macbook on 26/09/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "PaymentVC.h"
#import "CardIO.h"
#import "PTKView.h"
#import "Stripe.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "AFNHelper.h"
#import "PTKTextField.h"

@interface PaymentVC ()<CardIOPaymentViewControllerDelegate,PTKViewDelegate>
{
    NSString *strForStripeToken,*strForLastFour;

}



@end

@implementation PaymentVC

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
    NSLog(@"NavigationList= %@",self.navigationController.viewControllers);
    
    [super setNavBarTitle:TITLE_PAYMENT];
    //[super setBackBarItem];
    
    
    PTKView *paymentView = [[PTKView alloc] initWithFrame:CGRectMake(15, 250, 9, 5)];
    paymentView.delegate = self;
    self.paymentView = paymentView;
    [self.view addSubview:paymentView];
    self.btnAddPayment.enabled=NO;
    
    self.btnMenu.titleLabel.font=[UberStyleGuide fontRegular];
   self.btnAddPayment.titleLabel.font=[UberStyleGuide fontRegularBold];
    
    self.btnRemove.hidden=NO;
    [APPDELEGATE.window addSubview:self.btnRemove];
    [APPDELEGATE.window bringSubviewToFront:self.btnRemove];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.paymentView resignFirstResponder];
}
#pragma mark -
#pragma mark - Actions


- (void)paymentView:(PTKView *)paymentView
           withCard:(PTKCard *)card
            isValid:(BOOL)valid
{
    // Enable save button if the Checkout is valid
    self.btnAddPayment.enabled=YES;
}
- (IBAction)scanBtnPressed:(id)sender
{
    CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
    scanViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    scanViewController.appToken = @""; // see Constants.h
    [self presentViewController:scanViewController animated:YES completion:nil];
    self.btnRemove.hidden = YES;

}

- (IBAction)addPaymentBtnPressed:(id)sender
{
    [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"LOADING", nil)];
    
    if (![self.paymentView isValid]) {
        return;
    }
    if (![Stripe defaultPublishableKey]) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"No Publishable Key"
                                                          message:@"Please specify a Stripe Publishable Key in Constants"
                                                         delegate:nil
                                                cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                otherButtonTitles:nil];
        [message show];
        return;
    }
    STPCard *card = [[STPCard alloc] init];
    card.number = self.paymentView.card.number;
    card.expMonth = self.paymentView.card.expMonth;
    card.expYear = self.paymentView.card.expYear;
    card.cvc = self.paymentView.card.cvc;
    [Stripe createTokenWithCard:card completion:^(STPToken *token, NSError *error) {
        if (error) {
            [self hasError:error];
        } else {
            [self hasToken:token];
            [self addCardOnServer];
        }
    }];
}

- (IBAction)backBtnPressed:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.btnRemove removeFromSuperview];
   
}

- (IBAction)removePaymentBtnPressed:(id)sender
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Remove Card" message:@"Are Sure You Want to Remove Card" delegate:self cancelButtonTitle:@"CANCEL" otherButtonTitles:@"OK", nil];
    alert.tag=100;
    [alert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 100)
    {
        if (buttonIndex == 1)
        {
            NSUserDefaults *prefCard=[NSUserDefaults standardUserDefaults];
            NSString *strForUserId=[prefCard objectForKey:PREF_USER_ID];
            NSString *strForUserToken=[prefCard objectForKey:PREF_USER_TOKEN];
            NSString *strCardId = [prefCard objectForKey:PARAM_CARD_ID];
            

            NSMutableDictionary *dictDeleteCard=[[NSMutableDictionary alloc]init];
            [dictDeleteCard setValue:strForUserToken forKey:PARAM_TOKEN];
            [dictDeleteCard setValue:strForUserId forKey:PARAM_ID];
            [dictDeleteCard setValue:strCardId forKey:PARAM_CARD_ID];
            

            
            AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
            [afn getDataFromPath:FILE_DELETE_CARD_TOKEN withParamData:dictDeleteCard withBlock:^(id response, NSError *error)
             {
                
                 if(response)
                 {
                     if([[response valueForKey:@"success"] boolValue])
                     {
                        
                         self.paymentView.cardNumberField.text=@"";
                         self.paymentView.cardExpiryField.text=@"";
                         self.paymentView.cardCVCField.text=@"";

                         UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Remove Card" message:@"successfully removed" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                         [alert show];

                     }
                     else
                     {
                        
                     }
                 }
                 
             }];

            
            
            
        }
    }
}
- (void)hasError:(NSError *)error {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                      message:[error localizedDescription]
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                            otherButtonTitles:nil];
    [message show];
}

- (void)hasToken:(STPToken *)token
{
    
    NSLog(@"%@",token.tokenId);
    NSLog(@"%@",token.card.last4);
    
    strForLastFour=token.card.last4;
    strForStripeToken=token.tokenId;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    return;
    
}

#pragma mark -
#pragma mark - CardIOPaymentViewControllerDelegate

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info inPaymentViewController:(CardIOPaymentViewController *)paymentViewController
{
    NSLog(@"Scan succeeded with info: %@", info);
    // Do whatever needs to be done to deliver the purchased items.
    [self dismissViewControllerAnimated:YES completion:nil];
    
    self.paymentView.cardNumberField.text =[NSString stringWithFormat:@"%@",info.redactedCardNumber];
    self.paymentView.cardExpiryField.text=[NSString stringWithFormat:@"%02lu/%lu",(unsigned long)info.expiryMonth, (unsigned long)info.expiryYear];
    self.paymentView.cardCVCField.text=[NSString stringWithFormat:@"%@",info.cvv];
    
    NSLog(@"%@", [NSString stringWithFormat:@"Received card info. Number: %@, expiry: %02lu/%lu, cvv: %@.", info.redactedCardNumber, (unsigned long)info.expiryMonth, (unsigned long)info.expiryYear, info.cvv]);
}

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)paymentViewController {
    NSLog(@"User cancelled scan");
   [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark - WS Methods

-(void)addCardOnServer
{
    
    if([[AppDelegate sharedAppDelegate]connected])
    {
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        NSString * strForUserId=[pref objectForKey:PREF_USER_ID];
        NSString * strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
        

        
    NSMutableDictionary *dictParam=[[NSMutableDictionary alloc]init];
    [dictParam setValue:strForUserToken forKey:PARAM_TOKEN];
    [dictParam setValue:strForUserId forKey:PARAM_ID];
    [dictParam setValue:strForStripeToken forKey:PARAM_STRIPE_TOKEN];
    [dictParam setValue:strForLastFour forKey:PARAM_LAST_FOUR];


    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
    [afn getDataFromPath:FILE_ADD_CARD withParamData:dictParam withBlock:^(id response, NSError *error)
     {
        [[AppDelegate sharedAppDelegate]hideLoadingView];
        if(response)
        {
            if([[response valueForKey:@"success"] boolValue])
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Successfully Added your card." delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                [alert show];
            }
            else
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"Fail to add your card." delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        
    }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Status" message:@"Sorry, network is not available. Please try again later." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}




@end
