/*******************************************************************************
	mogenerator.m - <http://github.com/rentzsch/mogenerator>
		Copyright (c) 2006-2010 Jonathan 'Wolf' Rentzsch: <http://rentzsch.com>
		Some rights reserved: <http://opensource.org/licenses/mit-license.php>

	***************************************************************************/

#import "mogenerator.h"

@interface MOGeneratorApp (Implementation)
- (void)handleHelpAndReturnError:(NSError**)error_;
- (void)handleVersionAndReturnError:(NSError**)error_;
- (void)handleListSourceFilesAndReturnError:(NSError**)error_;
- (void)handleOrphanedAndReturnError:(NSError**)error_;
- (void)handleGenerationAndReturnError:(NSError**)error_;
@end

@implementation MOGeneratorApp

- (int)application:(DDCliApplication*)app runWithArguments:(NSArray*)arguments {
	NSError *error = nil;
	
    if (help) {
        [self handleHelpAndReturnError:&error];
    } else if (version) {
		[self handleVersionAndReturnError:&error];
	} else if (listSourceFiles) {
		[self handleListSourceFilesAndReturnError:&error];
	} else if (orphaned) {
		[self handleOrphanedAndReturnError:&error];
	} else {
		[self handleGenerationAndReturnError:&error];
	}
	
	if (error) {
		JRLogNSError(error);
		return EXIT_FAILURE;
	} else {
		return EXIT_SUCCESS;
	}
	
	
#if 0
	
    
    gCustomBaseClass = [baseClass retain];
    NSString * mfilePath = includem;
	NSMutableString * mfileContent = [NSMutableString stringWithString:@""];
    if (outputDir == nil)
        outputDir = [fm currentDirectoryPath];
    if (machineDir == nil)
        machineDir = outputDir;
    if (humanDir == nil)
        humanDir = outputDir;
	
	if (_orphaned) {
		NSMutableDictionary *entityFilesByName = [NSMutableDictionary dictionary];
		
		NSArray *srcDirs = [NSArray arrayWithObjects:machineDir, humanDir, nil];
		nsenumerate(srcDirs, NSString, srcDir) {
			if (![srcDir length]) {
				srcDir = [fm currentDirectoryPath];
			}
			nsenumerate([fm subpathsAtPath:srcDir], NSString, srcFileName) {
#define MANAGED_OBJECT_SOURCE_FILE_REGEX	@"_?([a-zA-Z0-9_]+MO).(h|m|mm)" // Sadly /^(*MO).(h|m|mm)$/ doesn't work.
				if ([srcFileName isMatchedByRegex:MANAGED_OBJECT_SOURCE_FILE_REGEX]) {
					NSString *entityName = [[srcFileName captureComponentsMatchedByRegex:MANAGED_OBJECT_SOURCE_FILE_REGEX] objectAtIndex:1];
					if (![entityFilesByName objectForKey:entityName]) {
						[entityFilesByName setObject:[NSMutableSet set] forKey:entityName];
					}
					[[entityFilesByName objectForKey:entityName] addObject:srcFileName];
				}
			}
		}
		nsenumerate ([model entitiesWithACustomSubclassVerbose:NO], NSEntityDescription, entity) {
			[entityFilesByName removeObjectForKey:[entity managedObjectClassName]];
		}
		nsenumerate(entityFilesByName, NSSet, ophanedFiles) {
			nsenumerate(ophanedFiles, NSString, ophanedFile) {
				ddprintf(@"%@\n", ophanedFile);
			}
		}
		
		return EXIT_SUCCESS;
	}
    
	MOGenProcessingResults processingResults = [[[MOGenProcessingResults alloc] init] autorelease];
	if (model) {
		NSArray *customizedEntities = [model entitiesWithACustomSubclassVerbose:!_listSourceFiles];
		processingResults = [self processEntities:customizedEntities generatingFiles:!_listSourceFiles];
	}
	
	if (tempMOMPath) {
		[fm removeFileAtPath:tempMOMPath handler:nil];
	}
	
	//	include.m file.
	bool mfileGenerated = NO;
	if (mfilePath && ![mfileContent isEqualToString:@""]) {
		[mfileContent writeToFile:mfilePath atomically:NO];
		mfileGenerated = YES;
	}
	
	if (_listSourceFiles) {
		NSArray *filesList = [NSArray arrayWithObjects:humanMFiles, humanHFiles, machineMFiles, machineHFiles, nil];
		nsenumerate (filesList, NSArray, files) {
			nsenumerate (files, NSString, fileName) {
				ddprintf(@"%@\n", fileName);
			}
		}
	} else {
		printf("%d machine files%s %d human files%s generated.\n", processingResults->machineFilesGenerated,
			   (mfileGenerated ? "," : " and"), humanFilesGenerated, (mfileGenerated ? " and one include.m file" : ""));
	}
	
	return EXIT_SUCCESS;
#endif
}

