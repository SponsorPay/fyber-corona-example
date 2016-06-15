////////////////////////////////////////////////////////////////////////////
//
//  fyberLib.mm
//
//  Copyright (c) Bubadu. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////

#include "CoronaLua.h"

class fyberLib
{
public:
    typedef fyberLib Self;
    
public:
    static const char *Name();
    static int Open( lua_State *L );
    
public:
    static void sendRuntimeEvent(const char *eventName, NSMutableDictionary *parameters);
    
};
