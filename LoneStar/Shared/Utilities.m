//
//  Utilities.m
//  LoneStar
//
//  Created by Sandeep on 1/30/12.
//  Copyright (c) 2012 Mobiuso LLC. All rights reserved.
//  updated 8/27/2015
//  updated 09/23/2015 - fontlist
//
/*!
 
 @class Utilities
 
 @discussion
 
 
 TODO:
 
 @history
 
 Initial version.
 
 */

#import "Utilities.h"
#import <CommonCrypto/CommonDigest.h>
#import <CoreGraphics/CoreGraphics.h>
#include <sys/xattr.h>
#import "RNEncryptor.h"
#import "RNDecryptor.h"
#import "Theme.h"
#import <UIKit/UIKit.h>
#import "ZipArchive.h"
@import NotificationCenter;

//#import "JSON.h"

@interface Utilities (Private)
+ (void)setupDateFormatters;
@end

@implementation Utilities

#define DEG_TO_RAD(angle) ((M_PI * angle) / 180.0)
#define RAD_TO_DEG(radians) (radians * (180.0/M_PI))

NSString *kShshDoxDefaultUserWantsBiometricSupport = @"com.mobiuso.shshdox.userWantsBiometricSupport";

// The following are based on the index numbers of the wallpaper chosen
long fontcolors[] = {
    /*00*/MAKERGBHEX(255, 255, 255),
    /*01*/MAKERGBHEX(255, 255, 255),
    /*02*/MAKERGBHEX(50, 50, 50),
    /*03*/MAKERGBHEX(32, 32, 32),
    /*04*/MAKERGBHEX(255, 255, 255),
    /*05*/MAKERGBHEX(255, 255, 255),
    /*06*/MAKERGBHEX(255, 255, 255),
    /*07*/MAKERGBHEX(255, 255, 255),
    /*08*/MAKERGBHEX(154, 0, 0)
};

// The following are based on the index numbers of the wallpaper chosen
long brandcolors[] = {/*00*/ 0xffd42b45,  // red
    /*01*/ 0xff14aede, // blue
    /*03*/ 0xff97999c,  // gray
    /*02*/ 0xff5ca445 // green
};

// The following are based on the index numbers of the wallpaper chosen
long tilecolors[] = {/*00*/ 0x5f97b0b7,  //
    /*01*/ 0x80ffffff,
    /*02*/ 0xffffffff,
    /*03*/ 0xffffffff,
    /*04*/ 0xffffffff,
    /*05*/ 0xffffffff,
    /*06*/ 0xffffffff,
    /*07*/ 0xffffffff
};


void Alert(NSString *title, NSString *msg) {
    [[[UIAlertView alloc]
      initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
     show];
}

+ (NSString *) getMD5Hash: (NSString*) token
{
    return token;
#ifdef NOTNOW_WHYIS_RETURN_HERE
    NSString *curatedToken = [token stringByTrimmingCharactersInSet:
                              [NSCharacterSet whitespaceCharacterSet]];
    
    const char *cStr = [curatedToken UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // compute MD5
    
    NSString *md5Token = [[NSString alloc] initWithFormat:
                          @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          result[0], result[1], result[2], result[3],
                          result[4], result[5], result[6], result[7],
                          result[8], result[9], result[10], result[11],
                          result[12], result[13], result[14], result[15]
                          ];
    // NSString *gravatarEndPoint = [NSString stringWithFormat:@"http://www.gravatar.com/avatar/%@?s=512", md5email];
    
    return md5Token; // [md5Token autorelease]; // [NSURL URLWithString:gravatarEndPoint];
#endif
}

// Convert the given string into MD5 hash for using on the local machine
+ (NSString *) getSHA1Hash: (NSString*) token
{
    NSString *curatedToken = [[token stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]]
                              lowercaseString];
    
    const char *cStr = [curatedToken UTF8String];
    unsigned char result[20];
    CC_SHA1(cStr, (unsigned int)strlen(cStr), result); // compute MD5
    NSString *sha1Token = [[NSString alloc] initWithFormat:
                           @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                           result[0], result[1], result[2], result[3],
                           result[4], result[5], result[6], result[7],
                           result[8], result[9], result[10], result[11],
                           result[12], result[13], result[14], result[15],
                           result[16], result[17], result[18], result[19]
                           ];
    // NSString *gravatarEndPoint = [NSString stringWithFormat:@"http://www.gravatar.com/avatar/%@?s=512", md5email];
    
    return sha1Token; // [sha1Token autorelease]; // [NSURL URLWithString:gravatarEndPoint];
}


+ (NSData *) readData: (NSString *) filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager contentsAtPath:filePath];
}

+ (NSString *) readString: (NSString *) filePath
{
    NSData *data = [self readData:filePath];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

// Clones Data to File System Path specified
+ (NSString *)clone: (NSString *) path withData: (NSData *) data
{
    // Create BackupPath if not there
    NSString *appPath = [self applicationDoNotBackupPath];
    
    NSString *delimiter = @"";
    NSString *dir = @"";
    NSRange index = [path rangeOfString:@"/"];
    if (index.location != 0)  {
        delimiter = @"/";
    }
    if (index.location != NSNotFound) {
        // find out the leading components and create directories if necessary
        index = [path rangeOfString:@"/" options:NSBackwardsSearch];
        dir = [path substringToIndex:index.location];
        NSLog(@"path=%@", dir);
    }
    
    NSString *appDir = [NSString stringWithFormat:@"%@%@%@", appPath, delimiter, dir];
    if (![[NSFileManager defaultManager] fileExistsAtPath:appDir])
    {
        NSError *err = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:appDir
                                       withIntermediateDirectories:YES attributes:nil error:&err])
        {
            NSLog(@"DDFileLogManagerDefault: Error creating directory: %@", err);
        }
    }
    
    NSString *fullpath = [NSString stringWithFormat:@"%@%@%@", appPath, delimiter, path];
    // copy blindly, later check the existence of the file and whether we have new data
    BOOL success = [data writeToFile: fullpath atomically:YES];
    NSLog(@"result=%@", success? @"YES":@"NO");
    return (success? fullpath : nil);
}




+ (BOOL) writeFile: (NSString *) filePath withContents: (NSString *) fileContents
{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath error:&error];
    
    NSData *data = [fileContents dataUsingEncoding:NSUTF8StringEncoding];
    
    // Do we delete the file first?
    if ((!error) && (fileAttributes != nil)) {
        // Looks like the file exists, compare the timestamps
        [fileManager removeItemAtPath:filePath error:&error];
    }
    
    return [fileManager createFileAtPath:filePath contents:data attributes:nil];
    
}

// Get optimal Font color for the theme
+ (UIColor *) getThemeFontColor: (int) themeIdx
{
    return COLORFROMHEX( fontcolors[themeIdx]);
}

// Get optimal Tile color for the theme
+ (UIColor *) getThemeTileColor: (int) themeIdx
{
    return COLORFROMHEX( tilecolors[themeIdx]);
}

// Get optimal Font color for the theme
+ (CGFloat) getThemeFontAlpha: (int) themeIdx
{
    return ALPHAFROMHEX( fontcolors[themeIdx]);
}

// Get optimal Tile color for the theme
+ (CGFloat) getThemeTileAlpha: (int) themeIdx
{
    return ALPHAFROMHEX( tilecolors[themeIdx]);
}

+ (UIImage *) setupScreenshot: (UIView *) view
{
    CGSize result = [[UIScreen mainScreen] bounds].size;
    
    CGSize result2 = result;
    result2.height += 60;
    // UIGraphicsBeginImageContext(/*self.view.bounds.size*/result2);
    UIGraphicsBeginImageContextWithOptions(result2, YES, 0.0);
    CALayer *imageLayer = [[CALayer alloc] init];
    imageLayer.frame = CGRectMake((result.width - 110)/2, 72, 110, 30);
    imageLayer.contents = (__bridge id)([UIImage imageNamed:@"skyscape.png"].CGImage);
    
    [view.layer addSublayer: imageLayer];
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *screenshotImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [imageLayer removeFromSuperlayer];
    
    return screenshotImage;
}

