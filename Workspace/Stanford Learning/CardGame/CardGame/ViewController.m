//
//  ViewController.m
//  CardGame
//
//  Created by mayur on 1/1/15.
//  Copyright (c) 2015 user. All rights reserved.
//

#import "ViewController.h"
#import "PlayingCardDeck.h"

@interface ViewController ()
@property (strong, nonatomic) Deck *deck;
@end

@implementation ViewController

- (Deck *)deck
{
    if(!_deck) _deck = [self createDeck];
    return _deck;
}

- (Deck *)createDeck
{
    return [[PlayingCardDeck alloc] init];
}

- (IBAction)touchCardButton:(UIButton *)sender {
    
    if(![sender.currentTitle length]){
        Card *card = [self.deck drawRandomCard];
        UIImage *img = [UIImage imageNamed:@"cardfront"];
        [sender setBackgroundImage:img forState:UIControlStateNormal];
        [sender setTitle:card.contents forState:UIControlStateNormal];
    }
    else{
        UIImage *img = [UIImage imageNamed:@"cardback"];
        [sender setBackgroundImage:img forState:UIControlStateNormal];
        [sender setTitle:@"" forState:UIControlStateNormal];
    }
    
}


@end
