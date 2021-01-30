//
//  ExportConfiguration.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExportConfiguration : NSObject {

  NSString* _outputDirectoryPath;
  NSString* _outputFileName;

  BOOL _remapRootDirectory;
  NSString* _remapRootDirectoryOriginalPath;
  NSString* _remapRootDirectoryMappedPath;

  BOOL _scheduleEnabled;
}

- (instancetype)init;

- (instancetype)initWithUserDefaults;

- (NSString*)ouputDirectoryPath;
- (NSString*)ouputFileName;
- (nullable NSString*)outputFilePath;

- (BOOL)remapRootDirectory;
- (NSString*)remapRootDirectoryOriginalPath;
- (NSString*)remapRootDirectoryMappedPath;

- (BOOL)scheduleEnabled;

- (void)setOutputDirectoryPath:(NSString*)path;
- (void)setOutputFileName:(NSString*)fileName;

- (void)setRemapRootDirectory:(BOOL)flag;
- (void)setRemapRootDirectoryOriginalPath:(NSString*)originalPath;
- (void)setRemapRootDirectoryMappedPath:(NSString*)mappedPath;

- (void)setScheduleEnabled:(BOOL)flag;

- (void)setValuesFromUserDefaults;

@end

NS_ASSUME_NONNULL_END
