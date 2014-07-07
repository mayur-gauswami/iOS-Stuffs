//
//  UIWebView+Custom.m
//  webviewTest
//
//  Created by Mayur Gosai on 01/07/14.
//  Copyright (c) 2014 Mayur Gosai. All rights reserved.
//

#import "UIWebView+Custom.h"
#import <objc/objc-runtime.h>
#import "JRSwizzle.h"
#import "ViewController.h"

@implementation UIWebView (UIWebViewDelegate)

+ (void)load
{
    Method original, swizzle;
    
    original = class_getInstanceMethod([UIWebView class], @selector(setDelegate:));
    swizzle  = class_getInstanceMethod(self, @selector(swizzled_setDelegate:));
    
    method_exchangeImplementations(original, swizzle);
    
    /*BOOL methodAdded = class_addMethod([UIWebView class],
                                       @selector(webViewDidStartLoad:),
                                       method_getImplementation(swizzle),
                                       method_getTypeEncoding(swizzle));
    
    if (!methodAdded) {
        class_replaceMethod([self class],
                            @selector(swizzled_webViewDidStartLoad:),
                            method_getImplementation(original),
                            method_getTypeEncoding(original));
    } else {
        method_exchangeImplementations(original, swizzle);
    }*/
    
    
    
    /*original = class_getInstanceMethod(self, @selector(loadHTMLString:baseURL:));
    swizzle  = class_getInstanceMethod(self, @selector(swizzled_loadHTMLString:baseURL:));
    method_exchangeImplementations(original, swizzle);*/
    /*NSError *err;
    [self jr_swizzleMethod:@selector(swizzled_webViewDidStartLoad:) withMethod:@selector(webViewDidStartLoad:) error:&err];
    if(err)
        NSLog(@"ERROR: %@", err);*/
    //[self jr_swizzleClassMethod:@selector(swizzled_webViewDidStartLoad:) withClassMethod:@selector(webViewDidStartLoad:) error:NULL];
}

- (id) webViewDelegate {
    return objc_getAssociatedObject(self, @selector(webViewDelegate));
}

- (void)setWebViewDelegate: (id) delegate {
    objc_setAssociatedObject(self, @selector(webViewDelegate), delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)swizzled_setDelegate: (id)delegate
{
    self.webViewDelegate = delegate;
    
    Method original = class_getInstanceMethod([delegate class], @selector(webViewDidFinishLoad:));
    Method swizzle = class_getInstanceMethod([self class], @selector(swizzled_webViewDidFinishLoad:));
    if(original)
        method_exchangeImplementations(original, swizzle);
    
    [self swizzled_setDelegate:delegate];
    
    NSLog(@"method swizzled_setDelegate...");
}


- (void)swizzled_webViewDidFinishLoad:(UIWebView *)webView
{
    [self.webViewDelegate webViewDidFinishLoad:webView];
    NSLog(@"method swizzled_webViewDidStartLoad......");
}

- (void)swizzled_webViewDidStartLoad:(UIWebView *)webView
{
    [self swizzled_webViewDidStartLoad:webView];
    NSLog(@"method swizzled_webViewDidStartLoad......");
}

- (void)swizzled_loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    [self swizzled_loadHTMLString:string baseURL:baseURL];
    NSLog(@"method swizzled_loadHTMLString......");
}

@end
