//
//  SelectServiceVC.m
//  TaxiNow Driver
//
//  Created by My Mac on 3/23/15.
//  Copyright (c) 2015 Deep Gami. All rights reserved.
//

#import "SelectServiceVC.h"
#import "SelectServiceCell.h"

@interface SelectServiceVC ()
{
    NSMutableArray *arr;
    NSMutableArray *arrType;
    NSMutableArray *arrPricet;
    
    NSMutableArray *arrWtype;
    NSMutableArray *arrWtypePrice;
 }
@end

@implementation SelectServiceVC

- (void)viewDidLoad
{
    [super viewDidLoad];
     [super setBackBarItem];
    arr=[[NSMutableArray alloc] initWithObjects:@"one",@"two",@"three", nil];
    arrWtype=[[NSMutableArray alloc]init];
    arrWtypePrice=[[NSMutableArray alloc]init];
    arrPricet=[[NSMutableArray alloc]init];
    NSLog(@"register details :%@",self.dictparam);
    NSLog(@"image  :%@",self.imgP);
    [APPDELEGATE hideLoadingView];
    [self getType];
    
    NSLog(@"log :%@",arrType);    
}

-(void)viewWillAppear:(BOOL)animated
{
    arrType=[[NSMutableArray alloc]init];
    [self getType];
    
}
-(void)getType
{
    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:FILE_WALKER_TYPE withParamData:nil withBlock:^(id response, NSError *error)
         {
                          if (response) {
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     [[AppDelegate sharedAppDelegate]hideHUDLoadingView];
                     arrType=[response valueForKey:@"types"];
                     NSLog(@"arr :%@",arrType);
                     [self.tblselectService reloadData];
                     NSLog(@"Check %@",response);

                 }
             }
             
         }];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if([textField.text isEqualToString:@""])
    {
        UITextField *txtf=(UITextField *)textField;
        
        NSIndexPath *path = [NSIndexPath indexPathForRow:txtf.tag inSection:0];
        SelectServiceCell *cell1=[self.tblselectService cellForRowAtIndexPath:path];
        
        NSDictionary *dictType=[arrType objectAtIndex:txtf.tag];
        NSString *strTypeId=[NSMutableString stringWithFormat:@"%@",[dictType valueForKey:@"id"]];
  
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"note" message:@"enter price !" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        [arrPricet removeObject:cell1.txtprice.text];
        
        [arrWtype removeObject:strTypeId];
        
    }else{
        UITextField *txtf=(UITextField *)textField;
        NSIndexPath *path = [NSIndexPath indexPathForRow:txtf.tag inSection:0];
        SelectServiceCell *cell=[self.tblselectService cellForRowAtIndexPath:path];
        
        NSDictionary *dictType=[arrType objectAtIndex:txtf.tag];
        NSString *strTypeId=[NSMutableString stringWithFormat:@"%@",[dictType valueForKey:@"id"]];
        
        [arrWtype addObject:strTypeId];
       
        NSLog(@"index  :%ld",(long)txtf.tag);
        [arrPricet addObject:cell.txtprice.text];
        NSLog(@"log :%@",arrPricet);
        
    }
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
     [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    /*UITextField *txtf=(UITextField *)textField;
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:txtf.tag inSection:0];
    SelectServiceCell *cell=[self.tblselectService cellForRowAtIndexPath:path];
    
    if([textField isEqual:cell.txtprice]){
        NSLog(@"index  :%ld",(long)txtf.tag);
        [arrPricet addObject:cell.txtprice.text];
    }*/
    
   
    
    return YES;
    
}
#pragma mark tableview 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrType.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict=[arrType objectAtIndex:indexPath.row];
    
    SelectServiceCell *cell=(SelectServiceCell *)[tableView dequeueReusableCellWithIdentifier:@"PriceCell"];
    cell.lbltitle.text=[dict valueForKey:@"name"];
   // [cell.btnPrice setTitle:[NSString stringWithFormat:@
                           //  "$%@",[dict valueForKey:@"price_per_unit_distance"]] forState:UIControlStateNormal];
   
   // [cell.btnPrice addTarget:self action:@selector(btnCommentClick:) forControlEvents:UIControlEventTouchUpInside];
  //  cell.btnPrice.tag=indexPath.row;
    cell.txtprice.tag=indexPath.row;
    cell.txtprice.enabled=NO;
    cell.txtdoller.hidden=YES;
    
    
    
    return cell;
    
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
   SelectServiceCell *Cell=(SelectServiceCell *)[self.tblselectService cellForRowAtIndexPath:indexPath];
    if([Cell.imgCheck.image isEqual:[UIImage imageNamed:@"btn_uncheck"]]){
        Cell.imgCheck.image=[UIImage imageNamed:@"btn_check"];
         Cell.txtprice.background=[UIImage imageNamed:@"bg_price"];
        Cell.txtprice.enabled=YES;
        [Cell.txtprice becomeFirstResponder];
        
        
        NSDictionary *dictType=[arrType objectAtIndex:indexPath.row];
        NSString *strTypeId=[NSMutableString stringWithFormat:@"%@",[dictType valueForKey:@"id"]];
        NSString *StrPrice=[dictType valueForKey:@"price_per_unit_distance"];
      //  [arrWtype addObject:strTypeId];
        Cell.txtdoller.hidden=NO;
        
        //[arrWtypePrice addObject:StrPrice];
        
    }
    else{
        
         Cell.imgCheck.image=[UIImage imageNamed:@"btn_uncheck"];
        Cell.imgs.image=[UIImage imageNamed:@"bg_price_g"];
        Cell.txtprice.enabled=NO;
        Cell.txtdoller.hidden=YES;
        
        Cell.txtprice.background=[UIImage imageNamed:@"bg_price_g"];
        NSDictionary *dictType=[arrType objectAtIndex:indexPath.row];
        NSString *strTypeId=[dictType valueForKey:@"id"];
        NSString *StrPrice=[dictType valueForKey:@"price_per_unit_distance"];
        NSLog(@"dict deselect  :%@",strTypeId);
     
        [arrPricet removeObject:Cell.txtprice.text];
        //NSString *Str=Cell.txtprice.text;
        //[arrPricet removeObject:Str];
        
        [arrWtype removeObject:strTypeId];
       // [arrWtypePrice removeObject:StrPrice];
        Cell.txtprice.text=@"";
       
    }
    
    
    /*
    if([Cell.imgCheck.image isEqual:[UIImage imageNamed:@"btn_uncheck"]])
    {
        Cell.imgCheck.image=[UIImage imageNamed:@"btn_check"];
      //  [Cell.btnPrice setBackgroundImage:[UIImage imageNamed:@"bg_price"] forState:UIControlStateNormal];
        Cell.txtprice.enabled=YES;
        
        Cell.imgs.image=[UIImage imageNamed:@"bg_price"];
        
        Cell.txtprice.background=[UIImage imageNamed:@"bg_price"];
    
        NSDictionary *dictType=[arrType objectAtIndex:indexPath.row];
        //txtType.text=[dictType valueForKey:@"name"];;
        NSString *strTypeId=[NSMutableString stringWithFormat:@"%@",[dictType valueForKey:@"id"]];
        NSString *StrPrice=[dictType valueForKey:@"price_per_unit_distance"];
        
        int val=[Cell.txtprice.text intValue];
        if(val<=0 || [Cell.txtprice.text isEqualToString:@""])
        {
            Cell.imgCheck.image=[UIImage imageNamed:@"btn_uncheck"];
            UIAlertView  *alert=[[UIAlertView alloc]initWithTitle:@"Note" message:@"Enter valid Price" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
            [arrWtype removeObject:strTypeId];
            [arrPricet removeObject:Cell.txtprice.text];
            Cell.txtprice.background=[UIImage imageNamed:@"bg_price_g"];
            
            
      }
        else{
            [arrWtype addObject:strTypeId];
        }
        //[imgType downloadFromURL:[dictType valueForKey:@"icon"] withPlaceholder:nil];
       // [self.tblselectService reloadData];
        NSLog(@"dict select :%@",strTypeId);
        
        [arrWtypePrice addObject:StrPrice];
        //[arrPricet addObject:StrPrice];
        //[Cell.txtprice resignFirstResponder];
      
    }
    else{
        Cell.imgCheck.image=[UIImage imageNamed:@"btn_uncheck"];
     //   [Cell.btnPrice setBackgroundImage:[UIImage imageNamed:@"bg_price_g"] forState:UIControlStateNormal];
         NSDictionary *dictType=[arrType objectAtIndex:indexPath.row];
        Cell.imgs.image=[UIImage imageNamed:@"bg_price_g"];
        Cell.txtprice.background=[UIImage imageNamed:@"bg_price_g"];
        
        NSString *strTypeId=[dictType valueForKey:@"id"];
        NSString *StrPrice=[dictType valueForKey:@"price_per_unit_distance"];
        NSLog(@"dict deselect  :%@",strTypeId);
        
        NSString *Str=Cell.txtprice.text;
        [arrPricet removeObject:Str];

        [arrWtype removeObject:strTypeId];
        [arrWtypePrice removeObject:StrPrice];
        Cell.txtprice.text=@"";
        Cell.txtprice.enabled=NO;
      
    }*/
    
    [self.tblselectService deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(void)btnCommentClick:(id)sender
{
     UIButton *senderButton = (UIButton *)sender;
     NSIndexPath *path = [NSIndexPath indexPathForRow:senderButton.tag inSection:0];
     SelectServiceCell *cell=[self.tblselectService cellForRowAtIndexPath:path];
    
    
       NSLog(@"text :%@",cell.lbltitle.text);
    
                   // cell.btnPrice.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_price"]];
    
            
    
    //[self.tblselectService reloadData];
    
       /*
     UIButton *senderButton = (UIButton *)sender;
     
     NSLog(@"current Row=%ld",(long)senderButton.tag);
     // NSIndexPath *path = [NSIndexPath indexPathForRow:senderButton.tag inSection:0];
     NSLog(@" sdsd %@" ,senderButton.titleLabel.text);
     */
    
}


- (void)didReceiveMemoryWarning {
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

- (IBAction)onClickforRegister:(id)sender
{
    if(arrWtype.count==0)
    {
        [arrWtype addObject:@"1"];
    }
    if(arrWtypePrice.count==0)
    {
        [arrWtypePrice addObject:@"10"];
    }

   // NSString *joinedString = [arrWtype componentsJoinedByString:@","];
   // NSString *joinedString1 = [arrWtypePrice componentsJoinedByString:@","];
   //  NSString *joinedStringprice = [arrPricet componentsJoinedByString:@","];
    
    [APPDELEGATE showLoadingWithTitle:@"Loading..."];
    
    NSLog(@" final dict :%@",self.dictparam);
    NSLog(@" final imgae :%@",self.imgP);
    
    for(int i=0;i<arrPricet.count;i++)
    {
        NSString *Str=[arrPricet objectAtIndex:i];
        int val=[[arrPricet objectAtIndex:i] intValue];
        if(val<=0 || [Str isEqualToString:@""])
        {
            [arrPricet removeObject:[arrPricet objectAtIndex:i]];
            
        }
    }
    
    NSString *joinedStringprice11 = [arrPricet componentsJoinedByString:@","];
    NSString *joinedStringprice12 = [arrWtype componentsJoinedByString:@","];
   
    NSLog(@"price2   :%@",joinedStringprice11);
    NSLog(@"type    :%@",joinedStringprice12);
    
    
    [self.dictparam setValue:joinedStringprice12 forKey:PARAM_WALKER_TYPE];
    [self.dictparam setValue:joinedStringprice11 forKey:PARAM_WALKER_PRICE];

    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
    [afn getDataFromPath:FILE_REGISTER withParamDataImage:self.dictparam andImage:self.imgP withBlock:^(id response, NSError *error)
     {
         [APPDELEGATE hideLoadingView];
         if (response)
         {
             if([[response valueForKey:@"success"] intValue]==1)
             {
                 [APPDELEGATE showToastMessage:(NSLocalizedString(@"REGISTER_SUCCESS", nil))];
                 //arrUser=response;
                 NSLog(@"res :%@",response);
                 [self.navigationController popToRootViewControllerAnimated:YES];
             }
             else
             {
                 UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:[response valueForKey:@"error"] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                 [alert show];
             }
         }
         NSLog(@"REGISTER RESPONSE --> %@",response);
     }];
}

@end