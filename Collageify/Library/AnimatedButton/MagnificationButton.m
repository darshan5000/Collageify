//
//  MagnificationButton.h
//  Photo Collage Maker
//
//  Created by Grapes Infosoft on 14/09/19.
//  Copyright © 2019 Grapes Infosoft. All rights reserved.
//

#import "MagnificationButton.h"

#define magnificationDuration 0.1

@implementation MagnificationButton

-(void)magnifyOnPress:(BOOL)animate{
    if(animate){
        [self addTarget:self action:@selector(magnifyAnimation) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(unmagnifyAnimation) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)magnifyAnimation{
    [UIView animateWithDuration:magnificationDuration animations:^{
        self.transform = CGAffineTransformMakeScale(1.15, 1.15);
    }];
}

-(void)unmagnifyAnimation{
    [UIView animateWithDuration:magnificationDuration animations:^{
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
