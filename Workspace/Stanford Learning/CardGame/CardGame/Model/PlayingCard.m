//
//  PlayingCard.m
//  CardGame
//
//  Created by mayur on 1/1/15.
//  Copyright (c) 2015 user. All rights reserved.
//

#import "PlayingCard.h"

@implementation PlayingCard

-(NSString *)contents
{
    NSArray *rankArr = [PlayingCard rankStrings];
    return [rankArr[self.rank] stringByAppendingString:self.suit];
}


@synthesize suit = _suit;

+(NSArray *)validSuits
{
    return @[@"♠️", @"♥️", @"♣️", @"♦️"];
}

-(void)setSuit:(NSString *)suit
{
    if([[PlayingCard validSuits] containsObject:suit])
        _suit = suit;
}

-(NSString *)suit
{
    _suit = (_suit) ? _suit : @"?";
    return _suit;
}

+(NSArray *)rankStrings
{
    return @[@"?",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"J",@"Q",@"K"];
}

+(NSUInteger)maxRank
{
    return [[PlayingCard rankStrings] count] - 1;
}

-(void)setRank:(NSUInteger)rank
{
    if(rank <= [PlayingCard maxRank]){
        _rank = rank;
    }
}

@end
