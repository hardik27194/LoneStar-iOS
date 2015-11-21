//
//  ConferenceLayoutAttributes.m
//  MobiusoShelfPlus
//
//  Created by Sandeep Shah on 04/07/15.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

#import "ModuleLayoutAttributes.h"

@implementation ModuleLayoutAttributes

- (id)init
{
    self = [super init];
    if (self) {
        _headerTextAlignment = NSTextAlignmentLeft;
        _shadowOpacity = 0.5;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    ModuleLayoutAttributes *newAttributes = [super copyWithZone:zone];
    newAttributes.headerTextAlignment = self.headerTextAlignment;
    newAttributes.shadowOpacity = self.shadowOpacity;
    return newAttributes;
}

/*+ (instancetype)layoutAttributesForCellWithIndexPath:(NSIndexPath *)indexPath
{
    ConferenceLayoutAttributes *attributes = [[ConferenceLayoutAttributes alloc] init];
    attributes->_representedElementCategory = UICollectionElementCategoryCell;
    return attributes;
}

+ (instancetype)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind withIndexPath:(NSIndexPath*)indexPath
{
    ConferenceLayoutAttributes *attributes = [[ConferenceLayoutAttributes alloc] init];
    return attributes;
}

+ (instancetype)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind withIndexPath:(NSIndexPath *)indexPath
{
    ConferenceLayoutAttributes *attributes = [[ConferenceLayoutAttributes alloc] init];
    return attributes;
}*/

@end
