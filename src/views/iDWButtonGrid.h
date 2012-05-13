//
//  iDWButtonGrid.h
//  iDreamwidth
//
//  Created by Andrea Nall on 5/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iDWButtonGrid : UIView {
    CGFloat labelSpacing;
    CGSize buttonSize;
}

@property (assign,nonatomic) CGFloat labelSpacing;
@property (assign,nonatomic) CGSize buttonSize;

@end
