//
//  AuthenticationViewController.m
//  TalkinToTheNet
//
//  Created by Elber Carneiro on 9/25/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.
//

#import "AuthenticationViewController.h"

@interface AuthenticationViewController ()
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation AuthenticationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView = [[UIWebView alloc]initWithFrame:[self.view bounds]];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    NSString *authenticateURLString = [NSString stringWithFormat:@"%@?client_id=%@&response_type=token&redirect_uri=%@", FOURSQUARE_AUTHENTICATE_URL, FOURSQUARE_CLIENT_ID, FOURSQUARE_REDIRECT_URI];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:authenticateURLString]];
    
    [self.webView loadRequest:request];
}

#pragma mark - UIWebViewDelegate methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if ([request.URL.scheme isEqualToString:@"ec-foursquare-login"]) {
        NSString *URLString = [[request URL] absoluteString];
        
        if ([URLString rangeOfString:[NSString stringWithFormat:@"%@=", ACCESS_TOKEN_KEY]].location != NSNotFound) {
            NSString *accessToken = [[URLString componentsSeparatedByString:@"="] lastObject];
            NSLog(@"From AuthenticationViewController - access token: %@", accessToken);
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:accessToken forKey:ACCESS_TOKEN_KEY];
            [defaults synchronize];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
    return YES;
}

@end
