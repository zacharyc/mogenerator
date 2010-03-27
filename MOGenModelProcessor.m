#import "MOGenModelProcessor.h"
#import "MiscMergeEngine.h"
#import "MiscMergeTemplate.h"
#import "nsenumerate.h"
#import "FoundationAdditions.h"
#import "NSXReturnThrowError.h"

@interface MiscMergeEngine (engineWithTemplatePath)
+ (id)engineWithTemplatePath:(NSString*)templatePath_;
@end

@interface MOGenModelProcessor (Implementation)
- (NSString*)appSupportFileNamed:(NSString*)fileName_
              inTemplatesDirPath:(NSString*)templatesDirPath_
                   templateGroup:(NSString*)templateGroup_
                           error:(NSError**)error_;
@end

@implementation MOGenModelProcessor
- (MOGenModelProcessorResult*)processEntities:(NSArray*)entities_ /** @TypeInfo NSEntityDescription */
                              generatingFiles:(BOOL)genFiles_
                             templatesDirPath:(NSString*)templatesDirPath_
                                templateGroup:(NSString*)templateGroup_
                                     humanDir:(NSString*)humanDir_
                                   machineDir:(NSString*)machineDir_
                                        error:(NSError**)error_
{
    NSError *error = nil;
    
    MOGenModelProcessorResult *result = [[[MOGenModelProcessorResult alloc] init] autorelease];
    
    MiscMergeEngine *machineH = nil;
    if (!error) {
        machineH = [MiscMergeEngine engineWithTemplatePath:[self appSupportFileNamed:@"machine.h.motemplate"
                                                                  inTemplatesDirPath:templatesDirPath_
                                                                       templateGroup:templateGroup_
                                                                               error:&error]];
        NSXReturnError(machineH);
    }
    
    MiscMergeEngine *machineM = nil;
    if (!error) {
        machineM = [MiscMergeEngine engineWithTemplatePath:[self appSupportFileNamed:@"machine.m.motemplate"
                                                                  inTemplatesDirPath:templatesDirPath_
                                                                       templateGroup:templateGroup_
                                                                               error:&error]];
        NSXReturnError(machineM);
    }
    
    MiscMergeEngine *humanH = nil;
    if (humanH) {
        humanH = [MiscMergeEngine engineWithTemplatePath:[self appSupportFileNamed:@"human.h.motemplate"
                                                                inTemplatesDirPath:templatesDirPath_
                                                                     templateGroup:templateGroup_
                                                                             error:&error]];
        NSXReturnError(humanH);
    }
    
    MiscMergeEngine *humanM = nil;
    if (!error) {
        humanM = [MiscMergeEngine engineWithTemplatePath:[self appSupportFileNamed:@"human.m.motemplate"
                                                                inTemplatesDirPath:templatesDirPath_
                                                                     templateGroup:templateGroup_
                                                                             error:&error]];
        NSXReturnError(humanM);
    }
    
    if (!error) {
        NSFileManager *fm = [NSFileManager defaultManager];
        
        nsenumerate (entities_, NSEntityDescription, entity) {
            NSString *generatedMachineH = [machineH executeWithObject:entity sender:nil];
            NSString *generatedMachineM = [machineM executeWithObject:entity sender:nil];
            NSString *generatedHumanH = [humanH executeWithObject:entity sender:nil];
            NSString *generatedHumanM = [humanM executeWithObject:entity sender:nil];
            
            NSString *entityClassName = [entity managedObjectClassName];
            BOOL machineDirtied = NO;
            
            // Machine header files.
            NSString *machineHFileName = [machineDir_ stringByAppendingPathComponent:
                                          [NSString stringWithFormat:@"_%@.h", entityClassName]];
            [result->machineHFiles addObject:machineHFileName];
            if (genFiles_
                && (![fm regularFileExistsAtPath:machineHFileName]
                    || ![generatedMachineH isEqualToString:[NSString stringWithContentsOfFile:machineHFileName]]))
            {
                //	If the file doesn't exist or is different than what we just generated, write it out.
                [generatedMachineH writeToFile:machineHFileName atomically:NO];
                machineDirtied = YES;
                result->machineFilesGenerated++;
            }
            
            // Machine source files.
            NSString *machineMFileName = [machineDir_ stringByAppendingPathComponent:
                                          [NSString stringWithFormat:@"_%@.m", entityClassName]];
            [result->machineMFiles addObject:machineMFileName];
            if (genFiles_
                && (![fm regularFileExistsAtPath:machineMFileName]
                    || ![generatedMachineM isEqualToString:[NSString stringWithContentsOfFile:machineMFileName]]))
            {
                //	If the file doesn't exist or is different than what we just generated, write it out.
                [generatedMachineM writeToFile:machineMFileName atomically:NO];
                machineDirtied = YES;
                result->machineFilesGenerated++;
            }
            
            // Human header files.
            NSString *humanHFileName = [humanDir_ stringByAppendingPathComponent:
                                        [NSString stringWithFormat:@"%@.h", entityClassName]];
            [result->humanHFiles addObject:humanHFileName];
            if (genFiles_) {
                if ([fm regularFileExistsAtPath:humanHFileName]) {
                    if (machineDirtied)
                        [fm touchPath:humanHFileName];
                } else {
                    [generatedHumanH writeToFile:humanHFileName atomically:NO];
                    result->humanFilesGenerated++;
                }
            }
            
            //	Human source files.
            NSString *humanMFileName = [humanDir_ stringByAppendingPathComponent:
                                        [NSString stringWithFormat:@"%@.m", entityClassName]];
            NSString *humanMMFileName = [humanDir_ stringByAppendingPathComponent:
                                         [NSString stringWithFormat:@"%@.mm", entityClassName]];
            if (![fm regularFileExistsAtPath:humanMFileName] && [fm regularFileExistsAtPath:humanMMFileName]) {
                //	Allow .mm human files as well as .m files.
                humanMFileName = humanMMFileName;
            }
            [result->humanMFiles addObject:humanMFileName];
            if (genFiles_) {
                if ([fm regularFileExistsAtPath:humanMFileName]) {
                    if (machineDirtied)
                        [fm touchPath:humanMFileName];
                } else {
                    [generatedHumanM writeToFile:humanMFileName atomically:NO];
                    result->humanFilesGenerated++;
                }
            }
            
            /*[mfileContent appendFormat:@"#include \"%@\"\n#include \"%@\"\n",
             [humanMFileName lastPathComponent], [machineMFileName lastPathComponent]];*/
        }
    }
    
    if (error_) {
        *error_ = error;
    }
	
	return result;
}

