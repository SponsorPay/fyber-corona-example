////////////////////////////////////////////////////////////////////////////
//
//  fyberLib.mm
//
//  Copyright (c) Bubadu. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////

#import "fyberLib.h"

#import "CoronaRuntime.h"

#import <UIKit/UIKit.h>

#import "FyberSDK.h"

//variables
static lua_State* state;

static bool fyber_initialized = NO;


////////////////////////////////////////////////////////////////////////////
// fyber video delegate
////////////////////////////////////////////////////////////////////////////
@interface MyFyberVideoDelegate : UIViewController <FYBRewardedVideoControllerDelegate, FYBVirtualCurrencyClientDelegate>

    @property(nonatomic, assign) BOOL didReceiveOffers;

@end

@implementation MyFyberVideoDelegate

    #pragma mark - UIViewController

    - (void)viewDidLoad
    {
        [super viewDidLoad];
    }

    #pragma mark FYBRewardedVideoControllerDelegate - Request Video

    - (void)rewardedVideoControllerDidReceiveVideo:(FYBRewardedVideoController *)rewardedVideoController
    {
        //NSLog(@"Did receive offer");
        
        //send back to corona
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:@"load_video_available"    forKey:@"status"];
        [params setValue:@""                        forKey:@"extras"];
        fyberLib::sendRuntimeEvent("VideoEvent", params);
        
    }

    - (void)rewardedVideoController:(FYBRewardedVideoController *)rewardedVideoController didFailToReceiveVideoWithError:(NSError *)error
    {
        //NSLog(@"Did not receive any offer error : %@", error);
        
        //send back to corona
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:@"load_video_not_available"    forKey:@"status"];
        [params setValue:@""                            forKey:@"extras"];
        fyberLib::sendRuntimeEvent("VideoEvent", params);
        
    }

    #pragma mark FYBRewardedVideoControllerDelegate - Show Video

    - (void)rewardedVideoControllerDidStartVideo:(FYBRewardedVideoController *)rewardedVideoController
    {
        //NSLog(@"Video Started");
        
        //send back to corona
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:@"show_video_started"  forKey:@"status"];
        [params setValue:@""                    forKey:@"extras"];
        fyberLib::sendRuntimeEvent("VideoEvent", params);
    }

    - (void)rewardedVideoController:(FYBRewardedVideoController *)rewardedVideoController didDismissVideoWithReason:(FYBRewardedVideoControllerDismissReason)reason
    {
        //NSLog(@"Video didDismissVideoWithReason");
        
        //NSLog(@"Received %@", @(reason));
        //  0 - finished video will receive reward - DismissReasonUserEngaged
        //  1 - aborted - DismissReasonAborted
        // -1 - error - DismissReasonError
        
        //send back to corona
        if (reason == 1) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setValue:@"show_video_aborted"  forKey:@"status"];
            [params setValue:@""                    forKey:@"extras"];
            fyberLib::sendRuntimeEvent("VideoEvent", params);
            
        } else if (reason == 0) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setValue:@"show_video_finished" forKey:@"status"];
            [params setValue:@""                    forKey:@"extras"];
            fyberLib::sendRuntimeEvent("VideoEvent", params);
            
        } else if (reason == -1) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setValue:@"show_video_error"  forKey:@"status"];
            [params setValue:@""                  forKey:@"extras"];
            fyberLib::sendRuntimeEvent("VideoEvent", params);
            
        }
    }

    - (void)rewardedVideoController:(FYBRewardedVideoController *)rewardedVideoController didFailToStartVideoWithError:(NSError *)error
    {
        //NSLog(@"Video didFailToStartVideoWithError : %@", error);

        //send back to corona
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:@"show_video_error"        forKey:@"status"];
        [params setValue:@""                        forKey:@"extras"];
        fyberLib::sendRuntimeEvent("VideoEvent", params);
        
    }

    #pragma mark - FYBVirtualCurrencyClientDelegate

    - (void)virtualCurrencyClient:(FYBVirtualCurrencyClient *)client didReceiveResponse:(FYBVirtualCurrencyResponse *)response
    {
        //NSLog(@"Video didReceiveResponse - reward - video finished - response: %@", response);
        
        //send back to corona
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:@"show_video_finished_reward"  forKey:@"status"];
        [params setValue:@""                            forKey:@"extras"];
        fyberLib::sendRuntimeEvent("VideoEvent", params);
        
        //NSLog(@"Received %@ %@", @(response.deltaOfCoins), response.currencyName);
    }

    - (void)virtualCurrencyClient:(FYBVirtualCurrencyClient *)client didFailWithError:(NSError *)error
    {
        //NSLog(@"Video didFailWithError - reward - video finished - error : %@", error);
        
        //send back to corona
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:@"show_video_aborted_no_reward"    forKey:@"status"];
        [params setValue:@""                                forKey:@"extras"];
        fyberLib::sendRuntimeEvent("VideoEvent", params);
        
        //NSLog(@"Failed to receive virtual currency %@", error);
        
    }

