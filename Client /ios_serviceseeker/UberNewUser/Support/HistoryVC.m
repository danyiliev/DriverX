//
//  SupportVC.m
//  UberNew
//
//  Created by Elluminati - macbook on 26/09/14.
//  Copyright (c) 2014 Jigs. All rights reserved.
//

#import "HistoryVC.h"
#import "HistoryCell.h"
#import "Constants.h"
#import "UIImageView+Download.h"
#import "AppDelegate.h"
#import "AFNHelper.h"
#import "UtilityClass.h"
#import "HistoryCellPrize.h"

@interface HistoryVC ()
{
    NSMutableArray *arrHistory;
    NSMutableArray *arrForDate;
    NSMutableArray *arrForSection;
    NSArray *arrTypes;

}

@end

@implementation HistoryVC

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
    self.viewForBill.hidden=YES;
    arrHistory=[[NSMutableArray alloc]init];
    //[super setNavBarTitle:TITLE_SUPPORT];
    [super setBackBarItem];
    [[AppDelegate sharedAppDelegate]showLoadingWithTitle:NSLocalizedString(@"GETTING HISTORY", nil)];
    [self getHistory];
    
    self.btnMenu.titleLabel.font=[UberStyleGuide fontRegular];
    
   // self.lblDistCost.font=[UberStyleGuide fontRegular];
   // self.lblBasePrice.font=[UberStyleGuide fontRegular];
    
   // self.lblPerDist.font=[UberStyleGuide fontRegular];
  //  self.lblPerTime.font=[UberStyleGuide fontRegular];
  //  self.lblTimeCost.font=[UberStyleGuide fontRegular];
    //self.lblTotal.font=[UberStyleGuide fontRegular:25.0f];
  
    
}

-(void)viewWillAppear:(BOOL)animated
{
    self.tableView.hidden=NO;
    self.viewForBill.hidden=YES;
   // self.lblnoHistory.hidden=YES;
    self.imgNoDisplay.hidden=YES;
    self.navigationController.navigationBarHidden=NO;
    self.tblPrize.tag=2;
    self.tableView.tag=0;
}

#pragma mark -
#pragma mark - Memory Mgmt

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark-
#pragma mark - Table view data source

-(void)makeSection
{
    arrForDate=[[NSMutableArray alloc]init];
    arrForSection=[[NSMutableArray alloc]init];
    NSMutableArray *arrtemp=[[NSMutableArray alloc]init];
    [arrtemp addObjectsFromArray:arrHistory];
    NSSortDescriptor *distanceSortDiscriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO
                                                                            selector:@selector(localizedStandardCompare:)];
    
    [arrtemp sortUsingDescriptors:@[distanceSortDiscriptor]];
    
    for (int i=0; i<arrtemp.count; i++)
    {
        NSMutableDictionary *dictDate=[[NSMutableDictionary alloc]init];
        dictDate=[arrtemp objectAtIndex:i];
        
        NSString *temp=[dictDate valueForKey:@"date"];
        NSArray *arrDate=[temp componentsSeparatedByString:@" "];
        NSString *strdate=[arrDate objectAtIndex:0];
        if(![arrForDate containsObject:strdate])
        {
            [arrForDate addObject:strdate];
        }
        
    }
    
    for (int j=0; j<arrForDate.count; j++)
    {
        NSMutableArray *a=[[NSMutableArray alloc]init];
        [arrForSection addObject:a];
    }
    for (int j=0; j<arrForDate.count; j++)
    {
        NSString *strTempDate=[arrForDate objectAtIndex:j];
        
        for (int i=0; i<arrtemp.count; i++)
        {
            NSMutableDictionary *dictSection=[[NSMutableDictionary alloc]init];
            dictSection=[arrtemp objectAtIndex:i];
            NSArray *arrDate=[[dictSection valueForKey:@"date"] componentsSeparatedByString:@" "];
            NSString *strdate=[arrDate objectAtIndex:0];
            if ([strdate isEqualToString:strTempDate])
            {
                [[arrForSection objectAtIndex:j] addObject:dictSection];
                
            }
        }
        
    }
    
    
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if(tableView.tag == 100)
    {
        return 1;
    }
    else
    {
        return arrForSection.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag==100)
    {
        return arrTypes.count;
    }
    else
    {
        return  [[arrForSection objectAtIndex:section] count];
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView.tag==100)
    {
        return 1.0f;
    }
    else
    {
        return 20.0f;
    }

}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if (tableView.tag==100)
    {
        return nil;
    }
    else
    {
    UIView *headerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 15)];
    UILabel *lblDate=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, 300, 15)];
    lblDate.font=[UberStyleGuide fontRegular:13.0f];
    lblDate.textColor=[UberStyleGuide colorDefault];
    NSString *strDate=[arrForDate objectAtIndex:section];
    NSString *current=[[UtilityClass sharedObject] DateToString:[NSDate date] withFormate:@"yyyy-MM-dd"];
    
   
    ///   YesterDay Date Calulation
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = -1;
    NSDate *yesterday = [gregorian dateByAddingComponents:dayComponent
                                                   toDate:[NSDate date]
                                                  options:0];
    NSString *strYesterday=[[UtilityClass sharedObject] DateToString:yesterday withFormate:@"yyyy-MM-dd"];
    
    
    if([strDate isEqualToString:current])
    {
        lblDate.text=@"Today";
        headerView.backgroundColor=[UberStyleGuide colorDefault];
        lblDate.textColor=[UIColor whiteColor];
    }
    else if ([strDate isEqualToString:strYesterday])
    {
        lblDate.text=@"Yesterday";
    }
    else
    {
        NSDate *date=[[UtilityClass sharedObject]stringToDate:strDate withFormate:@"yyyy-MM-dd"];
        NSString *text=[[UtilityClass sharedObject]DateToString:date withFormate:@"dd MMMM yyyy"];//2nd Jan 2015
        lblDate.text=text;
    }
    
    [headerView addSubview:lblDate];
    return headerView;
    }
}