- (NSString*)appSupportFileNamed:(NSString*)fileName_
              inTemplatesDirPath:(NSString*)templatesDirPath_
                   templateGroup:(NSString*)templateGroup_
                           error:(NSError**)error_
{
    NSString *ApplicationSupportSubdirectoryName = @"mogenerator";
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isDirectory;
	
	if (templatesDirPath_) {
		if ([fileManager fileExistsAtPath:templatesDirPath_ isDirectory:&isDirectory] && isDirectory) {
			return [templatesDirPath_ stringByAppendingPathComponent:fileName_];
		}
	} else {
		NSArray *appSupportDirectories = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask+NSLocalDomainMask, YES);
		assert(appSupportDirectories);
		
		nsenumerate (appSupportDirectories, NSString*, appSupportDirectory) {
			if ([fileManager fileExistsAtPath:appSupportDirectory isDirectory:&isDirectory]) {
				NSString *appSupportSubdirectory = [appSupportDirectory stringByAppendingPathComponent:ApplicationSupportSubdirectoryName];
				if (templateGroup_) {
					appSupportSubdirectory = [appSupportSubdirectory stringByAppendingPathComponent:templateGroup_];
				}
				if ([fileManager fileExistsAtPath:appSupportSubdirectory isDirectory:&isDirectory] && isDirectory) {
					NSString *appSupportFile = [appSupportSubdirectory stringByAppendingPathComponent:fileName_];
					if ([fileManager fileExistsAtPath:appSupportFile isDirectory:&isDirectory] && !isDirectory) {
						return appSupportFile;
					}
				}
			}
		}
	}
    
    if (error_) {
        *error_ = [NSError errorWithDomain:NSOSStatusErrorDomain
                                      code:fnfErr
                                  userInfo:<#(NSDictionary *)dict#>];
    }
	return nil;
}

@end

@implementation MOGenModelProcessorResult

- (id)init {
	self = [super init];
	if (self) {
		humanMFiles = [[NSMutableArray alloc] init];
		humanHFiles = [[NSMutableArray alloc] init];
		machineMFiles = [[NSMutableArray alloc] init];
		machineHFiles = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc {
	[humanMFiles release];
	[humanHFiles release];
	[machineMFiles release];
	[machineHFiles release];
	[super dealloc];
}

@end

@implementation MiscMergeEngine (engineWithTemplatePath)
+ (id)engineWithTemplatePath:(NSString*)templatePath_ {
	MiscMergeTemplate *template = [[[MiscMergeTemplate alloc] init] autorelease];
	[template setStartDelimiter:@"<$" endDelimiter:@"$>"];
	[template parseContentsOfFile:templatePath_];
	return [[[self alloc] initWithTemplate:template] autorelease];
}
@end