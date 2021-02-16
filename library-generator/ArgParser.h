//
//  ArgParser.h
//  library-generator
//
//  Created by Kyle King on 2021-02-15.
//

#import <Foundation/Foundation.h>

#import "LGDefines.h"


NS_ASSUME_NONNULL_BEGIN

@class XPMArgumentSignature;
@class ExportConfiguration;

@interface ArgParser : NSObject


#pragma mark - Properties

@property (readonly) NSDictionary* parsed;

@property (readonly) NSProcessInfo* processInfo;

@property (readonly) LGCommandKind command;
@property (nullable, readonly) NSString* commandError;

@property (readonly) NSString* optionsError;
@property (nullable, readonly) NSArray<NSString*>* optionsWithErrors;


#pragma mark - Initializers

- (instancetype)initWithProcessInfo:(NSProcessInfo*)processInfo;

+ (instancetype)parserWithProcessInfo:(NSProcessInfo*)processInfo;


#pragma mark - Accessors

- (nullable XPMArgumentSignature*)signatureForCommand:(LGCommandKind)command;
- (nullable XPMArgumentSignature*)signatureForOption:(LGOptionKind)option;

- (NSSet<NSNumber*>*)determineCommandTypes;

- (void)displayHelp;

- (void)dumpArguments;


#pragma mark - Mutators

- (void)initMemberSignatures;

- (void)parse;

- (BOOL)validateCommand;
- (BOOL)validateOptions;

- (BOOL)populateExportConfiguration:(ExportConfiguration*)configuration;


@end

NS_ASSUME_NONNULL_END
