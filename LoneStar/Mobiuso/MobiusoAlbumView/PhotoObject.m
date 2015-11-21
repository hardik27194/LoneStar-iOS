//
//  PhotoObject.m
//  
//
//

#import "PhotoObject.h"

@implementation PhotoObject

@synthesize description;

+ (id)issueItemWithDict:(NSDictionary *)dict {
    PhotoObject *item = [[PhotoObject alloc] init];
    
    item.imageName = dict[@"image"];
    item.date = dict[@"date"];
    item.title = dict[@"title"];
    item.descriptionX = dict[@"description"];
    item.type = dict[@"type"];
    item.background = [UIColor clearColor];
    
    item.imageDownloaded = NO;
    item.imageMarked = NO;
    
    return item;
}


@end