//
// Rotate the image with animation
//
+ (void)rotateImage:(UIImageView *)imageView duration:(NSTimeInterval)duration
              curve:(int)curve degrees:(CGFloat)degrees
{
    // Setup the animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    // The transform matrix
    CGAffineTransform transform =
    CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(degrees));
    imageView.transform = transform;
    
    // Commit the changes
    [UIView commitAnimations];
}

+ (void)rotateImage:(UIImageView *)imageView degrees:(CGFloat)degrees
{
    
    // The transform matrix
    CGAffineTransform transform =
    CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(degrees));
    imageView.transform = transform;
    
}

+ (NSString *)platformSuffix {
    BOOL isPad = NO;
#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 30200)
    isPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
#endif
    return isPad ? @"iPad" : @"iPhone";
}

+ (NSString *) orientationSuffix {
    // The following yields Unknown orientation (may only be valid for the Simulator
    UIInterfaceOrientation orientation =  // [[UIDevice currentDevice] orientation];
    [[UIApplication sharedApplication] statusBarOrientation];
    return (orientation==UIDeviceOrientationPortrait)? @"Portrait" : @"Landscape";
}

- (BOOL) isRetina {
    return [[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0);
}


+ (NSString *)resolutionSuffix {
    
    return (([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))? @"@2x" : @"");
}

#ifdef PROBLEM
// Given a frame and "root" name, find the best fit for the image (may need to rotate, it will be decided later)...
+ (UIImage *) getOptimalImage: (NSString *) rootName frame: (CGRect) frame
{
    UIImage *wallpaperImage = nil;
    // NSString *imageName;
    
#ifdef DEBUGX
    BOOL gotit = ((wallpaperImage = [UIImage imageNamed: (imageName=[NSString stringWithFormat: @"%@-%@-%@%@.png",
                                                                     rootName, [Utilities orientationSuffix],
                                                                     [Utilities platformSuffix],
                                                                     [Utilities resolutionSuffix]])]) != nil) ||
#endif
    
    // JPEG
    ((wallpaperImage = [UIImage imageNamed: ([NSString stringWithFormat: @"%@-%@-%@%@.jpg",
                                              rootName, [Utilities orientationSuffix],
                                              [Utilities platformSuffix],
                                              [Utilities resolutionSuffix]])]) != nil)  ||
    // worst case try to get the image with just the root name...png
    ((wallpaperImage = [UIImage imageNamed: ([NSString stringWithFormat: @"%@.png",
                                              rootName])]) != nil)   ||
    // worst case try to get the image with just the root name...jpg
    ((wallpaperImage = [UIImage imageNamed: ([NSString stringWithFormat: @"%@.jpg",
                                              rootName])]) != nil);
    // NSLog(@"%@", imageName);
    return wallpaperImage;
}
#endif

// Imageview frame must be set up
+ (void) setOptimalImageViewProperties: (UIImageView *) imageView image: (UIImage *) image
{
    // do the rotation, stretch or anything else..
    // TODO - for now
    imageView.image = image;
    imageView.contentMode = UIViewContentModeCenter;
    CGSize imageSize = image.size;
    CGSize frameSize = [imageView frame].size;   //
    imageView.center = CGPointMake(frameSize.width/2, frameSize.height/2);
    imageView.clipsToBounds = YES;
    // The following is OK for now
    if ((imageSize.height < frameSize.height) && (imageSize.width < frameSize.width)) {
        // Have to stretch - no choice
        imageView.contentMode = UIViewContentModeScaleAspectFill;  // stretch proportionally
    } else if (((imageSize.height < frameSize.height) && (imageSize.width >= frameSize.height)) ||
               ((imageSize.width < frameSize.width) && (imageSize.height >= frameSize.width))) {
        // Need to rotate the image (can do with animation if necessary)
        [Utilities rotateImage:imageView degrees: (([[UIDevice currentDevice] orientation] == UIInterfaceOrientationLandscapeRight)? 270.0f: 90.0f)];
        // the following to check if one of the dimensions is exact multiple of the other one
    } else if (((((uint)imageSize.height/(uint)frameSize.height)*(uint)(uint)frameSize.height) == (uint)imageSize.height) ||
               ((((uint)imageSize.width/(uint)frameSize.width)*(uint)(uint)frameSize.width) == (uint)imageSize.width)) {
        // Can scale proportionally, TODO one more check is needed
        imageView.contentMode = UIViewContentModeScaleAspectFill;  // stretch proportionally
    } else {
        imageView.contentMode = UIViewContentModeCenter;
    }
    
}

// This method will convert given date into UTC format
+(NSString *)getUTCFormateDate:(NSDate *)localDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:localDate];
    // [dateFormatter release];
    return dateString;
}

+(NSDate *)getUTCStringToDate:(NSString *)localDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //NSString *dateString = [dateFormatter stringFromDate:localDate];
    NSDate *returnDate = [dateFormatter dateFromString:localDate];
    // [dateFormatter release];
    return returnDate;
}

//Bug #0000022
+(NSString *)getLocalDateFromUTC:(NSString *)utcDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //NSString *dateString = [dateFormatter stringFromDate:localDate];
    NSDate *returnDate = [dateFormatter dateFromString:utcDate];
    // [dateFormatter release];
    
    NSDateFormatter* df_local = [[NSDateFormatter alloc] init];
    [df_local setTimeZone:[NSTimeZone systemTimeZone]];
    [df_local setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* ts_local_string = [df_local stringFromDate:returnDate];
    return ts_local_string;
}






+ (NSArray *)reversedArray:(NSArray *)souceArray {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[souceArray count]];
    NSEnumerator *enumerator = [souceArray reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}

+(NSDate *)getDateFromUTCFormat:(NSString *)dateString
{
    return nil;
    
}

#ifdef NOTNOW
+ (NSString *) getDocumentsDir
{
    NSFileManager    *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    
}

// From http://iphoneincubator.com/blog/data-management/reading-and-writing-plists
- (id)readPlist:(NSString *)fileName {
    NSData *plistData;
    NSString *error;
    NSPropertyListFormat format;
    id plist;
    
    NSString *localizedPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    plistData = [NSData dataWithContentsOfFile:localizedPath];
    
    plist = [NSPropertyListSerialization propertyListFromData:plistData mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&error];
    if (!plist) {
        DLog(@"Error reading plist from file '%s', error = '%s'", [localizedPath UTF8String], [error UTF8String]);
        [error release];
    }
    
    return plist;
}

- (NSArray *)getArray:(NSString *)fileName {
    return (NSArray *)[self readPlist:fileName];
}

- (NSDictionary *)getDictionary:(NSString *)fileName {
    return (NSDictionary *)[self readPlist:fileName];
}
- (void)writePlist:(id)plist fileName:(NSString *)fileName {
    NSData *xmlData;
    NSString *error;
    
    NSString *localizedPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    xmlData = [NSPropertyListSerialization dataFromPropertyList:plist format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    if (xmlData) {
        [xmlData writeToFile:localizedPath atomically:YES];
    } else {
        DLog(@"Error writing plist to file '%s', error = '%s'", [localizedPath UTF8String], [error UTF8String]);
        [error release];
    }
}







#endif  // NOTNOW

+(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding onString:(NSString *)sourceStr
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)sourceStr,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 CFStringConvertNSStringEncodingToEncoding(encoding)));
}


