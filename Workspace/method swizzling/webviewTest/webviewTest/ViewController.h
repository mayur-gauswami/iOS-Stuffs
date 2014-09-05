//
//  ViewController.h
//  webviewTest
//
//  Created by Mayur Gosai on 24/04/14.
//  Copyright (c) 2014 Mayur Gosai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;
- (void)webViewDidFinishLoad:(UIWebView *)webView;
@end
