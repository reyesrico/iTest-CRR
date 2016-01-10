//
//  ViewController.h
//  iTest
//
//  Created by Carlos Reyes on 08/01/16.
//  Copyright © 2016 CR. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *wordEntered;
@property (weak, nonatomic) IBOutlet UIButton *findBtn;
@property (weak, nonatomic) IBOutlet UILabel *meaningsTitleLbl;
@property (weak, nonatomic) IBOutlet UITextView *meaningsTxt;

-(void) getData;
-(void) getReachibility;


@end

