//
//  EMKJavascriptEvaluation.h
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

#import <Foundation/Foundation.h>



extern NSString *const EMKJavascriptEvaluationComplete;




typedef enum _EMKEvaluationReadyState
{
    EMKEvaluationStateDOMReady,
    EMKEvaluationStateDOMLoaded,
    EMKEvaluationStateWebViewLoaded
} EMKEvaluationReadyState;




@interface EMKJavascriptEvaluation : NSObject
{
    NSURL *url;
    NSString *html;
    NSString *script;

    NSMutableArray *libraryPaths;    
    
    EMKEvaluationReadyState readyState;
    
    NSString *result;    
}


+(EMKJavascriptEvaluation*)evaluateScript:(NSString*)script withHtml:(NSString*)html;
+(EMKJavascriptEvaluation*)evaluateScript:(NSString*)script withHtmlAtURL:(NSURL*)url;


@property(readwrite, copy) NSURL *url;
@property(readwrite, copy) NSString *html;
@property(readwrite, copy) NSString *script;
@property(readwrite, assign) EMKEvaluationReadyState readyState;  //default: ready

@property(readonly) NSArray *libraryPaths;
@property(readonly) NSString *result;

-(void)injectLibraryAtPath:(NSString*)libraryPath;

-(void)evaluate;

@end