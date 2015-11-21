//
//  PhotoObject.h
//  
//
//

typedef enum {
    FolderHeaderItem = 1,
    FolderItem,
    PhotoHeaderItem,
    PhotoItem
} ItemType;

@interface PhotoObject : NSObject

@property (nonatomic, copy) UIImage     *image;
@property (nonatomic, copy) UIColor     *background;
@property (nonatomic, copy) NSString    *imageName;
@property (nonatomic, copy) NSDate      *date;
@property (nonatomic, copy) NSString    *title;
@property (nonatomic, copy) NSString    *descriptionX;
@property (nonatomic, copy) NSString    *type;
@property (nonatomic, copy) NSNumber    *size;
@property (nonatomic, copy) NSNumber    *indexReference;

@property (nonatomic, assign) ItemType    itemType;

@property (nonatomic, assign) BOOL      imageDownloaded;
@property (nonatomic, assign) BOOL      imageMarked;
@property (nonatomic, assign) BOOL      imageSelected;


+ (id)issueItemWithDict:(NSDictionary *)dict;

@end
