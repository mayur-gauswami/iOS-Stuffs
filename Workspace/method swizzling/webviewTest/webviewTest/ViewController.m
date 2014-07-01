//
//  ViewController.m
//  webviewTest
//
//  Created by Mayur Gosai on 24/04/14.
//  Copyright (c) 2014 Mayur Gosai. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
//    NSString *fullUrl = @"http://google.com";
//    NSURL *url = [NSURL URLWithString:fullUrl];
//    NSURLRequest *req = [NSURLRequest requestWithURL:url];
//    [self.webView loadRequest:req];
    self.webView.delegate = self;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSString *html = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:html baseURL:[[NSBundle mainBundle] bundleURL]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSString *result = [self.webView stringByEvaluatingJavaScriptFromString:@"document.onclick = function(e) { window.location = 'my-protocol:'+e.target; }"];
    NSLog(@"result : %@", result);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"got request : %@", [request URL]);
    return true;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
