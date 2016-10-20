//
//  DisplayCardVC.m
//  UberforXOwner
//
//  Created by Deep Gami on 17/11/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "DisplayCardVC.h"
#import "DispalyCardCell.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "AFNHelper.h"

@interface DisplayCardVC ()
{
    NSMutableArray *arrForCards;
}

@end

@implementation DisplayCardVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    arrForCards=[[NSMutableArray alloc]init];
    [super setBackBarItem];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.tableView.tableHeaderView=self.headerView;
    self.tableView.hidden=NO;
    self.headerView.hidden=NO;
    self.lblNoCards.hidden=YES;
     self.imgNoItems.hidden=YES;
    [self getAllMyCards];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)addCardBtnPressed:(id)sender
{
    [self performSegueWithIdentifier:SEGUE_TO_ADD_CARD sender:self];
}
#pragma mark -
#pragma mark - UITableView Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrForCards.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DispalyCardCell *cell=(DispalyCardCell *)[self.tableView dequeueReusableCellWithIdentifier:@"cardcell"];
    if (cell==nil) {
        cell=[[DispalyCardCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellSlider"];
    }
    if(arrForCards.count>0)
    {
        NSMutableDictionary *dict=[arrForCards objectAtIndex:indexPath.row];
        cell.lblcardNUmber.text=[NSString stringWithFormat:@"***%@",[dict valueForKey:@"last_four"]];
    }
    return cell;
}

/*
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
 */

-(void)getAllMyCards
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        NSString * strForUserId=[pref objectForKey:PREF_USER_ID];
        NSString * strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
        
        
        NSMutableString *pageUrl=[NSMutableString stringWithFormat:@"%@?%@=%@&%@=%@",FILE_GET_CARDS,PARAM_ID,strForUserId,PARAM_TOKEN,strForUserToken];
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:pageUrl withParamData:nil withBlock:^(id response, NSError *error)
         {
             
             NSLog(@"History Data= %@",response);
             [APPDELEGATE hideLoadingView];
             if (response)
             {
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     
                     [APPDELEGATE hideLoadingView];
                     [arrForCards removeAllObjects];
                     [arrForCards addObjectsFromArray:[response valueForKey:@"payments"]];
                     NSDictionary *dictCardId = [arrForCards objectAtIndex:0];
                     NSString *strCardId = [dictCardId valueForKey:@"id"];
                     
                     NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
                     [pref setObject:strCardId forKey:PARAM_CARD_ID];
                     [pref synchronize];

                   
                     if (arrForCards.count==0)
                     {
                         self.tableView.hidden=YES;
                         self.headerView.hidden=YES;
                         self.lblNoCards.hidden=NO;
                         self.imgNoItems.hidden=NO;
                     }
                     else
                     {
                         
                         self.tableView.hidden=NO;
                         self.headerView.hidden=NO;
                         self.lblNoCards.hidden=YES;
                         self.imgNoItems.hidden=YES;
                         [self.tableView reloadData];
                     }
                     
                     
                 }
             }
             
         }];
        
        
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Internet" message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0f;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView=[[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 1.0f)];
    footerView.backgroundColor=[UIColor colorWithRed:96.0f/255.0f green:201.0f/255.0f blue:255.0/255.0f alpha:1.0f];
    
    return footerView;
}

- (IBAction)backBtnPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
