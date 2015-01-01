//
//  Deck.h
//  CardGame
//
//  Created by mayur on 1/1/15.
//  Copyright (c) 2015 user. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

@interface Deck : NSObject

-(void)addCard:(Card *)card atTop:(BOOL)atTop;
-(void)addCard:(Card *)card;

-(Card *)drawRandomCard;

@end
