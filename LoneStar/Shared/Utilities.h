//
//  Utilities.h
//  LoneStar
//
//  Created by Sandeep on 1/30/12.
//  Copyright (c) 2012 Mobiuso. All rights reserved.
//  updated 8/19/2015
//

#import <Foundation/Foundation.h>

#import "Constants.h"
#import "MobiusoActionView.h"
#import "MobiusoVideoActionView.h"

/* Text alignment values, defined in a way which avoids deprecation
 warnings. */
#ifdef __IPHONE_6_0
# define DBX_ALIGN_LEFT NSTextAlignmentLeft
# define DBX_ALIGN_CENTER NSTextAlignmentCenter
# define DBX_ALIGN_RIGHT NSTextAlignmentRight
#else
# define DBX_ALIGN_LEFT UITextAlignmentLeft
# define DBX_ALIGN_CENTER UITextAlignmentCenter
# define DBX_ALIGN_RIGHT UITextAlignmentRight
#endif

#define IS_EQUAL(x,y)   ([x compare: y options: NSCaseInsensitiveSearch] == NSOrderedSame)

void Alert(NSString *title, NSString *msg);

typedef enum  {
    MoOrientationNorth = 1,   // top center
    MoOrientationNorthWest, // top left
    MoOrientationNorthEast, // top right
    MoOrientationWest,  // middle left
    MoOrientationCenter, // center
    MoOrientationEast,  // middle right
    MoOrientationSouthWest, // bottom left
    MoOrientationSouth, // bottom center
    MoOrientationSouthEast // bottom right
} MoOrientationType;


typedef enum  {
    FileTypeNone = 0,   // Can't figure out
    FileTypeText,
    FileTypePDF,
    FileTypeJPEG,
    FileTypePNG,
    FileTypePPTX,
    FileTypePPT,
    FileTypeDOCX,
    FileTypeDOC,
    FileTypeXLSX,
    FileTypeXLS,
    FileTypeRTF,
    FileTypeHTML,
    FileTypeGIF,
    FileTypeBMP,
    FileTypeZIP,
    FileTypeTIFF,
    FileTypeSHSH,   // Secure File
    FileTypeSHUB,   // Skills Hub
    FileTypeUnknown
} FileType;

typedef enum
{
    PasswordMatchNone = 0,
    PasswordMatchYes,
    PasswordMatchFactory
} PasswordMatchType;


#define UrlSafeString(str)        [[[[[[(str) stringByReplacingOccurrencesOfString:@"+" withString:@"%2b"] \
                                    stringByReplacingOccurrencesOfString:@"@" \
                                    withString:@"%40"] \
                                        stringByReplacingOccurrencesOfString:@" " \
                                        withString:@"%20"] \
                                            stringByReplacingOccurrencesOfString:@"#" \
                                            withString:@"%23"] \
                                                stringByReplacingOccurrencesOfString:@"~" \
                                                withString:@"%7E"] \
                                                    stringByReplacingOccurrencesOfString:@"-" \
                                                    withString:@"%2D"]

#define kTwitterProfileImageKey @"user_profile_image"
#define kTwitterBannerImageKey @"user_banner_image"


#define kFacebookProfileImageKey @"user_profile_image"
#define kFacebookBannerImageKey @"user_banner_image"

#define kFacebookProfileTypePage @"Page"
#define kFacebookProfileTypePersonal @"Personal"

@interface Utilities : NSObject

+ (NSString *) getMD5Hash: (NSString*) token;
+ (NSString *) getSHA1Hash: (NSString*) token;
+ (UIColor *) getThemeFontColor: (int) themeIdx;
+ (UIColor *) getThemeTileColor: (int) themeIdx;
// + (UIColor *) getBrandColor: (int) cornerIdx;
+ (CGFloat) getThemeFontAlpha: (int) themeIdx;
+ (CGFloat) getThemeTileAlpha: (int) themeIdx;

+ (UIImage *) setupScreenshot: (UIView *) view;

+ (void)rotateImage:(UIImageView *)imageView duration:(NSTimeInterval)duration 
              curve:(int)curve degrees:(CGFloat)degrees;
+ (void)rotateImage:(UIImageView *)imageView degrees:(CGFloat)degrees;

+ (NSString *)platformSuffix;
+ (NSString *)orientationSuffix;
+ (NSString *)resolutionSuffix;

// + (UIImage *)getOptimalImage: (NSString *) rootName frame: (CGRect) frame;
+ (void) setOptimalImageViewProperties: (UIImageView *) imageView image: (UIImage *) image;

+(NSString *)getUTCFormateDate:(NSDate *)localDate;
+(NSDate *)getUTCStringToDate:(NSString *)localDate;
+(NSString *)getLocalDateFromUTC:(NSString *)utcDate;

+ (NSArray *)reversedArray:(NSArray *)souceArray;

