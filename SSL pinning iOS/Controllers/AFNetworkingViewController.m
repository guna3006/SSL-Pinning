//
//  AFNetworkingViewController.m
//  SSL pinning iOS
//
//  Created by Adis on 12/06/15.
//  Copyright (c) 2015 Infinum Ltd. All rights reserved.
//

#import "AFNetworkingViewController.h"

#import <AFNetworking/AFNetworking.h>

@interface AFNetworkingViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *urlField;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UITextView *dataTextView;

@end

@implementation AFNetworkingViewController

#pragma mark - Networking

- (IBAction)fetchData:(id)sender
{
    self.dataTextView.text = @"";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey];
    manager.securityPolicy = policy;

    // old cert
    NSString *pathToCert1 = [[NSBundle mainBundle]pathForResource:@"www.pbdirectaia.com.my_old" ofType:@"cer"];
    NSData *localCertificate1 = [NSData dataWithContentsOfFile:pathToCert1];

    
    // new cert
    NSString *pathToCert2 = [[NSBundle mainBundle]pathForResource:@"www.pbdirectaia.com.my_new" ofType:@"cer"];
    NSData *localCertificate2 = [NSData dataWithContentsOfFile:pathToCert2];
    
    // concatenate cert
    NSString *pathToCert3 = [[NSBundle mainBundle]pathForResource:@"www.pbdirectaia.com.my" ofType:@"cer"];
    NSData *localCertificate3 = [NSData dataWithContentsOfFile:pathToCert3];
    
    
    
    manager.securityPolicy.pinnedCertificates = @[localCertificate3];
    
    
    
    
    [self.activityIndicator startAnimating];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:self.urlField.text parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.activityIndicator stopAnimating];
        NSLog(@"Response: %@", responseObject);
        
        self.dataTextView.text = operation.responseString;
        self.dataTextView.textColor = [UIColor darkTextColor];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.activityIndicator stopAnimating];
        NSLog(@"Error: %@", error);
        
        self.dataTextView.text = error.localizedDescription;
        self.dataTextView.textColor = [UIColor redColor];
    }];
}

#pragma mark - Textfield delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.urlField resignFirstResponder];
    return YES;
}

@end
