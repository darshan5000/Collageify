//
//  PressButton.h
//  Photo Collage Maker
//
//  Created by Grapes Infosoft on 14/09/19.
//  Copyright © 2019 Grapes Infosoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PressButton : UIButton

-(void)animateOnPress:(BOOL)animate;
-(void)setDefaultImageWithImageName:(NSString *)imageName;
-(void)setSelectedImageWithImageName:(NSString *)imageName andColor:(UIColor*)color;

@end