/*- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [arrForDate objectAtIndex:section];
}*/

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (tableView.tag==100)
    {
        return nil;
    }
    else
    {
        UIImageView *imgFooter=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"rectangle2"]];
        return imgFooter;
    }
    

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
    static NSString *cellIdentifier = @"historycell";
    

    
    HistoryCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (cell==nil)
    {
        cell=[[HistoryCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }

    NSMutableDictionary *pastDict=[[arrForSection objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
    NSMutableDictionary *dictOwner=[pastDict valueForKey:@"walker"];

    cell.lblName.font=[UberStyleGuide fontRegularBold:12.0f];
    cell.lblPrice.font=[UberStyleGuide fontRegular:20.0f];
    cell.lblType.font=[UberStyleGuide fontRegular];
    //cell.lblTime.font=[UberStyleGuide fontRegular];
    
    cell.lblName.text=[NSString stringWithFormat:@"%@ %@",[dictOwner valueForKey:@"first_name"],[dictOwner valueForKey:@"last_name"]];
    cell.lblType.text=[NSString stringWithFormat:@"%@",[dictOwner valueForKey:@"phone"]];
    cell.lblPrice.text=[NSString stringWithFormat:@"$%@",[pastDict valueForKey:@"total"]];
    
    NSDate *dateTemp=[[UtilityClass sharedObject]stringToDate:[pastDict valueForKey:@"date"]];
    NSString *strDate=[[UtilityClass sharedObject]DateToString:dateTemp withFormate:@"hh:mm a"];
    

  
    
    cell.lblTime.text=[NSString stringWithFormat:@"%@",strDate];
    [cell.imageView downloadFromURL:[dictOwner valueForKey:@"picture"] withPlaceholder:nil];
        return cell;
     */
    
    if (tableView.tag==100)
    {
        
        static NSString *cellIdentifier = @"cell";
        
        HistoryCellPrize *cell = [self.tblPrize dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        NSDictionary *dict=[arrTypes objectAtIndex:indexPath.row];
        
        if (cell==nil)
        {
            cell=[[HistoryCellPrize alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        
        cell.lblName.text=[dict valueForKey:@"name"];
        cell.lblPrize.text=[NSString stringWithFormat:@"$%@",[dict valueForKey:@"price"]];
        
        return cell;
    }
    else
    {
        static NSString *cellIdentifier = @"historycell";
        
        HistoryCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
        if (cell==nil)
        {
            cell=[[HistoryCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        NSMutableDictionary *pastDict=[[arrForSection objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
        NSMutableDictionary *dictOwner=[pastDict valueForKey:@"walker"];
        
        
        if (indexPath.row%2==0)
        {
           // cell.imgBackground.image=[UIImage imageNamed:@"historyBlueBg"];
        }
        else
        {
            //cell.imgBackground.image=[UIImage imageNamed:@"historyGreenBg"];
        }
        
        cell.lblName.text=[NSString stringWithFormat:@"%@ %@",[dictOwner valueForKey:@"first_name"],[dictOwner valueForKey:@"last_name"]];
        cell.lblType.text=[NSString stringWithFormat:@"%@",[dictOwner valueForKey:@"phone"]];
        cell.lblPrice.text=[NSString stringWithFormat:@"$%@",[pastDict valueForKey:@"total"]];
        
        // NSDate *dateTemp=[[UtilityClass sharedObject]stringToDate:[pastDict valueForKey:@"date"]];
        //NSString *strDate=[[UtilityClass sharedObject]DateToString:dateTemp withFormate:@"hh:mm a"];
        
      //  [cell.ratingView initRateBar];
      //  [cell.ratingView setUserInteractionEnabled:NO];
        
     //   RBRatings rate=([[dictOwner valueForKey:@"rating"]floatValue]*2);
     //   [ cell.ratingView setRatings:rate];
        
        
        cell.lblTime.text=[NSString stringWithFormat:@"%@",[pastDict valueForKey:@"date"]];
        [cell.imageView downloadFromURL:[dictOwner valueForKey:@"picture"] withPlaceholder:nil];
        
        return cell;
    }
    return nil;

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag==100)
    {
        return 44;
    }
    else
    {
        return 60;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView.tag==100)
    {
        return;
    }
    else
    {
    self.navigationController.navigationBarHidden=YES;
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSMutableDictionary *pastDict=[[arrForSection objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
   
    NSLog(@"Payment Detail:- %@",pastDict);
    
   // self.lblBasePrice.text=[NSString stringWithFormat:@"$%@",[pastDict valueForKey:@"base_price"]];
  //  self.lblDistCost.text=[NSString stringWithFormat:@"$%@",[pastDict valueForKey:@"distance_cost"]];
  //  self.lblTimeCost.text=[NSString stringWithFormat:@"$%@",[pastDict valueForKey:@"time_cost"]];
    self.lblTotal.text=[NSString stringWithFormat:@"$%@",[pastDict valueForKey:@"total"]];
    
    float totalDist=[[pastDict valueForKey:@"distance_cost"] floatValue];
    float Dist=[[pastDict valueForKey:@"distance"]floatValue];
    if ([[pastDict valueForKey:@"unit"]isEqualToString:@"kms"])
    {
        totalDist=totalDist*0.621317;
        Dist=Dist*0.621371;
    }
    
    if(Dist!=0)
    {
        //self.lblPerDist.text=[NSString stringWithFormat:@"%.2f$ per Miles",(totalDist/Dist)];
    }
    else
    {
       // self.lblPerDist.text=@"0$ per Miles";
    }
    
    float totalTime=[[pastDict valueForKey:@"time_cost"] floatValue];
    float Time=[[pastDict valueForKey:@"time"]floatValue];
    if(Time!=0)
    {
       // self.lblPerTime.text=[NSString stringWithFormat:@"%.2f$ per Mins",(totalTime/Time)];
    }
    else
    {
       // self.lblPerTime.text=@"0$ per Mins";
    }
        arrTypes=[pastDict valueForKey:@"type"];
        self.tblPrize.tag=100;
        self.tableView.tag=0;
        [self.tblPrize reloadData];
    
    
    
    [UIView animateWithDuration:0.5 animations:^{
        self.viewForBill.hidden=NO;
    } completion:^(BOOL finished)
     {
     }];
    }
}
#pragma mark -
#pragma mark - Custom Methods

-(void)getHistory
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
       NSString * strForUserId=[pref objectForKey:PREF_USER_ID];
       NSString * strForUserToken=[pref objectForKey:PREF_USER_TOKEN];
        
        
        NSMutableString *pageUrl=[NSMutableString stringWithFormat:@"%@?%@=%@&%@=%@",FILE_HISTORY,PARAM_ID,strForUserId,PARAM_TOKEN,strForUserToken];
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
                     
                     arrHistory=[response valueForKey:@"requests"];
                     NSLog(@"History count = %lu",(unsigned long)arrHistory.count);
                     if (arrHistory.count==0 || arrHistory==nil)
                     {
                         self.tableView.hidden=YES;
                        // self.lblnoHistory.hidden=NO;
                         self.imgNoDisplay.hidden=NO;
                     }
                     else
                     {
                         self.tableView.hidden=NO;
                         //self.lblnoHistory.hidden=YES;
                         self.imgNoDisplay.hidden=YES;
                         [self makeSection];
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
        
- (IBAction)closeBtnPressed:(id)sender
{
     self.navigationController.navigationBarHidden=NO;
    self.tblPrize.tag=2;
    self.tableView.tag=0;
    

   
    [UIView animateWithDuration:0.5 animations:^{
        self.viewForBill.hidden=YES;
    } completion:^(BOOL finished)
     {
     }];
}

@end
