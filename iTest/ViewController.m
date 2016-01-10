//
//  ViewController.m
//  iTest
//
//  Created by Carlos Reyes on 08/01/16.
//  Copyright © 2016 CR. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "MBProgressHUD.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.meaningsTitleLbl.hidden = true;
    self.meaningsTxt.hidden = true;
    self.meaningsTxt.text = @"";

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    return YES;
}

- (void) getData{
    //Variables
    NSString *value = self.wordEntered.text;
    NSString *URLString = [NSString stringWithFormat:@"http://www.nactem.ac.uk/software/acromine/dictionary.py?sf=%@", value];
    NSURL *url = [NSURL URLWithString:URLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //Sessions and Serializers
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders = @{@"Content-Type"       : @"application/json"};
    
    //AFHTTPSessionManager uses AFJSONResponseSerializer for responses. gets JSON and transforms to NSArray - Foundation.
    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url sessionConfiguration:sessionConfiguration];
    
    
    [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET" URLString:URLString parameters:nil error:nil];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    
    //Allowing Invalid SSL Certificates
    sessionManager.securityPolicy.allowInvalidCertificates = YES; // not recommended for production
    
    //self.getReachibility;
    
    //Settubg MBProgressHUD
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Do something...
        NSURLSessionDataTask *dataTask = [sessionManager  dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error) {
                NSLog(@"Error: %@", error);
                self.meaningsTxt.text = [NSString stringWithFormat:@"Error: %@", error];
            } else {
                NSArray *wrapper = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                NSDictionary *dictionary = [wrapper objectAtIndex:0];
                
                NSMutableString *allText = [[NSMutableString alloc]init];
                
                NSString *first = [NSString stringWithFormat:@"sf: %@\r\n", dictionary[@"sf"]];
                [allText appendString:first];
                NSArray *lfsA = dictionary[@"lfs"];
                
                for (NSDictionary *lfs in lfsA) {
                    NSString *lfsString = [NSString stringWithFormat:@"\tlf: %@, freq: %@, since: %@ \r\n",
                                           lfs[@"lf"], lfs[@"freq"], lfs[@"since"]];
                    
                    [allText appendString:lfsString];
                    
                    NSArray *lfA = lfs[@"vars"];
                    for(NSDictionary *lf in lfA){
                        NSString *lfString = [NSString stringWithFormat:@"\t\tlf: %@, freq: %@, since: %@ \r\n",
                                              lf[@"lf"], lf[@"freq"], lf[@"since"]];
                        [allText appendString:lfString];
                    }
                }
                
                //NSLog(@"%@", allText);
                self.meaningsTxt.text = allText;
            }
        }];
        [dataTask resume];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
    
    
}

-(void) getReachibility{
    //Shared Network Reachability
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        self.meaningsTitleLbl.text = [NSString stringWithFormat:@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status)];
        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

-(IBAction) findBtnPressed{
    self.meaningsTitleLbl.hidden=false;
    self.meaningsTxt.hidden = false;
    self.getData;
}

@end
