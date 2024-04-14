//
//  PressButton.m
//  Photo Collage Maker
//
//  Created by Grapes Infosoft on 14/09/19.
//  Copyright © 2019 Grapes Infosoft. All rights reserved.
//

#import "PressButton.h"

#define pressDuration 0.1

@implementation PressButton

-(void)animateOnPress:(BOOL)animate{
    if(animate){
        [self addTarget:self action:@selector(pressAnimation) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(unpressAnimation) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(unpressAnimation) forControlEvents:UIControlEventTouchUpOutside];
    }
}

-(void)pressAnimation{
    [UIView animateWithDuration:pressDuration animations:^{
        self.transform = CGAffineTransformMakeScale(0.85, 0.85);
    }];
}

-(void)unpressAnimation{
    [UIView animateWithDuration:pressDuration animations:^{
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
}
    

-(void)setDefaultImageWithImageName:(NSString *)imageName{
    UIImage *image = [UIImage imageNamed:imageName];
    [self setImage:image forState:UIControlStateNormal];
}

-(void)setSelectedImageWithImageName:(NSString *)imageName andColor:(UIColor*)color{
    UIImage *image = [UIImage imageNamed:imageName];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setImage:image forState:UIControlStateSelected];
    [self setImage:image forState:UIControlStateHighlighted];
    self.tintColor = color;
}

@end
