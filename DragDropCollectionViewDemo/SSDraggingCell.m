//
//  SSDraggingCell.m
//  DragDropCollectionViewDemo
//
//  Created by Stevenson on 3/13/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "SSDraggingCell.h"

@implementation SSDraggingCell

-(UIImage *)getRasterizedImageCopy
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0f);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
