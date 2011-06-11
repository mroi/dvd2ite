/* This is free software, see file COPYING for license. */

#import "DVDPrepareExtras.h"


@implementation DVDPrepareExtras

- (id)initWithDocument:(DVDImportDocument *)document
{
	if ((self = [self init])) {
		dvdImport = [document retain];
		[NSBundle loadNibNamed:@"DVDPrepareExtras" owner:self];
	}
	return self;
}

- (void)awakeFromNib
{
	[dvdImport.viewController addView:view];
}

- (void)dealloc
{
	[dvdImport release];
	[super dealloc];
}

@end
