//
//  EMKJavascriptEvaluation.m
//
//  Created by Benedict Cohen on 23/08/2010.
//  Copyright 2010 Benedict Cohen. All rights reserved.
//

/*
 Copyright (c) 2010 Benedict Cohen, ben@benedictcohen.co.uk
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "EMKJavascriptEvaluation.h"

#define LOG_METHOD NSLog(@"%s", __FUNCTION__);


NSString * const EMKJavascriptEvaluationComplete = @"EMKJavascriptEvaluationComplete";


@interface EMKJavascriptEvaluation (EMKJavascriptEvaluatorCallback)

-(void)setResultOfEvaluation;

@end





@interface EMKJavascriptEvaluator : NSObject <UIWebViewDelegate>
{
    UIWebView *webview;
    NSMutableArray *pendingEvaluations;
    
    EMKJavascriptEvaluation *currentEvaluation;    
    
    BOOL didPlantReadyScript;
}


+(EMKJavascriptEvaluator*)sharedEvaluator;

@property(readwrite, retain) EMKJavascriptEvaluation *currentEvaluation;

-(void)enqueueEvaluation:(EMKJavascriptEvaluation*)evaluation;
-(void)popEvaluation;
-(void)pollDocumentReadyState;
-(void)documentReady;    

-(void)loadHTMLFromURL:(NSURL*)url;
-(void)loadHTMLFromString:(NSString*)html;

@end




NSString* const EMKJavaScriptEvaluatorDomReadyScript = @"if (/loaded|complete/.test(document.readyState)){document.UIWebViewDocumentIsReady = true;} else {document.addEventListener('DOMContentLoaded', function(){document.UIWebViewDocumentIsReady = true;}, false);}";
NSString* const EMKJavaScriptEvaluatorDomLoadScript  = @"if (/loaded|complete/.test(document.readyState)){document.UIWebViewDocumentIsReady = true;} else {window.addEventListener('load',               function(){document.UIWebViewDocumentIsReady = true;}, false);}";
NSString* const EMKJavaScriptEvaluatorReadyStateCheckScript  = @"document.UIWebViewDocumentIsReady;";







@implementation EMKJavascriptEvaluation

+(EMKJavascriptEvaluation*)evaluateScript:(NSString*)script withHtml:(NSString*)html
{
    EMKJavascriptEvaluation *evaluation = [[EMKJavascriptEvaluation new] autorelease];
    
    evaluation.script = script;
    evaluation.html = html;

    return evaluation;
}




+(EMKJavascriptEvaluation*)evaluateScript:(NSString*)script withHtmlAtURL:(NSURL*)url
{
    EMKJavascriptEvaluation *evaluation = [[EMKJavascriptEvaluation new] autorelease];
    
    evaluation.script = script;
    evaluation.url = url;
    
    return evaluation;
}


-(id)init
{
    self = [super init];
    
    if (self)
    {

    }
    
    return self;
}


-(void)dealloc
{
    [url release],          url = nil;
    [html release],         html = nil;
    [script release],       script = nil;
    [libraryPaths release], libraryPaths = nil;
    [result release],       result = nil;
    
    [super dealloc];
}



@synthesize url;
@synthesize html;
@synthesize script;

@synthesize readyState;

@synthesize libraryPaths;
@synthesize result;



-(void)injectLibraryAtPath:(NSString *)libraryPath
{
    if (!libraryPath) return;
    
    if (!libraryPaths)
    {
        libraryPaths = [NSMutableArray new];
    }

    
    [libraryPaths addObject:libraryPath];
}



-(void)evaluate
{
    [[EMKJavascriptEvaluator sharedEvaluator] enqueueEvaluation:self];
}




-(void)setResultOfEvaluation:(NSString*)evalResult
{
    result = [evalResult copy];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EMKJavascriptEvaluationComplete object:self];
}




@end














@implementation EMKJavascriptEvaluator


static EMKJavascriptEvaluator *sharedEvaluator = nil;



-(id)init
{
    self = [super init];
    
    if (self)
    {
        
    }
    
    return self;
}


@synthesize currentEvaluation;




-(void)enqueueEvaluation:(EMKJavascriptEvaluation*)evaluation
{
    if (!pendingEvaluations)
    {
        pendingEvaluations = [[NSMutableArray arrayWithCapacity:10] retain];
    }
    
    [pendingEvaluations addObject:evaluation];
    
    [self popEvaluation];
}





-(void)popEvaluation
{
    if (self.currentEvaluation) return;

    
    if ([pendingEvaluations count] == 0) 
    {
        [webview release];
        webview = nil;
        return;
    }
    
    
    if (!webview) 
    {
        webview = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
        webview.delegate = self;
    }
    
    
    self.currentEvaluation = [pendingEvaluations objectAtIndex:0];
    [pendingEvaluations removeObjectAtIndex:0];
    
    
    didPlantReadyScript = NO;    
    
    NSString *html = self.currentEvaluation.html;

    if (html)
    {
        [self loadHTMLFromString:html];
    } else
    {
        [self loadHTMLFromURL:self.currentEvaluation.url];
    }
}





-(void)loadHTMLFromURL:(NSURL*)url
{
    if ([NSThread isMainThread])
    {
        [self performSelectorInBackground:@selector(loadHTMLFromURL:) withObject:url];
        return;
    }
    
    [NSAutoreleasePool new]; 
    
    NSStringEncoding encoding = 0;
    NSError *err = nil;
    NSString *html = [NSString stringWithContentsOfURL:url usedEncoding:&encoding error:&err];
    
    if (err)
    {
        [self.currentEvaluation setResultOfEvaluation:nil];
        self.currentEvaluation = nil;
        
        [self performSelectorOnMainThread:@selector(popEvaluation) withObject:nil waitUntilDone:NO];
        return;
    }

    [self performSelectorOnMainThread:@selector(loadHTMLFromString:) withObject:html waitUntilDone:NO];
}






-(void)loadHTMLFromString:(NSString*)html
{
    [webview loadHTMLString:html baseURL:nil]; 
}





-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (didPlantReadyScript) return;

    

    for (NSString* libraryPath in self.currentEvaluation.libraryPaths)
    {
        NSStringEncoding encoding = 0;
        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithContentsOfFile:libraryPath usedEncoding:&encoding error:NULL]];
    }
    
    
    
    
    didPlantReadyScript = YES;        

    switch (self.currentEvaluation.readyState)
    {
        case EMKEvaluationStateWebViewLoaded:
            [self documentReady];
            break;
            
        case EMKEvaluationStateDOMLoaded:                
            [webView stringByEvaluatingJavaScriptFromString:EMKJavaScriptEvaluatorDomLoadScript];                
            [self pollDocumentReadyState];
            break;
            
        case EMKEvaluationStateDOMReady:
        default:
            [webView stringByEvaluatingJavaScriptFromString:EMKJavaScriptEvaluatorDomReadyScript];                
            [self pollDocumentReadyState];                
            break;
    }
}



- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}




-(void)pollDocumentReadyState
{
    if ([@"true" caseInsensitiveCompare:[webview stringByEvaluatingJavaScriptFromString:EMKJavaScriptEvaluatorReadyStateCheckScript]] == NSOrderedSame)
    {
        [self documentReady];
    } else 
    {
        [self performSelector:@selector(pollDocumentReadyState) withObject:nil afterDelay:1];
    }
}






-(void)documentReady
{
    [self.currentEvaluation setResultOfEvaluation:[webview stringByEvaluatingJavaScriptFromString:self.currentEvaluation.script]];

    self.currentEvaluation = nil;
    
    [self popEvaluation];
}







#pragma mark Memory management

+ (EMKJavascriptEvaluator *)sharedEvaluator 
{ 
    @synchronized(self) 
    { 
        if (sharedEvaluator == nil) 
        { 
            sharedEvaluator = [[self alloc] init]; 
        } 
    } 

    return sharedEvaluator; 
} 



+ (id)allocWithZone:(NSZone *)zone 
{ 
    @synchronized(self) 
    { 
        if (sharedEvaluator == nil) 
        { 
            sharedEvaluator = [super allocWithZone:zone]; 
            return sharedEvaluator; 
        } 
    } 

    return nil; 
} 



- (id)copyWithZone:(NSZone *)zone 
{ 
   
    return self; 
} 

- (id)retain 
{ 
    return self; 
} 


- (NSUInteger)retainCount 
{ 
    return NSUIntegerMax; 
} 


- (void)release 
{ 
} 


- (id)autorelease 
{ 
    return self; 
}



@end