@end

////////////////////////////////////////////////////////////////////////////
// fyber interstitial delegate
////////////////////////////////////////////////////////////////////////////
@interface MyFyberInterstitialDelegate : UIViewController <FYBInterstitialControllerDelegate>

    @property(nonatomic) BOOL didReceiveOffers;

@end

@implementation MyFyberInterstitialDelegate

    #pragma mark - UIViewController

    - (void)viewDidLoad
    {
        [super viewDidLoad];
        
    }

    #pragma mark FYBInterstitialControllerDelegate - Request Interstitial

    - (void)interstitialControllerDidReceiveInterstitial:(FYBInterstitialController *)interstitialController
    {
        //NSLog(@"Did receive offer");
        
        //send back to corona
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:@"load_interstitial_available"     forKey:@"status"];
        [params setValue:@""                                forKey:@"extras"];
        fyberLib::sendRuntimeEvent("InterstitialEvent", params);
        
    }

    - (void)interstitialController:(FYBInterstitialController *)interstitialController didFailToReceiveInterstitialWithError:(NSError *)error
    {
        //NSLog(@"Did not receive any offer : %@", error);
        
        //send back to corona
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:@"load_interstitial_request_error" forKey:@"status"];
        [params setValue:@""                                forKey:@"extras"];
        fyberLib::sendRuntimeEvent("InterstitialEvent", params);
        
    }


    #pragma mark FYBInterstitialControllerDelegate  - Show Interstitial

    - (void)interstitialControllerDidPresentInterstitial:(FYBInterstitialController *)interstitialController
    {
        //NSLog(@"Interstitial Presented");
        
        //send back to corona
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:@"show_interstitial_presented" forKey:@"status"];
        [params setValue:@""                            forKey:@"extras"];
        fyberLib::sendRuntimeEvent("InterstitialEvent", params);
    }

    - (void)interstitialController:(FYBInterstitialController *)interstitialController didDismissInterstitialWithReason:(FYBInterstitialControllerDismissReason)reason
    {
        //NSLog(@"Interstitial didDismissInterstitialWithReason : %ld", (long)reason);
        
        //send back to corona
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:@"show_interstitial_closed"    forKey:@"status"];
        [params setValue:@""                            forKey:@"extras"];
        fyberLib::sendRuntimeEvent("InterstitialEvent", params);
        
    }

    - (void)interstitialController:(FYBInterstitialController *)interstitialController didFailToPresentInterstitialWithError:(NSError *)error
    {
        //NSLog(@"Interstitial didFailToPresentInterstitialWithError  - error : %@", error);
        
        //send back to corona
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:@"show_interstitial_error" forKey:@"status"];
        [params setValue:@""                        forKey:@"extras"];
        fyberLib::sendRuntimeEvent("InterstitialEvent", params);
        
    }

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
static int FyberFunction(lua_State *L ) {
    //1. fyber_action : init, load_interstitial, load_video, show_interstitial, show_video
    //2. fyber_appid
    //3. fyber_security_token
    const char *fyber_action_param = lua_tostring( L, 1 );
    const char *fyber_appid_param = lua_tostring( L, 2 );
    const char *fyber_security_token_param = lua_tostring( L, 3 );
    
    NSString *fyber_action = [NSString stringWithUTF8String:fyber_action_param];
    //NSLog(@"FYBER action: %@", fyber_action);
    
    NSString *fyber_appid;
    if (fyber_appid_param != NULL) {
        fyber_appid = [NSString stringWithUTF8String:fyber_appid_param];
    }
    
    NSString *fyber_security_token;
    if (fyber_security_token_param != NULL) {
        fyber_security_token = [NSString stringWithUTF8String:fyber_security_token_param];
    }
    
    // Set the log level of the FyberSDK
    [FyberSDK setLoggingLevel:FYBLogLevelDebug];
    //[FyberSDK setLoggingLevel:FYBLogLevelOff];
    
    if ([fyber_action isEqualToString:@"init"]) {
        fyber_initialized = NO;
    }

    if (fyber_initialized == NO ) {

        //NSLog(@"FYBER init");
        
        [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
        
        FYBSDKOptions *options = [FYBSDKOptions optionsWithAppId:fyber_appid securityToken:fyber_security_token];
        [FyberSDK startWithOptions:options];
    
        fyber_initialized = YES;
        
    } else {
        if ([fyber_action isEqualToString:@"load_interstitial"]) {
             //NSLog(@"FYBER load_interstitial");
            
            // Get the Interstitial Controller
            FYBInterstitialController *interstitialController = [FyberSDK interstitialController];
            
            // Set the delegate of the controller in order to be notified of the controller's state changes
            MyFyberInterstitialDelegate *myfyberinterstitialdelegate_ = [[MyFyberInterstitialDelegate alloc] init];
            interstitialController.delegate = myfyberinterstitialdelegate_;
            
            // Request an Interstitial
            FYBRequestParameters *parameters = [[FYBRequestParameters alloc] init];
            
            // Add an optional Placement ID or Custom Parameters to your request
            // parameters.placementId = @"PLACEMENT_ID";
            // [parameters addCustomParameterWithKey:@"param1Key" value:@"param1Value"];
            
            [interstitialController requestInterstitialWithParameters:parameters];

        } else if ([fyber_action isEqualToString:@"load_video"]) {
             //NSLog(@"FYBER load_video");
            
            // Get the Rewarded Video Controller
            FYBRewardedVideoController *rewardedVideoController = [FyberSDK rewardedVideoController];

            MyFyberVideoDelegate *myfybervideodelegate_ = [[MyFyberVideoDelegate alloc] init];
            rewardedVideoController.delegate = myfybervideodelegate_;
            
            // Enable or disable a "toast" message shown to the user after the video is fully watched
            rewardedVideoController.shouldShowToastOnCompletion = NO;
            
            // request the offers
            [rewardedVideoController requestVideo];
            
        } else if ([fyber_action isEqualToString:@"show_interstitial"]) {
            // NSLog(@"FYBER show_interstitial");
            
            // Play the received interstitial
            UIViewController *rootViewController = (UIViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
            
            [[FyberSDK interstitialController] presentInterstitialFromViewController:rootViewController];
            
        } else if ([fyber_action isEqualToString:@"show_video"]) {
            // NSLog(@"FYBER show_video");
            
            UIViewController *rootViewController = (UIViewController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
            // [interstitial_ presentFromRootViewController:rootViewController];

            [[FyberSDK rewardedVideoController] presentRewardedVideoFromViewController:rootViewController];
            
        }
    
    }
    return 0;
}

static int locale_to_currency( lua_State *L )
{
    //NSLog( @"locale_to_currency");
    // Fetch the Lua function's first argument.
    const char *locale_param = lua_tostring( L, 1 );
    NSString *locale_string = [NSString stringWithUTF8String:locale_param];
    
    //NSLog( @"locale from lua: value = %s", locale_param);
    
    NSLocale *curr_locale = [[[NSLocale alloc] initWithLocaleIdentifier:locale_string] autorelease];
    NSString *currency_code = [curr_locale objectForKey:NSLocaleCurrencyCode];
    
    //NSLog( @"currency_code: value = %@", currency_code );
    
    // Push the string to the Lua state's stack.
    // This is the value to be returned by the Lua function.
    lua_pushstring( L, [currency_code UTF8String] );
    
    // Return 1 to indicate that this Lua function returns 1 value.
    return 1;
}

////////////////////////////////////////////////////////////////////////////
// lib definition
////////////////////////////////////////////////////////////////////////////
const char *
fyberLib::Name()
{
	static const char sName[] = "plugin.fyberLib";
	return sName;
}

int
fyberLib::Open( lua_State *L )
{

    state = L;
    
    const luaL_Reg kVTable[] =
	{
        { "CallMethod", FyberFunction },
        { "locale_to_currency", locale_to_currency },
		{ NULL, NULL }
	};
    
	// Ensure upvalue is available to library
	void *context = lua_touserdata( L, lua_upvalueindex( 1 ) );
	lua_pushlightuserdata( L, context );
    
	luaL_openlib( L, Name(), kVTable, 1 ); // leave "mylibrary" on top of stack
    
	return 1;
}

////////////////////////////////////////////////////////////////////////////
// runtime event
////////////////////////////////////////////////////////////////////////////
void fyberLib::sendRuntimeEvent(const char *eventName, NSMutableDictionary *parameters) {
    
    lua_State *L = state;
    
    lua_newtable( L );
    lua_pushstring( L, eventName );		// All events are Lua tables
	lua_setfield( L, -2, "name" );      // that have a 'name' property
    
    if (parameters != nil) {
        for (NSString* key in parameters) {
            id value = [parameters objectForKey:key];
            
            lua_pushstring( L, [value UTF8String] );
            lua_setfield( L, -2, [key UTF8String] );
        }
    }
    
    Corona::Lua::DispatchRuntimeEvent(L, 0);
    
}

////////////////////////////////////////////////////////////////////////////