+(NSDictionary *)parseMobiusoUrl:(NSString *)requestURL
{
    if(requestURL == nil)
        return nil;
    NSString *temp1 = [requestURL substringFromIndex:2];
    NSArray *chunks1 = [temp1 componentsSeparatedByString: @"?"];
    if([chunks1 count] == 0)
    {
        return nil;
    }
    NSMutableDictionary *returnDict = [[NSMutableDictionary alloc] init];
    [returnDict setValue:[chunks1 objectAtIndex:0] forKey:@"action"];
    if([chunks1 count] < 2)
    {
        return returnDict;
    }
    NSArray *chunks2 = [[chunks1 objectAtIndex:1] componentsSeparatedByString: @"&"];
    for(NSString *temp2 in chunks2)
    {
        NSRange tempRange = [temp2 rangeOfString:@"="];
        if(tempRange.length != 0)
        {
            NSString *c1 = [temp2 substringToIndex:tempRange.location];
            NSString *c2 = [temp2 substringFromIndex:tempRange.location + 1];
            
            [returnDict setValue:c2 forKey:c1];
            
        }
        
        //        NSArray *chunks3 = [temp2 componentsSeparatedByString: @"="];
        //        if([chunks3 count] == 2)
        //        {
        //            [returnDict setValue:[chunks3 objectAtIndex:1] forKey:[chunks3 objectAtIndex:0]];
        //        }
    }
    return returnDict;
}

+ (NSString *)encodeBase64:(const uint8_t *)input length:(NSInteger)length {
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData *data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t *output = (uint8_t *)data.mutableBytes;
    
    for (NSInteger i = 0; i < length; i += 3) {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger index = (i / 3) * 4;
        output[index + 0] = table[(value >> 18) & 0x3F];
        output[index + 1] = table[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? table[(value >> 6) & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? table[(value >> 0) & 0x3F] : '=';
    }
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

+(CGSize) currentScreenSize
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGSize size = [UIScreen mainScreen].bounds.size;
    UIApplication *application = [UIApplication sharedApplication];
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        size = CGSizeMake(size.height, size.width);
    }
    if (application.statusBarHidden == NO)
    {
        size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
    }
    return size;
}


+ (NSString*) applicationSavePath
{
    NSString *os5 = @"5.0";
    
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    if ([currSysVer compare:os5 options:NSNumericSearch] == NSOrderedAscending) //lower than 4
    {
        return path;
    }
    else if ([currSysVer compare:os5 options:NSNumericSearch] == NSOrderedDescending) //5.0.1 and above
    {
        return path;
    }
    else // IOS 5
    {
        path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
        return path;
    }
    
    return nil;
}
+ (NSString*) applicationDoNotBackupPath
{
    NSString *os5 = @"5.0";
    
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    path = [path stringByAppendingPathComponent:@"DoNotBackup"];
    
    if ([currSysVer compare:os5 options:NSNumericSearch] == NSOrderedAscending) //lower than 4
    {
        return path;
    }
    else if ([currSysVer compare:os5 options:NSNumericSearch] == NSOrderedDescending) //5.0.1 and above
    {
        return path;
    }
    else // IOS 5
    {
        path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/DoNotBackup"];
        return path;
    }
    
    return nil;
}

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    NSError *error;
    
#ifdef NOTNOW
    if (/* DISABLES CODE */ (&NSURLIsExcludedFromBackupKey) == nil) { // iOS <= 5.0.1
        const char* filePath = [[URL path] fileSystemRepresentation];
        
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        return result == 0;
    } else
#endif
    { // iOS >= 5.1
        BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
        
        if(!success){
            
            DLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
            
        }
        return success;
    }
}


+ (NSArray *) bundledRawImages: (NSString *) folder
{
    return [[NSBundle mainBundle] pathsForResourcesOfType:@"png"
                                              inDirectory: folder];
}

+ (NSArray *) bundledUniqueImages: (NSString *) folder
{
    NSArray *array = [[NSBundle mainBundle] pathsForResourcesOfType:@"png"
                                                        inDirectory: folder];
    NSMutableArray *uniqueArray = [[NSMutableArray alloc] init];
    for (NSString *path in array) {
        if([path rangeOfString:@"@2x."].location == NSNotFound) {
            [uniqueArray addObject:path];
        }
    }
    return (NSArray *)uniqueArray;
}

+ (UIImage *) bundledImage: (NSString *) imageName inRelativeDirectory: (NSString *) folder
{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:nil inDirectory:folder];
    UIImage *bgImage = nil;
    if (imagePath != nil) {
        bgImage = [UIImage imageWithContentsOfFile: imagePath];
    }
    return bgImage;
}


+(NSInteger)getVersionStrFromDict:(NSDictionary *)inputDict
{
    NSString *tempStr = [inputDict objectForKey:@"minVer"];
    if(tempStr != nil)
    {
        return [Utilities convertVersionStrToInt:tempStr];
    }
    return [Utilities convertVersionStrToInt:@"13090.1"];
    //return @"13060.1";
}

+(NSString *)getTimeStampFromDict:(NSDictionary *)inputDict
{
    NSString *tempStr = [inputDict objectForKey:@"latestTimestamp"];
    if(tempStr != nil)
    {
        return tempStr;
    }
    
    return @"20130227121515";
    //return @"13060.1";
}

+(NSInteger)convertVersionStrToInt:(NSString *)inputStr
{
    NSInteger returnVal = 0;
    NSUInteger len = [inputStr length];
    for(int i = 0; i < len ;i++)
    {
        unichar tempChar = [inputStr characterAtIndex:i];
        if(tempChar >= '0' && tempChar <= '9')
        {
            returnVal = returnVal * 10 + (tempChar - '0');
        }
    }
    return returnVal;
}

// Return the Image located in the icons folder
+ (UIImage *)imageWithContentsOfFile:(NSString *)imageName
{
    NSString *imagePath = [[[Utilities applicationDoNotBackupPath] stringByAppendingPathComponent:@"icons"] stringByAppendingPathComponent: imageName];
    // Check for updated image ...
    UIImage *returnImage = [UIImage imageWithContentsOfFile: imagePath];
    // If not present in the 'patch', then locate in the bundle
    if (returnImage == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
        // NSString *imageWithPath = [NSString stringWithFormat:@"%@/%@", path, imageName];
        returnImage = [UIImage imageWithContentsOfFile: path];
    }
    return [returnImage copy];
    
}

+(UIImage *)imageWithContentOfFile_custom:(NSString *)imageName ofType:(NSString *)imageType
{
    
    UIImage *rightCap = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageName ofType:imageType]];
    
    if(rightCap == nil)
    {
        rightCap = [Utilities imageWithContentsOfFile:[imageName stringByAppendingString:@".png"]];
    }
    
    return rightCap;
    
    //    UIImage *img = [UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"myImage2" ofType:@"png"]];
    //    imageView.image = [UIImage imageWithCGImage:imageRef];
    //
    //
    //    NSString *retinaPath = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@@2x.%@", [[path lastPathComponent] stringByDeletingPathExtension], [path pathExtension]]];
    //
    //    if( [UIScreen mainScreen].scale == 2.0 && [[NSFileManager defaultManager] fileExistsAtPath:retinaPath] == YES)
    //        return [[[UIImage alloc] initWithCGImage:[[UIImage imageWithData:[NSData dataWithContentsOfFile:retinaPath]] CGImage] scale:2.0 orientation:UIImageOrientationUp] autorelease];
    //    else
    //        return [UIImage imageWithContentsOfFile:path];
}


+ (NSString *)getStringFromFile:(NSString *)fileName
{
    NSError *err;
    NSUInteger pos = [fileName rangeOfString: [NSString stringWithFormat: @"/"]].location;
    NSString *appFilePath = fileName;
    if ( (pos == NSNotFound) || pos != 0) {
        appFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"/%@",fileName] ofType:nil];
    }
    NSString *fileContent = [[NSString alloc] initWithContentsOfFile:appFilePath encoding:NSUTF8StringEncoding error: &err];
    return fileContent;
}