- (void)handleHelpAndReturnError:(NSError**)error_ {
	JRLogInfo(@"%@: Usage [OPTIONS] <argument> [...]\n", DDCliApp);
	JRLogInfo(@"\n"
			  "  -m, --model MODEL             Path to model\n"
			  "      --base-class CLASS        Custom base class\n"
			  "      --includem FILE           Generate aggregate include file\n"
			  "      --template-path PATH      Path to templates\n"
			  "      --template-group NAME     Name of template group\n"
			  "  -O, --output-dir DIR          Output directory\n"
			  "  -M, --machine-dir DIR         Output directory for machine files\n"
			  "  -H, --human-dir DIR           Output directory for human files\n"
			  "      --list-source-files		Only list model-related source files\n"
			  "      --orphaned                Only list files whose entities no longer exist\n"
			  "      --version                 Display version and exit\n"
			  "  -h, --help                    Display this help and exit\n"
			  "\n"
			  "Implements generation gap codegen pattern for Core Data.\n"
			  "Inspired by eogenerator.\n");
}

- (void)handleVersionAndReturnError:(NSError**)error_ {
	JRLogInfo(@"mogenerator 1.17. By Jonathan 'Wolf' Rentzsch + friends.\n");
}

- (void)handleListSourceFilesAndReturnError:(NSError**)error_ {
	;
}

- (void)handleOrphanedAndReturnError:(NSError**)error_ {
	;
}

- (void)handleGenerationAndReturnError:(NSError**)error_ {
	;
}

- (void)application:(DDCliApplication*)app willParseOptions:(DDGetoptLongParser*)optionsParser {
    [optionsParser setGetoptLongOnly:YES];
    DDGetoptOption optionTable[] = {
		// Long					Short   Argument options
		{@"model",				'm',    DDGetoptRequiredArgument},
		{@"base-class",			0,		DDGetoptRequiredArgument},
		// For compatibility:
		{@"baseClass",			0,      DDGetoptRequiredArgument},
		{@"includem",			0,      DDGetoptRequiredArgument},
		{@"template-path",		0,      DDGetoptRequiredArgument},
		// For compatibility:
		{@"templatePath",		0,      DDGetoptRequiredArgument},
		{@"output-dir",			'O',    DDGetoptRequiredArgument},
		{@"machine-dir",		'M',    DDGetoptRequiredArgument},
		{@"human-dir",			'H',    DDGetoptRequiredArgument},
		{@"template-group",		0,      DDGetoptRequiredArgument},
		{@"list-source-files",	0,      DDGetoptNoArgument},
		{@"orphaned",			0,      DDGetoptNoArgument},
		
		{@"help",				'h',    DDGetoptNoArgument},
		{@"version",			0,      DDGetoptNoArgument},
		{nil,					0,      0},
    };
    [optionsParser addOptionsFromTable:optionTable];
}

- (void)setModel:(NSString*)path {
    assert(!model); // Currently we only can load one model.
	
    if( ![[NSFileManager defaultManager] fileExistsAtPath:path]){
        NSString * reason = [NSString stringWithFormat: @"error loading file at %@: no such file exists", path];
        DDCliParseException * e = [DDCliParseException parseExceptionWithReason: reason
                                                                       exitCode: EX_NOINPUT];
        @throw e;
    }
	
    if ([[path pathExtension] isEqualToString:@"xcdatamodel"]) {
        //	We've been handed a .xcdatamodel data model, transparently compile it into a .mom managed object model.
        
        //  Find where Xcode installed momc this week.
        NSString *momc = nil;
        if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Developer/usr/bin/momc"]) { // Xcode 3.1 installs it here.
            momc = @"/Developer/usr/bin/momc";
        } else if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/Application Support/Apple/Developer Tools/Plug-ins/XDCoreDataModel.xdplugin/Contents/Resources/momc"]) { // Xcode 3.0.
            momc = @"/Library/Application Support/Apple/Developer Tools/Plug-ins/XDCoreDataModel.xdplugin/Contents/Resources/momc";
        } else if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Developer/Library/Xcode/Plug-ins/XDCoreDataModel.xdplugin/Contents/Resources/momc"]) { // Xcode 2.4.
            momc = @"/Developer/Library/Xcode/Plug-ins/XDCoreDataModel.xdplugin/Contents/Resources/momc";
        }
        assert(momc && "momc not found");
        
        tempMOMPath = [[NSTemporaryDirectory() stringByAppendingPathComponent:[(id)CFUUIDCreateString(kCFAllocatorDefault, CFUUIDCreate(kCFAllocatorDefault)) autorelease]] stringByAppendingPathExtension:@"mom"];
        system([[NSString stringWithFormat:@"\"%@\" \"%@\" \"%@\"", momc, path, tempMOMPath] UTF8String]); // Ignored system's result -- momc doesn't return any relevent error codes.
        path = tempMOMPath;
    }
    model = [[[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]] autorelease];
    assert(model);
}

- (NSString*)baseClass {
	return [[baseClass retain] autorelease];
}

- (NSString*)formattedMessageWithCall:(JRLogCall*)call_ {
	if (JRLogLevel_Info == call_->callerLevel) {
		return call_->message;
	} else {
		return [super formattedMessageWithCall:call_];
	}
}

@end

int main (int argc, char * const * argv) {
    return DDCliAppRunWithClass([MOGeneratorApp class]);
}
