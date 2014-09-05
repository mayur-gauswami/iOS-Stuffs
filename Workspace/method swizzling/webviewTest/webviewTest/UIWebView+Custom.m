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

@implementation UIWebView (Custom)

+ (void)load
{
    
    Method original, swizzle;
    
    original = class_getInstanceMethod(self, @selector(webViewDidStartLoad:));
    swizzle  = class_getInstanceMethod(self, @selector(swizzled_webViewDidStartLoad:));
    
    /*BOOL methodAdded = class_addMethod([self class],
                                       @selector(webViewDidStartLoad:),
                                       method_getImplementation(swizzle),
                                       method_getTypeEncoding(swizzle));
    
    if (methodAdded) {
        class_replaceMethod([self class],
                            @selector(swizzled_webViewDidStartLoad:),
                            method_getImplementation(original),
                            method_getTypeEncoding(original));
    } else {
        method_exchangeImplementations(original, swizzle);
    }
    
    
    
    original = class_getInstanceMethod(self, @selector(loadHTMLString:baseURL:));
    swizzle  = class_getInstanceMethod(self, @selector(swizzled_loadHTMLString:baseURL:));
    method_exchangeImplementations(original, swizzle);*/

    
    /* Using JR_Swizzle */
    NSError *err;
    [self jr_swizzleMethod:@selector(swizzled_webViewDidStartLoad:) withMethod:@selector(webViewDidStartLoad:) error:&err];
    if(err)
        NSLog(@"ERROR: %@", err);
    //[self jr_swizzleClassMethod:@selector(swizzled_webViewDidStartLoad:) withClassMethod:@selector(webViewDidStartLoad:) error:NULL];
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