#ifdef JSON
+ (NSDictionary *) getJSONObjectFromContentOfFile:(NSString*)JSONFileName
{
    
    NSString *fileContent = [self getStringFromFile:JSONFileName];
    if(fileContent == nil)
    {
        return nil;
    }
    NSDictionary *JSONObject = [fileContent JSONValue];
    if(JSONObject == nil)
    {
        return nil;
    }
    else
    {
        return JSONObject;
    }
}
#endif

// Slide In the View - properties will be set to where the view is supposed to be visible

+ (void) doSlideIn: (UIView *) targetSlideInView inView: (UIView *) targetContainer fromCorner: (MoOrientationType) corner toPoint: (CGPoint) point
{
    CGSize containerSize = [targetContainer bounds].size;
    CGPoint fromPoint;
    switch (corner) {
        case MoOrientationSouthEast:
            fromPoint.x = containerSize.width;
            fromPoint.y = containerSize.height;
            break;
            
        case MoOrientationCenter:
            fromPoint.x = containerSize.width/2;
            fromPoint.y = containerSize.height/2;
            break;
            
        case MoOrientationEast:
            fromPoint.x = containerSize.width;
            fromPoint.y = containerSize.height/2;
            break;
            
        case MoOrientationNorth:
            fromPoint.x = containerSize.width/2;
            fromPoint.y = 0;
            break;
            
        case MoOrientationNorthEast:
            fromPoint.x = containerSize.width;
            fromPoint.y = 0;
            break;
            
        case MoOrientationNorthWest:
            fromPoint.x = 0;
            fromPoint.y = 0;
            break;
            
        case MoOrientationSouth:
            fromPoint.x = containerSize.width/2;
            fromPoint.y = containerSize.height;
            break;
            
        case MoOrientationSouthWest:
            fromPoint.x = 0;
            fromPoint.y = containerSize.height;
            break;
            
        case MoOrientationWest:
            fromPoint.x = 0;
            fromPoint.y = containerSize.height/2;
            break;
            
            
        default:
            break;
    }
    [targetSlideInView setCenter: fromPoint/*sender.center*/];
    
    
    CGPoint center = point;
    [UIView animateWithDuration:1.2f
                          delay:0.1f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         // [starView setCenter:CGPointMake(0, 0)];
                         [targetSlideInView setAlpha:1.0f];
                         [targetSlideInView setCenter: center];
                     }
                     completion:^(BOOL finished){
                         //[targetImageView removeFromSuperview];
                         //points++;
                         //NSLog(@"points: %i", points);
                     }];
    
    [targetContainer addSubview:targetSlideInView];
    
}

#pragma mark Give the Shadow Effect to rectangular shapes

+ (CGPathRef)renderRect:(UIView*)imgView {
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:imgView.bounds];
    return path.CGPath;
}

+ (CGPathRef)renderTrapezoid:(UIView*)imgView {
    CGSize size = imgView.bounds.size;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(size.width * 0.33f, size.height * 0.66f)];
    [path addLineToPoint:CGPointMake(size.width * 0.66f, size.height * 0.66f)];
    [path addLineToPoint:CGPointMake(size.width * 1.15f, size.height * 1.15f)];
    [path addLineToPoint:CGPointMake(size.width * -0.15f, size.height * 1.15f)];
    
    return path.CGPath;
}

+ (CGPathRef)renderEllipse:(UIView*) imgView {
    CGSize size = imgView.bounds.size;
    
    CGRect ovalRect = CGRectMake(2.0f, size.height - 2, size.width - 4, 8);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:ovalRect];
    
    return path.CGPath;
}

+ (CGPathRef)renderSoftBlur:(UIView*)imgView {
    CGRect frame = imgView.bounds;
    float w = frame.size.width; float h = frame.size.height;
    float lineWidth = 8.0f;
    
    float x1, y1, x2, y2, x3, y3, x4, y4;
    x1 = 0; y1 = h-lineWidth;
    x2 = w; y2 = h-lineWidth;
    x3 = w; y3 = h;
    x4 = 0; y4 = h;
    
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(x1, y1)];
    [path addLineToPoint:CGPointMake(x2, y2)];
    [path addLineToPoint:CGPointMake(x3, y3)];
    [path addLineToPoint:CGPointMake(x4, y4)];
    
    return path.CGPath;
}

+ (CGPathRef)renderFatStroke:(UIView*)imgView {
    CGRect frame = imgView.bounds;
    float w = frame.size.width; float h = frame.size.height; float x = frame.origin.x; float y = frame.origin.y;
    float lineWidth = 20.0f;
    
    float x1, y1, cpx2, cpy2, cpx1, cpy1, x4, y4, x5, y5, x6, y6, x7, y7, x8, y8;
    x1 = x + w * 0.25f; y1 = y + h * 0.35f;
    cpx1 = x + w * 0.35f; cpy1 = y + h * 0.0f;
    cpx2 = x + w * 0.45f; cpy2 = y + h * 0.5f;
    x4 = x + w * 0.70f; y4 = y + h * 0.25f;
    x5 = x + w * 0.70f + lineWidth; y5 = y + h * 0.25f + lineWidth * 0.5f;
    x6 = x + w * 0.45f; y6 = y + h * 0.5f + lineWidth;
    x7 = x + w * 0.35f; y7 = y + h * 0.0f + lineWidth;
    x8 = x + w * 0.25f - lineWidth * 0.5f; y8 = y + h * 0.3f + lineWidth;
    
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(x1, y1)];
    [path addCurveToPoint:CGPointMake(x4, y4)
            controlPoint1:CGPointMake(cpx1, cpy1)
            controlPoint2:CGPointMake(cpx2, cpy2)];
    [path addLineToPoint:CGPointMake(x5, y5)];
    [path addCurveToPoint:CGPointMake(x8, y8)
            controlPoint1:CGPointMake(x6, y6)
            controlPoint2:CGPointMake(x7, y7)];
    
    
    return path.CGPath;
}

+ (CGPathRef)renderPaperCurl:(UIView*)imgView
{
    CGSize size = imgView.bounds.size;
    CGFloat curlFactor = 15.0f;
    CGFloat shadowDepth = 5.0f;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(3.0f, 3.0f)];
    [path addLineToPoint:CGPointMake(size.width+3.0f, 3.0f)];
    [path addLineToPoint:CGPointMake(size.width+3.0f, size.height + shadowDepth)];
    [path addCurveToPoint:CGPointMake(3.0f, size.height + shadowDepth)
            controlPoint1:CGPointMake(size.width - curlFactor, size.height + shadowDepth - curlFactor)
            controlPoint2:CGPointMake(curlFactor, size.height + shadowDepth - curlFactor)];
    
    return path.CGPath;
}

#ifdef APPMODEL
+(BOOL)isInAppModelIsPurchaseForReceipt:(NSString *)receipt
{
    if(receipt != nil)
    {
        NSData *decodedReceipt = [Utilities base64DecodeString:receipt];
        NSPropertyListFormat format;
        NSError *error;
        
        NSDictionary *tempDict = [NSPropertyListSerialization propertyListWithData: decodedReceipt
                                                                           options: NSPropertyListImmutable
                                                                            format: &format
                                                                             error: &error];
        
        NSString *purchaseInfo = [tempDict objectForKey:@"purchase-info"];
        
        
        NSData *purchaseInfoData = [Utilities base64DecodeString:purchaseInfo];
        NSDictionary *purchaseInfoDict = [NSPropertyListSerialization propertyListWithData:purchaseInfoData
                                                                                   options: NSPropertyListImmutable
                                                                                    format: &format
                                                                                     error: &error];
        NSString *expiryDateMS = [purchaseInfoDict objectForKey:@"expires-date"];
        if(expiryDateMS == nil)
        {
            return YES;
        }
    }
    return NO;
    
}
#endif
// New 20130910

