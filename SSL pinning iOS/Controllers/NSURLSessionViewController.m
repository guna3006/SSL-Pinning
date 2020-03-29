
#import "NSURLSessionViewController.h"

@interface NSURLSessionViewController () <NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSURLSession *urlSession;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation NSURLSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    self.urlSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
}

- (IBAction)loadDataHandler:(id)sender {
    [self.activityIndicator startAnimating];

    [[self.urlSession dataTaskWithURL:[NSURL URLWithString:self.textField.text] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator stopAnimating];
            if (!error) {
                self.textView.text = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
                self.textView.textColor = [UIColor blackColor];
            } else {
                self.textView.text = error.description;
                self.textView.textColor = [UIColor redColor];
            }
        });
    }] resume];
}

#pragma mark - NSURLSession delegate

-(void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    
    // Get remote certificate
    SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
    SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, 0);
    
    // Set SSL policies for domain name check
    NSMutableArray *policies = [NSMutableArray array];
    [policies addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)challenge.protectionSpace.host)];
    SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);
    
    // Evaluate server certificate
    SecTrustResultType result;
    SecTrustEvaluate(serverTrust, &result);
    BOOL certificateIsValid = (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);
    
    // Get local and remote cert data
    NSData *remoteCertificateData = CFBridgingRelease(SecCertificateCopyData(certificate));
    
    // old cert
    NSString *pathToCert1 = [[NSBundle mainBundle]pathForResource:@"www.pbdirectaia.com.my_old" ofType:@"cer"];
    
    // new cert
    NSString *pathToCert2 = [[NSBundle mainBundle]pathForResource:@"www.pbdirectaia.com.my_new" ofType:@"cer"];
    
    // concatenate cert
    NSString *pathToCert3 = [[NSBundle mainBundle]pathForResource:@"www.pbdirectaia.com.my" ofType:@"cer"];
    
    
    NSData *localCertificate1 = [NSData dataWithContentsOfFile:pathToCert1];
    NSData *localCertificate2 = [NSData dataWithContentsOfFile:pathToCert2];
    NSData *localCertificate3 = [NSData dataWithContentsOfFile:pathToCert3];
    
    // The pinnning check
    if ([remoteCertificateData isEqualToData:localCertificate3] && certificateIsValid) {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    }
    //else if ([remoteCertificateData isEqualToData:localCertificate1] && certificateIsValid){
    //NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
    //       completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    //}
    else{
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, NULL);
    }
}

@end
