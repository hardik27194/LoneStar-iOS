//
//  EncryptionUtilities.m
//  FlashDrive
//
//  Created by sandeep on 3/23/15.
//  Copyright (c) 2015 Skyscape. All rights reserved.
//
//  Refactored from Utilities and DropboxUtil
//  New additions for supporting Encryption support for HIPPA compliance and privacy reasons
//

#import "EncryptionUtilities.h"
#import "RNEncryptor.h"
#import "RNDecryptor.h"
#import "Utilities.h"

@implementation EncryptionUtilities

// Update the content portion of a file, leaving the rest intact
+ (BOOL) encryptFile:(NSString *) filePath withPassword: (NSString *) password andContent: (NSString *) content
{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath error:&error];
    
    if ((error) || (fileAttributes == nil)) {
        return NO;
    }
    NSData *encryptedData = [fileManager contentsAtPath:filePath];
    
    short passlen; short version;
    
    [encryptedData getBytes: &version length: sizeof(short)];
    [encryptedData getBytes: &passlen range:NSMakeRange(sizeof(short), sizeof(short))];
    
    NSData *encryptedHeaderData = [encryptedData subdataWithRange:NSMakeRange(0, passlen + sizeof(passlen)+sizeof(version))];
    
    // Now writeBack the original part
    // PART 1 - [file writeData:encryptedHeaderData error:&error];
    
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedNewData = [RNEncryptor encryptData:data
                                           withSettings:kRNCryptorAES256Settings
                                               password:password
                                                  error:&error];
    // PART 2 - [file appendData:encryptedNewData error:&error];
    
    NSMutableData *newFileData = [NSMutableData dataWithData:encryptedHeaderData];
    [newFileData appendData:encryptedNewData];
    
    [newFileData writeToFile:filePath atomically:YES];
    
    return (error==nil);
    
}

// Decrypt a given file
+ (NSData *) decryptFile: (NSString *) filePath withPassword: (NSString *) password
{
    NSData *encryptedData = [Utilities readData:filePath];
    return [self decrypt: encryptedData withPassword:password];
}

//
// Given a password, provide the data encrypted using the current version methods
//  If new version is added, make it upward compatible with support to encrypt or
//  decrypt older versions.

+ (NSData *) decrypt: (NSData *) encryptedData withPassword: (NSString *) password
{
    short passlen; short version;
    NSError *error = nil;
    
    @try {
        [encryptedData getBytes: &version length: sizeof(short)];
        [encryptedData getBytes: &passlen range:NSMakeRange(sizeof(short), sizeof(short))];
        
        NSString *passwordHash = [[Utilities getMD5Hash:[Utilities getSHA1Hash:password]] copy];
        NSData *passdata = [passwordHash dataUsingEncoding:NSUTF8StringEncoding];
        NSData *encryptedHeaderData = [encryptedData subdataWithRange:NSMakeRange(sizeof(passlen)+sizeof(version), passlen)];
        NSData *decryptedHeaderData = [RNDecryptor decryptData:encryptedHeaderData
                                                  withPassword:password
                                                         error:&error];
        // compare the initial bytes of the encrypted Data to match the password supplied (hashed/encrypted)
        if (decryptedHeaderData && (error ==nil)) {
            NSInteger   plen = passlen + sizeof(version) + sizeof(passlen);
            NSInteger   flen = [encryptedData length];
            if ([passdata isEqualToData: decryptedHeaderData]) {
                
                // We are good to go, return the remaining data...
                NSData *mainEncryptedData = [encryptedData subdataWithRange:NSMakeRange(plen, flen - plen)];
                NSData *decryptedData = [RNDecryptor decryptData:mainEncryptedData
                                                    withPassword:password
                                                           error:&error];
                return decryptedData;
            }
        } else {
            return nil;
        }
    }
    @catch (NSException *exception) {
        DLog(@"Error Occured %@ (reason: %@)", [exception name], [exception reason]);
        return nil;
    }
}
// Encryption
+ (NSString *) factoryPassword
{
    return DOWNLOAD_FILE_PASS_PHRASE;
}

+ (BOOL) isFactoryPassword: (NSString *) password
{
    return ([password compare: [self factoryPassword] options:NSCaseInsensitiveSearch] == NSOrderedSame);
}

// Inspect the given file to check if the password is correct
+ (BOOL) match: (NSData *) encryptedData withPassword: (NSString *) password
{
    NSError *error;
    
    // We don't need to read the whole data set, but Dropbox has a limitation for now...
    //    NSData *encryptedData = [file readData:&error];
    
    short passlen; short version;
    
    @try {
        
        [encryptedData getBytes: &version length: sizeof(short)];
        
        [encryptedData getBytes: &passlen range:NSMakeRange(sizeof(short), sizeof(short))];
        
        NSString *passwordHash = [[Utilities getMD5Hash:[Utilities getSHA1Hash:password]] copy];
        NSData *passdata = [passwordHash dataUsingEncoding:NSUTF8StringEncoding];
        NSData *encryptedHeaderData = [encryptedData subdataWithRange:NSMakeRange(sizeof(passlen)+sizeof(version), passlen)];
        NSData *decryptedHeaderData = [RNDecryptor decryptData:encryptedHeaderData
                                                  withPassword:password
                                                         error:&error];
        encryptedData = nil;
        if (decryptedHeaderData && (error ==nil)) {
            // compare the initial bytes of the encrypted Data to match the password supplied (hashed/encrypted)
            return [passdata isEqualToData: decryptedHeaderData];
        } else {
            return NO;
        }
    }
    @catch (NSException *exception) {
        DLog(@"Error Occured %@ (reason: %@)", [exception name], [exception reason]);
        return NO;
    }
    
}

//
// Given a password, provide the data encrypted using the current version methods
//  If new version is added, make it upward compatible with support to encrypt or
//  decrypt older versions.
+ (NSData *) encrypt: (NSData *) rawContentData withPassword: (NSString *) password
{
    NSError *error = nil;
    
    NSData *encryptedContentData = [RNEncryptor encryptData:rawContentData
                                               withSettings:kRNCryptorAES256Settings
                                                   password:password
                                                      error:&error];
    
    //--------
    NSString *passwordHash = [[Utilities getMD5Hash:[Utilities getSHA1Hash:password]] copy];
    NSData *passdata = [passwordHash dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *encryptedPassData = [RNEncryptor encryptData: passdata
                                            withSettings:kRNCryptorAES256Settings
                                                password:password
                                                   error:&error];
    
    
    //--------
    short version = ENCRYPTED_FILE_FORMAT_VERSION;
    NSData *versionData = [NSData dataWithBytes: &version length: sizeof(version)];
    
    //--------
    short size = [encryptedPassData length];
    NSData *sizeData = [NSData dataWithBytes: &size length: sizeof(size)];
    
    // First write headerData so that the user's supplied password can be compared
    // NOTE: The password itself is not saved - it is a one-way hash using the original password
    //       so as to ascertain if the supplied password is correct
    NSMutableData *encryptedData = [NSMutableData dataWithData:versionData];
    [encryptedData appendData:sizeData];
    [encryptedData appendData:encryptedPassData];
    [encryptedData appendData:encryptedContentData];
    
    return encryptedData;
}



@end