+(UIImage*)createWhiteGradientImageWithSize:(CGSize)size{
    
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGRect fillRect = CGRectMake(0,0,size.width,size.height);
    UIColor * whiteColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    UIColor* whiteTransparent = [UIColor colorWithWhite:1.0f alpha:0.6f];
    drawLinearGradient(currentContext, fillRect, whiteColor.CGColor, whiteTransparent.CGColor);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+(UIImage*)createBlackGradientImageWithSize:(CGSize)size{
    
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGRect fillRect = CGRectMake(0,0,size.width,size.height);
    UIColor * blackColor = [UIColor colorWithWhite:0.0 alpha:0.2f];
    UIColor* blackColorTransparent = [UIColor clearColor];
    drawLinearGradient(currentContext, fillRect, blackColor.CGColor, blackColorTransparent.CGColor);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+(UIImage*)createSolidColorImageWithColor:(UIColor*)color andSize:(CGSize)size{
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGRect fillRect = CGRectMake(0,0,size.width,size.height);
    CGContextSetFillColorWithColor(currentContext, color.CGColor);
    CGContextFillRect(currentContext, fillRect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+(UIImage*)createRoundedRectImageWithColor:(UIColor*)color andSize:(CGSize)size andRadius:(CGFloat)radius{
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGRect fillRect = CGRectMake(0,0,size.width,size.height);
    // CGContextSetFillColorWithColor(currentContext, color.CGColor);
    //CGContextFillRect(currentContext, fillRect);
    
    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:fillRect cornerRadius:radius];
    CGContextAddPath(currentContext, path.CGPath);
    CGContextSetFillColorWithColor(currentContext, color.CGColor);
    CGContextFillPath(currentContext);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+(UIImage*)createSolidCircleImageWithColor:(UIColor*)color andSize:(CGSize)size{
    
    CGRect contextRect = CGRectMake(0, 0, size.width+5, size.height+5);
    CGRect imageRect = [self createRectWithSize:size inMiddleOfRect:contextRect];
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    UIGraphicsBeginImageContextWithOptions(contextRect.size, NO, scale);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    
    CGContextAddEllipseInRect(currentContext, imageRect);
    CGContextSetFillColorWithColor(currentContext, color.CGColor);
    CGContextFillPath(currentContext);
    
    CGContextSetStrokeColor(currentContext, CGColorGetComponents([UIColor colorWithWhite:0.0 alpha:0.1].CGColor));
    CGContextSetLineWidth(currentContext, 2);
    CGContextStrokeEllipseInRect(currentContext, imageRect);
    
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+(CGRect)createRectWithSize:(CGSize)size inMiddleOfRect:(CGRect)rect{
    
    CGFloat leftMargin = (rect.size.width - size.width)/2.0;
    CGFloat topMargin = (rect.size.height - size.height)/2.0;
    
    CGRect newRect = CGRectMake(leftMargin, topMargin, size.width, size.height);
    
    return newRect;
}

#ifdef IMAGESCALING
#pragma mark - Images
+ (UIImage *)imageByScalingImage:(UIImage *)image toSize:(CGSize)size scale:(CGFloat)contentScale fromITouchCamera:(BOOL)isFromITouchCamera {
    UIImage *result = nil;
    CGImageRef imageRef = nil;
    size_t samplesPerPixel, bytesPerRow, bitsPerComponent;
    CGFloat newHeight, newWidth;
    CGRect newRect;
    CGContextRef bitmapContext = nil;
    CGImageRef newRef = nil;
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGImageAlphaInfo newAlphaInfo;
    CGColorSpaceRef colorSpaceRef;
    
    imageRef = [image CGImage];
    
    samplesPerPixel = 4;
    
    size = CGSizeMake(floor(size.width), floor(size.height));
    newWidth = size.width;
    newHeight = size.height;
    
    // Rotate and scale based on orientation.
    if (image.imageOrientation == UIImageOrientationUpMirrored) { // EXIF 2
                                                                  // Image is mirrored horizontally.
        transform = CGAffineTransformMakeTranslation(newWidth, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
    } else if (image.imageOrientation == UIImageOrientationDown) { // EXIF 3
                                                                   // Image is rotated 180 degrees.
        transform = CGAffineTransformMakeTranslation(newWidth, newHeight);
        transform = CGAffineTransformRotate(transform, DEG_TO_RAD(180));
    } else if (image.imageOrientation == UIImageOrientationDownMirrored) { // EXIF 4
                                                                           // Image is mirrored vertically.
        transform = CGAffineTransformMakeTranslation(0, newHeight);
        transform = CGAffineTransformScale(transform, 1.0, -1.0);
    } else if (image.imageOrientation == UIImageOrientationLeftMirrored) { // EXIF 5
                                                                           // Image is mirrored horizontally then rotated 270 degrees clockwise.
        transform = CGAffineTransformRotate(transform, DEG_TO_RAD(90));
        transform = CGAffineTransformScale(transform, -newHeight/newWidth,  newWidth/newHeight);
        transform = CGAffineTransformTranslate(transform, -newWidth, -newHeight);
    } else if (image.imageOrientation == UIImageOrientationLeft) { // EXIF 6
                                                                   // Image is rotated 270 degrees clockwise.
        transform = CGAffineTransformRotate(transform, DEG_TO_RAD(-90));
        transform = CGAffineTransformScale(transform, newHeight/newWidth,  newWidth/newHeight);
        transform = CGAffineTransformTranslate(transform, -newWidth, 0);
    } else if (image.imageOrientation == UIImageOrientationRightMirrored) { // EXIF 7
                                                                            // Image is mirrored horizontally then rotated 90 degrees clockwise.
        transform = CGAffineTransformRotate(transform, DEG_TO_RAD(-90));
        transform = CGAffineTransformScale(transform, -newHeight/newWidth,  newWidth/newHeight);
    } else if (image.imageOrientation == UIImageOrientationRight) { // EXIF 8
                                                                    // Image is rotated 90 degrees clockwise.
        transform = CGAffineTransformRotate(transform, DEG_TO_RAD(90));
        transform = CGAffineTransformScale(transform, newHeight/newWidth,  newWidth/newHeight);
        transform = CGAffineTransformTranslate(transform, 0.0, -newHeight);
    }
    newRect = CGRectIntegral(CGRectMake(0.0, 0.0, newWidth, newHeight));
    
    bytesPerRow = samplesPerPixel * newWidth;
    newAlphaInfo = kCGImageAlphaPremultipliedFirst;
    bitsPerComponent = 8;
    colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    
    bitmapContext = CGBitmapContextCreate(NULL, newWidth, newHeight, bitsPerComponent, bytesPerRow, colorSpaceRef, newAlphaInfo);
    CGColorSpaceRelease(colorSpaceRef), colorSpaceRef = NULL;
    CGContextSetInterpolationQuality(bitmapContext, kCGInterpolationHigh);
    
    // The iPhone tries to be "smart" about image orientation, and messes it
    // up in the process. Here, UIImageOrientationLeft happens when the
    // device is held upside down (camera on the end towards the ground).
    // UIImageOrientationRight happens when the camera is in a normal, upright
    // position. In both cases, the image is rotated 180 degrees from what
    // the user actually saw through the image preview.
    if (isFromITouchCamera && (image.imageOrientation == UIImageOrientationRight || image.imageOrientation == UIImageOrientationLeft)) {
        CGContextScaleCTM(bitmapContext, -1.0, -1);
        CGContextTranslateCTM(bitmapContext, -newWidth, -newHeight);
    }
    
    CGContextConcatCTM(bitmapContext, transform);
    CGContextDrawImage(bitmapContext, newRect, imageRef);
    
    newRef = CGBitmapContextCreateImage(bitmapContext);
    result = [UIImage imageWithCGImage:newRef scale:contentScale orientation:UIImageOrientationUp];
    CGContextRelease(bitmapContext);
    CGImageRelease(newRef);
    
    return result;
}
#endif

#pragma mark - String and File
+(NSString *) nameFromEmailString: (NSString *) emailStr
{
    NSString *ret = emailStr;
    if([ret rangeOfString:@"@"].location  != NSNotFound)
    {
        // DLog(@"truncating %@",emailStr);
        NSArray *tempArray1 = [ret componentsSeparatedByString: @"@"];
        ret = [tempArray1 objectAtIndex:0];
    }
    return ret;
}

+ (NSString *)randomStringOfLength:(NSUInteger)length {
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
    NSMutableString *result = [NSMutableString stringWithString:@""];
    for (NSUInteger i = 0; i < length; i++) {
        [result appendFormat:@"%c", [letters characterAtIndex:arc4random()%[letters length]]];
    }
    return result;
}

+ (void)uniquifyArray:(NSMutableArray *)array {
    NSUInteger location = [array count];
    for (NSObject *value in [array reverseObjectEnumerator]) {
        location -= 1;
        NSUInteger index = [array indexOfObject:value];
        if (index < location) {
            [array removeObjectAtIndex:location];
        }
    }
}


+ (NSString *)stringRepresentationOfDate:(NSDate *)aDate {
    return [Utilities stringRepresentationOfDate:aDate timeZone:[NSTimeZone defaultTimeZone]];
}

//
+ (NSString *) extension: (FileType) filetype
{
    NSString *ft;
    switch (filetype) {
        case FileTypeZIP:
            ft = @"zip";
            break;
            
        case FileTypePPTX:
            ft = @"pptx";
            break;
            
        case FileTypeJPEG:
            ft = @"jpg";
            break;
            
        case FileTypePNG:
            ft = @"png";
            break;
            
        case FileTypeGIF:
            ft = @"gif";
            break;
            
        case FileTypePPT:
            ft = @"ppt";
            break;
            
        case FileTypeDOC:
            ft = @"doc";
            break;
            
        case FileTypeXLS:
            ft = @"xls";
            break;
            
        case FileTypeRTF:
            ft = @"rtf";
            break;
            
        case FileTypeHTML:
            ft = @"html";
            break;
            
        case FileTypeText:
            ft = @"txt";
            break;
            
        case FileTypeSHSH:
            ft = @"shsh";
            break;
            
        default:
            ft = @"xxx";
            break;
    }
    return ft;
}

+ (NSString *) extensionFromName:(NSString *) filename
{
    NSRange fileextension = [filename rangeOfString: @"." options:NSBackwardsSearch];
    NSString *extension = @"";
    if ((fileextension.location != NSNotFound) && ((filename.length - fileextension.location) > 1)) {
        extension = [filename substringFromIndex:fileextension.location+1];
    }
    return extension;
}


// If the file begins with a leading '.', then it is a special file, remove the . and return the remaining  string
+ (NSString *) basenameIfDotfile: (NSString *) filename
{
    NSString *mainfile = nil;
    NSRange index = [filename rangeOfString:LOCK_PREFIX];
    if (index.location == 0) {
        mainfile = [filename substringFromIndex:(index.location+1)];
    }
    return mainfile;
}

// The the file ends with the special UTI (.shsh), then strip it from the end and return the name
+ (NSString *) basenameIfEncryptedfile: (NSString *) filename
{
    NSString *basefile = filename;
    NSRange encrypted = [filename rangeOfString: ENCRYPTED_FILE_UTI options:NSBackwardsSearch|NSCaseInsensitiveSearch];
    if ((encrypted.location != NSNotFound) &&
        (encrypted.location + [ENCRYPTED_FILE_UTI length]) == [filename length]) {
        basefile = [filename substringToIndex:encrypted.location];
    }
    return basefile;
}

// Take out the suffix like -1, -2, or -10 where the file name is filename.pdf-10
+ (NSString *) stripNumericSuffix: (NSString *) filename
{
    NSMutableString *newname = [NSMutableString stringWithString:filename];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:
                                  @"-([0-9]+$)" options:0 error:nil];
    
    [regex replaceMatchesInString:newname options:0 range:NSMakeRange(0, [filename length]) withTemplate:@""];
    return newname;
}

// Returns what kind of file is represented by the filename (only uses the extensions and such)
+ (NSString *) mimeType: (FileType) type
{
    NSString *mt;
    switch (type) {
        case FileTypeZIP:
            mt = @"application/zip";
            break;
            
        case FileTypePPTX:
            mt = @"application/vnd.openxmlformats-officedocument.presentationml.presentation";
            break;
            
        case FileTypeXLSX:
            mt = @"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
            break;
            
        case FileTypeDOCX:
            mt = @"application/vnd.openxmlformats-officedocument.wordprocessingml.document";
            break;
            
        case FileTypeJPEG:
            mt = @"image/jpeg";
            break;
            
        case FileTypePNG:
            mt = @"image/png";
            break;
            
        case FileTypeGIF:
            mt = @"image/gif";
            break;
            
        case FileTypePPT:
            mt = @"application/vnd.ms-powerpoint";
            break;
            
        case FileTypeDOC:
            mt = @"application/msword";
            break;
            
        case FileTypeRTF:
            mt = @"application/rtf";
            break;
            
        case FileTypeXLS:
            mt = @"application/vnd.ms-excel";
            break;
            
        case FileTypeHTML:
            mt = @"text/html";
            break;
            
        case FileTypeText:
            mt = @"text/plain";
            break;
            
        case FileTypeSHSH:
            mt = @"application/shsh";
            break;
            
        default:
            mt = @"application/shsh";
            break;
    }
    return mt;
}

// Returns what kind of file is represented by the filename (only uses the extensions and such)
+ (FileType) fileType: (NSString *) filename
{
    NSString *extension = [Utilities extensionFromName: filename];
    FileType ft;
    
    if (IS_EQUAL(extension, @"pdf"))  {
        ft = FileTypePDF;
    } else if (IS_EQUAL(extension, @"shsh")) {
        ft = FileTypeSHSH;
    } else if (IS_EQUAL(extension, @"zip")) {
        ft = FileTypeZIP;
    } else if (IS_EQUAL(extension, @"tiff") || IS_EQUAL(extension, @"tif")) {
        ft = FileTypeTIFF;
    } else if (IS_EQUAL(extension, @"jpg") || IS_EQUAL(extension, @"jpeg")) {
        ft = FileTypeJPEG;
    } else if (IS_EQUAL(extension, @"png")) {
        ft = FileTypePNG;
    } else if (IS_EQUAL(extension, @"gif")) {
        ft = FileTypeGIF;
    } else if (IS_EQUAL(extension, @"ppt")) {
        ft = FileTypePPT;
    } else if (IS_EQUAL(extension, @"doc")) {
        ft = FileTypeDOC;
    } else if (IS_EQUAL(extension, @"xls")) {
        ft = FileTypeXLS;
    } else if (IS_EQUAL(extension, @"docx")) {
        ft = FileTypeDOCX;
    } else if (IS_EQUAL(extension, @"pptx")) {
        ft = FileTypePPTX;
    } else if (IS_EQUAL(extension, @"xlsx")) {
        ft = FileTypeXLSX;
    } else if (IS_EQUAL(extension, @"rtf")) {
        ft = FileTypeRTF;
    } else if (IS_EQUAL(extension, @"html") ||
               IS_EQUAL(extension, @"htm")) {
        ft = FileTypeHTML;
    } else if (IS_EQUAL(extension, @"text") ||
               IS_EQUAL(extension, @"txt") ||
               ([extension length] == 0)) {
        ft = FileTypeText;
    } else if ([extension length] > 0) {
        ft = FileTypeUnknown;
    } else {
        ft = FileTypeNone;
    }
    return ft;
}

static NSDateFormatter *dateFormatter = nil;

+ (NSString *)stringRepresentationOfDate:(NSDate *)aDate timeZone:(NSTimeZone *)timeZone {
    NSString *result = nil;
    @synchronized(self) { // to avoid calendars stepping on themselves
        [Utilities setupDateFormatters];
        dateFormatter.timeZone = timeZone;
        NSString *dateString = [dateFormatter stringFromDate:aDate];
        
        NSInteger timeZoneOffset = [timeZone secondsFromGMT];
        NSString *sign = (timeZoneOffset >= 0) ? @"+" : @"-";
        NSInteger hoursOffset = abs((int)floor(timeZoneOffset/60/60));
        NSInteger minutesOffset = abs((int)floor(timeZoneOffset/60) % 60);
        NSString *timeZoneString = [NSString stringWithFormat:@"%@%.2d%.2d", sign, (int)hoursOffset, (int)minutesOffset];
        
        NSTimeInterval interval = [aDate timeIntervalSince1970];
        double fractionalSeconds = interval - (long)interval;
        
        // This is all necessary because of rdar://10500679 in which NSDateFormatter won't
        // format fractional seconds past two decimal places. Also, strftime() doesn't seem
        // to have fractional seconds on iOS.
        if (fractionalSeconds == 0.0) {
            result = [NSString stringWithFormat:@"%@ %@", dateString, timeZoneString];
        } else {
            NSString *f = [[NSString alloc] initWithFormat:@"%g", fractionalSeconds];
            NSRange r = [f rangeOfString:@"."];
            if (r.location != NSNotFound) {
                NSString *truncatedFloat = [f substringFromIndex:r.location + r.length];
                result = [NSString stringWithFormat:@"%@.%@ %@", dateString, truncatedFloat, timeZoneString];
            } else {
                // For some reason, we couldn't find the decimal place.
                result = [NSString stringWithFormat:@"%@.%ld %@", dateString, (long)(fractionalSeconds * 1000), timeZoneString];
            }
            f= nil;
        }
    }
    return result;
}

+ (NSDate *)dateFromISO8601String:(NSString *)string {
    BOOL validDate = YES;
    NSDate *result = nil;
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    calendar.firstWeekday = 2;
    calendar.timeZone = [NSTimeZone defaultTimeZone];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    NSDateComponents *nowComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    components.calendar = calendar;
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:string];
    NSString *ymdString = nil;
    [scanner scanUpToString:@"T" intoString:&ymdString];
    
    if (ymdString && [ymdString length]) {
        NSScanner *ymdScanner = [[NSScanner alloc] initWithString:ymdString];
        do { // once
            NSInteger month = 0;
            NSInteger day = 0;
            NSString *yearString = nil;
            if (![ymdScanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&yearString] || [yearString length] != 4) {
                validDate = NO;
                break;
            }
            components.year = [yearString integerValue];
            if (![ymdScanner scanString:@"-" intoString:NULL]) break;
            if (![ymdScanner scanInteger:&month]) break;
            components.month = month;
            if (![ymdScanner scanString:@"-" intoString:NULL]) break;
            if (![ymdScanner scanInteger:&day]) break;
            components.day = day;
        } while (NO);
        ymdScanner = nil;
    } else {
        [components setYear:[nowComponents year]];
        [components setMonth:[nowComponents month]];
        [components setDay:[nowComponents day]];
    }
    
    if ([scanner scanString:@"T" intoString:NULL]) {
        do { // once
            NSInteger hour = 0;
            NSInteger minute = 0;
            if (![scanner scanInteger:&hour]) {
                validDate = NO;
                break;
            }
            components.hour = hour;
            if (![scanner scanString:@":" intoString:NULL]) break;
            if (![scanner scanInteger:&minute]) break;
            components.minute = minute;
            if (![scanner scanString:@":" intoString:NULL]) break;
            double secondFraction = 0.0;
            if (![scanner scanDouble:&secondFraction]) break;
            components.second = (NSInteger)round(secondFraction);
        } while (NO);
    }
    
    if ([scanner scanString:@"Z" intoString:NULL]) {
        // Use UTC.
        components.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    } else {
        do { // once
            BOOL isPositiveOffset = YES;
            if ([scanner scanString:@"+" intoString:NULL]) {
                isPositiveOffset = YES;
            } else if ([scanner scanString:@"-" intoString:NULL]) {
                isPositiveOffset = NO;
            } else {
                if (![scanner isAtEnd]) {
                    validDate = NO;
                }
                break;
            }
            NSInteger hours = 0;
            NSInteger minutes = 0;
            if (!([scanner scanInteger:&hours] && [scanner scanString:@":" intoString:NULL] && [scanner scanInteger:&minutes])) {
                validDate = NO;
                break;
            }
            NSInteger secondsFromGMT = hours*3600 + minutes*60;
            if (!isPositiveOffset) {
                secondsFromGMT = secondsFromGMT * -1;
            }
            components.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:secondsFromGMT];
        } while (NO);
    }
    
    calendar = nil;
    scanner = nil;
    if (validDate) {
        result = [components date];
    }
    components = nil;
    return result;
}



#pragma mark - phone numbers
// Strip - and opening and closing parenthesis
+ (NSString *) formatPhoneNumber: (NSString *) phoneString
{
    NSError *error = NULL;
    
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"([ \\b\\(\\-\\)])" // @"([^0-9])" //
                                  options:NSRegularExpressionCaseInsensitive
                                  error:&error];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:phoneString
                                
                                                               options:0
                                
                                                                 range:NSMakeRange(0, [phoneString length])
                                
                                                          withTemplate:@""];
    return modifiedString;
}

+ (CGRect) applicationFrame
{
    // Start with the screen size and adjust for the landscape if necessary
    CGRect maxFrame = [UIScreen mainScreen].bounds; // applicationFrame;
    
#ifdef ISITREQUIRED // ios8
                    // If the orientation is landscape left or landscape right then swap the width and height
    BOOL isLandscape = ([[UIApplication sharedApplication] statusBarOrientation] != UIDeviceOrientationPortrait);
    if (isLandscape) {
        CGFloat temp = maxFrame.size.height;
        maxFrame.size.height = maxFrame.size.width;
        maxFrame.size.width = temp;
    }
#endif
    
    return maxFrame;
}

#ifdef NOTNOW
+ (CGRect) bounds: (UIViewController *) vc {
    CGRect maxBounds = [Utilities frame:vc];
    maxBounds.origin.x = 0;
    maxBounds.origin.y = 0;
    return maxBounds;
}

+ (CGRect) frame: (UIViewController *) vc {
    
    static CGFloat const kNavigationBarPortraitHeight = 44;
    static CGFloat const kNavigationBarLandscapeHeight = 34;
    static CGFloat const kToolBarHeight = 49;
    
    // Start with the screen size minus the status bar if present
    CGRect maxFrame = [UIScreen mainScreen].applicationFrame;
    
    // If the orientation is landscape left or landscape right then swap the width and height
    if (UIInterfaceOrientationIsLandscape(vc.interfaceOrientation)) {
        CGFloat temp = maxFrame.size.height;
        maxFrame.size.height = maxFrame.size.width;
        maxFrame.size.width = temp;
    }
    
    // Take into account if there is a navigation bar present and visible (note that if the NavigationBar may
    // not be visible at this stage in the view controller's lifecycle.  If the NavigationBar is shown/hidden
    // in the loadView then this provides an accurate result.  If the NavigationBar is shown/hidden using the
    // navigationController:willShowViewController: delegate method then this will not be accurate until the
    // viewDidAppear method is called.
    if (vc.navigationController) {
        if (vc.navigationController.navigationBarHidden == NO) {
            
            // Depending upon the orientation reduce the height accordingly
            if (UIInterfaceOrientationIsLandscape(vc.interfaceOrientation)) {
                maxFrame.size.height -= kNavigationBarLandscapeHeight;
            }
            else {
                maxFrame.size.height -= kNavigationBarPortraitHeight;
            }
        }
    }
    
    // Take into account if there is a toolbar present and visible
    if (vc.tabBarController) {
        if (!vc.tabBarController.view.hidden) maxFrame.size.height -= kToolBarHeight;
    }
    return maxFrame;
}
#endif

// Strip the type name and provide the basename
+ (NSString *) basename: (NSString *) filename
{
    NSArray *chunks = [filename componentsSeparatedByString: @"."];
    return [chunks objectAtIndex:0];
}

// Strip the type name and provide the basename // Is this Correct?  Returns dirPathName
+ (NSString *) basePathName: (NSString *) pathKey
{
    NSRange separator = [pathKey rangeOfString: @":" options:NSBackwardsSearch];
    NSString *dir = @"";
    if ((separator.location != NSNotFound) && ((pathKey.length - separator.location) > 1)) {
        dir = [pathKey substringToIndex:separator.location];
    }
    return dir;
    
}

// Strip the type name and provide the basename
// drive#test_folder#autohtml#sandeep00411.htm will return sandeep00411.htm
+ (NSString *) baseCacheFileName: (NSString *) cacheFileName
{
    NSRange separator = [cacheFileName rangeOfString: @"#" options:NSBackwardsSearch];
    NSString *file = cacheFileName;
    if ((separator.location != NSNotFound) && ((cacheFileName.length - separator.location) > 1)) {
        file = [cacheFileName substringFromIndex:separator.location+1];
    }
    return file;
    
}

// Strip the name and provide the directory Path name - if there is no '#', the dir name is @""
// drive#test_folder#autohtml#sandeep00411.htm will return drive#test_folder#autohtml
+ (NSString *) dirCacheFileName: (NSString *) cacheFileName
{
    NSRange separator = [cacheFileName rangeOfString: @"#" options:NSBackwardsSearch];
    NSString *file = @"";
    if ((separator.location != NSNotFound) && ((cacheFileName.length - separator.location) > 1)) {
        file = [cacheFileName substringToIndex:separator.location];
    }
    return file;
    
}


+ (UIImage*)createGradientImageFromColor:(UIColor *)startColor toColor:(UIColor *)endColor withSize:(CGSize)size {
    
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGRect fillRect = CGRectMake(0,0,size.width,size.height);
    drawLinearGradient(currentContext, fillRect, startColor.CGColor, endColor.CGColor);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}



void drawLinearGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef endColor)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    NSArray *colors = @[(__bridge id) startColor, (__bridge id) endColor];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextSaveGState(context);
    CGContextAddRect(context, rect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

+ (NSString*)getTimeAsString:(NSDate *)lastDate {
    NSTimeInterval dateDiff =  [[NSDate date] timeIntervalSinceDate:lastDate];
    
    int nrSeconds = dateDiff;//components.second;
    int nrMinutes = nrSeconds / 60;
    int nrHours = nrSeconds / 3600;
    int nrDays = dateDiff / 86400; //components.day;
    
    NSString *time;
    if (nrDays > 5){
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateStyle:NSDateFormatterShortStyle];
        [dateFormat setTimeStyle:NSDateFormatterNoStyle];
        
        time = [NSString stringWithFormat:@"%@", [dateFormat stringFromDate:lastDate]];
    } else {
        // days=1-5
        if (nrDays > 0) {
            if (nrDays == 1) {
                time = @"1 day ago";
            } else {
                time = [NSString stringWithFormat:@"%d days ago", nrDays];
            }
        } else {
            if (nrHours == 0) {
                if (nrMinutes < 2) {
                    time = @"just now";
                } else {
                    time = [NSString stringWithFormat:@"%d minutes ago", nrMinutes];
                }
            } else { // days=0 hours!=0
                if (nrHours == 1) {
                    time = @"1 hour ago";
                } else {
                    time = [NSString stringWithFormat:@"%d hours ago", nrHours];
                }
            }
        }
    }
    
    return [NSString stringWithFormat:NSLocalizedString(@"%@", @"label"), time];
}