+(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding onString:(NSString *)sourceStr;

+(NSDictionary *)parseMobiusoUrl:(NSString *)requestURL;

+(NSString *)encodeBase64:(const uint8_t *)input length:(NSInteger)length;
// + (NSData *) base64DecodeString: (NSString *) strBase64;

+(CGSize) currentScreenSize;

+ (NSString*) applicationSavePath;
+ (NSString*) applicationDoNotBackupPath;
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;


+(NSInteger)getVersionStrFromDict:(NSDictionary *)inputDict;
+(NSString *)getTimeStampFromDict:(NSDictionary *)inputDict;
+(NSInteger)convertVersionStrToInt:(NSString *)inputStr;


+ (UIImage *)imageWithContentsOfFile:(NSString *)imageName;

+ (UIImage *)imageWithContentOfFile_custom:(NSString *)imageName ofType:(NSString *)imageType;

//+ (NSString *)urlEncodeUsingEncodingForS3:(NSStringEncoding)encoding onString:(NSString *)sourceStr;

+ (NSString *)getStringFromFile:(NSString *)fileName;

//+ (NSDictionary *) getJSONObjectFromContentOfFile:(NSString*)JSONFileName;

+ (void) doSlideIn: (UIView *) targetSlideInView inView: (UIView *) targetContainer fromCorner: (MoOrientationType) corner toPoint: (CGPoint) point;

+ (NSArray *) bundledRawImages: (NSString *) folder;

+ (NSArray *) bundledUniqueImages: (NSString *) folder;

+ (UIImage *) bundledImage: (NSString *) imageName inRelativeDirectory: (NSString *) folder;


#pragma mark Give the Shadow Effect to tiles
+ (CGPathRef)renderRect:(UIView*)imgView;
+ (CGPathRef)renderTrapezoid:(UIView*)imgView;
+ (CGPathRef)renderEllipse:(UIView*)imgView;
+ (CGPathRef)renderSoftBlur:(UIView*)imgView;
+ (CGPathRef)renderFatStroke:(UIView*)imgView;
+ (CGPathRef)renderPaperCurl:(UIView*)imgView;

// +(BOOL)isInAppModelIsPurchaseForReceipt:(NSString *)receipt;

+(UIImage*)createWhiteGradientImageWithSize:(CGSize)size;

+(UIImage*)createBlackGradientImageWithSize:(CGSize)size;

+(UIImage*)createSolidColorImageWithColor:(UIColor*)color andSize:(CGSize)size;

+(UIImage*)createSolidCircleImageWithColor:(UIColor*)color andSize:(CGSize)size;

+(UIImage*)createRoundedRectImageWithColor:(UIColor*)color andSize:(CGSize)size andRadius:(CGFloat)radius;

+ (UIImage*)createGradientImageFromColor:(UIColor *)startColor toColor:(UIColor *)endColor withSize:(CGSize)size;


+( NSString *) nameFromEmailString: (NSString *) emailStr;
+ (NSString *)randomStringOfLength:(NSUInteger)length;
+ (void)uniquifyArray:(NSMutableArray *)array;
+ (NSString *)stringRepresentationOfDate:(NSDate *)aDate;

// + (UIImage *)imageByScalingImage:(UIImage *)image toSize:(CGSize)size scale:(CGFloat)contentScale fromITouchCamera:(BOOL)isFromITouchCamera;
#ifdef NOTNOW
+ (CGRect) frame: (UIViewController *) vc;
+ (CGRect) bounds: (UIViewController *) vc;
#endif

+ (CGRect) applicationFrame;

+ (NSString *) mimeType: (FileType) type;
+ (FileType) fileType: (NSString *) filename;
+ (NSString *) extension: (FileType) filetype;
+ (NSString *) extensionFromName:(NSString *) filename;
+ (NSString *) basenameIfDotfile: (NSString *) filename;
+ (NSString *) basenameIfEncryptedfile: (NSString *) filename;

+ (NSString *) basename: (NSString *) filename;
+ (NSString *) basePathName: (NSString *) pathKey;
+ (NSString *) baseCacheFileName: (NSString *) cacheFileName;
+ (NSString *) dirCacheFileName: (NSString *) cacheFileName;

+ (NSString *) stripNumericSuffix: (NSString *) filename;

+ (NSString*)getTimeAsString:(NSDate *)lastDate;
+ (void)showError:(NSString*)errorMessage;
+ (NSString *) formatPhoneNumber: (NSString *) phoneString;


+ (BOOL) writeFile: (NSString *) filePath withContents: (NSString *) fileContents;
+ (NSData *) readData: (NSString *) filePath;
+ (NSString *) readString: (NSString *) filePath;
+ (NSString *)clone: (NSString *) path withData: (NSData *) data;

#pragma mark - Action View
// Setup Action View
+ (MobiusoActionView *) setupActionView: (NSInteger) tag
                           withMessage : (NSString *) message
                              withTitle: (NSString *) title
                        placeholderText: (NSString *) placeHolder
                             andButtons: (NSArray *) buttonArray
                      cancelButtonTitle: (NSString *) cancelStr
                                  color: (UIColor *) color
                                 inView: (UIView *) parentView
                            andDelegate: (NSObject <MobiusoActionViewDelegate> *) actionDelegate;
// Setup Action View
+ (MobiusoVideoActionView *) setupVideoActionView: (NSInteger) tag
                                     withMessage : (NSString *) message
                                        withTitle: (NSString *) title
                                  placeholderText: (NSString *) placeHolder
                                       andButtons: (NSArray *) buttonArray
                                cancelButtonTitle: (NSString *) cancelStr
                                            color: (UIColor *) color
                                       background: (NSString *) backgroundAsset
                                           inView: (UIView *) parentView
                                      andDelegate: (NSObject <MobiusoActionViewDelegate> *) actionDelegate;
+ (UIVisualEffectView *) addBlurVibrancyView: (CGRect) frame options: (BOOL) notificationCenter;

+ (BOOL) decompress: (NSString *)zippedFilePath toDestinationPath: (NSString *) destinationPath;

#ifdef DEBUG
+ (void) printFontNames;
#endif

@end
