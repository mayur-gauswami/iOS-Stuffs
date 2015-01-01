//
//  Card.h
//  CardGame
//
//  Created by mayur on 1/1/15.
//  Copyright (c) 2015 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Card : NSObject

@property (strong, nonatomic) NSString *contents;

@property (nonatomic, getter=isChoosen) BOOL choosen;
@property (nonatomic, getter=isMatched) BOOL matched;

-(int)match:(NSArray *)otherCards;

@end