+ (void)showError:(NSString*)errorMessage
{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [alertView show];
    });
}

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
                            andDelegate: (NSObject <MobiusoActionViewDelegate> *) actionDelegate
{
    MobiusoActionView *view = [[MobiusoActionView alloc] initWithTitle: title
                                                              delegate: actionDelegate
                                                            andMessage: message
                                                       placeholderText: placeHolder
                                                     cancelButtonTitle: cancelStr
                                                     otherButtonTitles: buttonArray
                                                                 color: color
                                                                 frame: parentView.bounds];
    [parentView addSubview:view];
    actionDelegate.currentActionViewId = tag;
    return view;
}

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
                                      andDelegate: (NSObject <MobiusoActionViewDelegate> *) actionDelegate
{
    MobiusoVideoActionView *view = [[MobiusoVideoActionView alloc] initWithTitle: title
                                                                        delegate: actionDelegate
                                                                      andMessage: message
                                                                 placeholderText: placeHolder
                                                               cancelButtonTitle: cancelStr
                                                               otherButtonTitles: buttonArray
                                                                           color: color
                                                                      background:backgroundAsset];
    [parentView addSubview:view];
    actionDelegate.currentActionViewId = tag;
    return view;
}

// Given a view rectangle - provide the necessary blurView to use
+ (UIVisualEffectView *) addBlurVibrancyView: (CGRect) frame options: (BOOL) notificationCenter
{
#if 0 // Reference
    UIBlurEffect * effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView * viewWithBlurredBackground = [[UIVisualEffectView alloc] initWithEffect:effect];
    
    UIVisualEffectView * viewInducingVibrancy =
    [[UIVisualEffectView alloc] initWithEffect:effect]; // must be the same effect as the blur view
    [viewWithBlurredBackground.contentView addSubview:viewInducingVibrancy];
    UILabel * vibrantLabel = [UILabel new];
    // Set the text and the position of your label
    [viewInducingVibrancy.contentView addSubview:vibrantLabel];
#endif
    
    UIBlurEffect * effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVibrancyEffect * notificationeffect = [UIVibrancyEffect notificationCenterVibrancyEffect];
    UIVisualEffectView * selectedBackgroundView = [[UIVisualEffectView alloc] initWithEffect:(notificationCenter? notificationeffect : effect)];
    selectedBackgroundView.autoresizingMask =
    UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    selectedBackgroundView.frame = frame;
    UIView * view = [[UIView alloc] initWithFrame:selectedBackgroundView.bounds];
    view.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    view.autoresizingMask =
    UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [selectedBackgroundView.contentView addSubview:view];
    return selectedBackgroundView;
}

#pragma mark - Decompress
+ (BOOL) decompress: (NSString *)zippedFilePath toDestinationPath: (NSString *) destinationPath
{
    BOOL success = NO;
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    if([zipArchive UnzipOpenFile:zippedFilePath])
    {
        
        if ([zipArchive UnzipFileTo:destinationPath overWrite:YES])
        {
            success = YES;
        }
        
    }
    return success;
}



#ifdef DEBUG
+ (void) printFontNames
{
    for (NSString* family in [UIFont familyNames])
    {
        DLog(@"%@", family);
        
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            DLog(@"  %@", name);
        }
    }

}
#endif

@end

@implementation Utilities (Private)
+ (void)setupDateFormatters {
    @synchronized(self) {
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            NSLocale *enUSLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            [dateFormatter setLocale:enUSLocale];
            [dateFormatter setCalendar:calendar];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        }
    }
}

@end

