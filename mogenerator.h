/*******************************************************************************
	mogenerator.h - <http://github.com/rentzsch/mogenerator>
		Copyright (c) 2006-2010 Jonathan 'Wolf' Rentzsch: <http://rentzsch.com>
		Some rights reserved: <http://opensource.org/licenses/mit-license.php>

	***************************************************************************/

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DDCommandLineInterface.h"
#import "JRLog.h"

/*#import "MiscMergeTemplate.h"
#import "MiscMergeCommandBlock.h"
#import "MiscMergeEngine.h"
#import "FoundationAdditions.h"
#import "nsenumerate.h"
#import "NSString+MiscAdditions.h"*/

@interface MOGeneratorApp : JRLogDefaultFormatter<DDCliApplicationDelegate> {
	// Auto-populated arguments:
	NSManagedObjectModel	*model;
	NSString				*baseClass;
	NSString				*includem;
	NSString				*templatePath;
	NSString				*outputDir;
	NSString				*machineDir;
	NSString				*humanDir;
	NSString				*templateGroup;
	BOOL					help;
	BOOL					version;
	BOOL					listSourceFiles;
    BOOL					orphaned;
	
	// 
	NSString				*tempMOMPath;
}

- (NSString*)baseClass;

@end