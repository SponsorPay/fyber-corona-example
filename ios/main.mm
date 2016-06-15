//
//  main.mm
//
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CoronaApplicationMain.h"

#import "MyCoronaDelegate.h"

int main(int argc, char *argv[])
{
	@autoreleasepool
	{
		CoronaApplicationMain( argc, argv, [MyCoronaDelegate class] );
	}

	return 0;
}
