//
//  EncryptionUtilities.h
//  FlashDrive
//
//  Created by sandeep on 3/23/15.
//  Copyright (c) 2015 Skyscape. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EncryptionUtilities : NSObject


// Encryption
+ (NSString *) factoryPassword;
+ (BOOL) isFactoryPassword: (NSString *) password;
+ (BOOL) encryptFile:(NSString *) filePath withPassword: (NSString *) password andContent: (NSString *) content;
+ (NSData *) decryptFile: (NSString *) filePath withPassword: (NSString *) password;
+ (NSData *) decrypt: (NSData *) encryptedData withPassword: (NSString *) password;
+ (BOOL) match: (NSData *) encryptedData withPassword: (NSString *) password;
+ (NSData *) encrypt: (NSData *) rawContentData withPassword: (NSString *) password;


/*
 *
 *  In the first version
 *  2 bytes version #
 *  2 bytes password hash header len (N)
 *  N bytes password hash encrypted
 *  * remaing bytes are the actual encrypted file
 *
 *  (This is true even for a fragments in memory or other locations where encrypted data is saved)
 *
 */
#define ENCRYPTED_FILE_FORMAT_VERSION   1

@end
