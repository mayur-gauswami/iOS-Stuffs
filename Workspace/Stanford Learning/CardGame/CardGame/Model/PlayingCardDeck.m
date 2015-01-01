//
//  PlayingCardDeck.m
//  CardGame
//
//  Created by mayur on 1/1/15.
//  Copyright (c) 2015 user. All rights reserved.
//

#import "PlayingCardDeck.h"
#import "PlayingCard.h"

@implementation PlayingCardDeck

-(instancetype)init
{
    self = [super init];
    
    if(self){
        for (NSString *suite in [PlayingCard validSuits]) {
            for (NSUInteger rank = 1; rank < [PlayingCard maxRank]; rank++) {
                PlayingCard *card = [[PlayingCard alloc] init];
                card.rank = rank;
                card.suit = suite;
                [self addCard:card];
            }
        }
    }
    
    return self;
}

@end
