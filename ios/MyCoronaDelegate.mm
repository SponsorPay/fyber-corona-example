//
//  MyCoronaDelegate.mm
//  CoronaSampleApp
//
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyCoronaDelegate.h"

#import "CoronaRuntime.h"
#import "CoronaLua.h"
#import "fyberLib.h"

@implementation MyCoronaDelegate

- (void)willLoadMain:(id<CoronaRuntime>)runtime
{

    //NSLog(@"willLoadMain");
    
	// Register modules before execution of main.lua
	const luaL_Reg moduleLoaders[] =
	{
		// Each module is a pair: (name, C-function loader)
		{ fyberLib::Name(), fyberLib::Open },
		
		// Termination
		{ NULL, NULL }
	};

	lua_State *L = runtime.L;

	// Make runtime available to each module
	lua_pushlightuserdata( L, runtime );
	Corona::Lua::RegisterModuleLoaders( L, moduleLoaders, 1 );

	// CUSTOM ERROR HANDLER
	// Uncomment the following line to set MyTraceback as a custom error handler:
	// Corona::Lua::SetErrorHandler( MyTraceback );
}

- (void)didLoadMain:(id<CoronaRuntime>)runtime
{

}




@end



