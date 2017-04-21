//
//  GLChatInputBaseView.h
//  66GoodLook
//
//  Created by Yanci on 17/4/20.
//  Copyright © 2017年 Yanci. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLChatInputAbleView.h"

@protocol GLChatInputBaseViewDataSource <NSObject>
@end

@protocol GLChatInputBaseViewDelegate <NSObject>
@end

/*!
 @class GLChatInputBaseView
 
 @brief The UIView class
 
 @discussion    基础输入视图
 
 @superclass SuperClass: UIView\n
 @classdesign    No special design is applied here.
 @coclass    None
 @helps It helps no other classes.
 @helper    No helper exists for this class.
 */
@interface GLChatInputBaseView : UIView
@property (nonatomic,weak)id<GLChatInputAbleViewDelegate> chatDelegate;
@end
