//
//  Card.m
//  CardGame
//
//  Created by mayur on 1/1/15.
//  Copyright (c) 2015 user. All rights reserved.
//

#import "Card.h"

@implementation Card

-(int)match:(NSArray *)otherCards
{
    int store = 0;
    
    for (Card *card in otherCards) {
        if([[card contents] isEqualToString:self.contents])
        {
            store = 1;
        }
    }
    
    return store;
}

@end
