//
//  BlogCategory.h
//  Skilld
//
//  Created by TianHang on 3/14/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BlogCategory : NSObject

@property (strong) NSString *strId;
@property (strong) NSString *strName;
@property (strong) BlogCategory *parent;
@property (assign) int nRowNum;
@property (assign) int nSelected;
@property (assign) BOOL bHasSubItem;

- (id)initWithCategory:(BlogCategory *)category;
- (id)initWithData:(NSString *)cateid name:(NSString *)catename;

@end
