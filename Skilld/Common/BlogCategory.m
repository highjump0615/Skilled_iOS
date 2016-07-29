//
//  BlogCategory.m
//  Skilld
//
//  Created by TianHang on 3/14/14.
//  Copyright (c) 2014 TianHang. All rights reserved.
//

#import "BlogCategory.h"

@implementation BlogCategory

@synthesize strId;
@synthesize strName;
@synthesize parent;
@synthesize nRowNum;
@synthesize nSelected;
@synthesize bHasSubItem;

- (id)initWithData:(NSString *)cateid name:(NSString *)catename {
    self = [super init];
    
	if (self) {
        strId = [NSString stringWithString:cateid];
        strName = [NSString stringWithString:catename];
        
        parent = nil;
        nRowNum = nSelected = 0;
        bHasSubItem = NO;
    }
    
    return self;
}

- (id)initWithCategory:(BlogCategory *)category {
    self = [super init];
    
	if (self) {
        strId = category.strId;
        strName = category.strName;
        parent = category.parent;
        nRowNum = category.nRowNum;
        nSelected = category.nSelected;
        bHasSubItem = category.bHasSubItem;
    }
    
    return self;
}

@end
