//
//  Deck.m
//  CardGame
//
//  Created by mayur on 1/1/15.
//  Copyright (c) 2015 user. All rights reserved.
//

#import "Deck.h"

@interface Deck()

@property (strong, nonatomic) NSMutableArray *cards; // of cards

@end


@implementation Deck

-(NSMutableArray *)cards{
    if(!_cards) _cards = [[NSMutableArray alloc] init];
    return _cards;
}

-(void)addCard:(Card *)card atTop:(BOOL)atTop
{
    if(atTop){
        [self.cards insertObject:card atIndex:0];
    }
    else{
        [self.cards addObject:card];
    }
}

-(void)addCard:(Card *)card
{
    [self.cards addObject:card];
}

-(Card *)drawRandomCard
{
    Card *randomCard = nil;
    
    if([self.cards count]){
        unsigned idx = arc4random() % [self.cards count];
        randomCard = self.cards[idx];
        [self.cards removeObjectAtIndex:idx];
    }
    
    return randomCard;
}

@end
