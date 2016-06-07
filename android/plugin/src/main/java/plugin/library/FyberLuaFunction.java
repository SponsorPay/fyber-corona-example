/******************************************************************************
*
* CORONA ENTERPRISE/FYBER TEST APP
* v: 1.00
*
******************************************************************************/

package plugin.library;

import android.content.Intent;

import com.ansca.corona.CoronaActivity;
import com.fyber.Fyber;
import com.fyber.ads.AdFormat;
import com.fyber.ads.interstitials.InterstitialActivity;
import com.fyber.ads.interstitials.InterstitialAdCloseReason;
import com.fyber.ads.videos.RewardedVideoActivity;
import com.fyber.requesters.InterstitialRequester;
import com.fyber.requesters.RequestCallback;
import com.fyber.requesters.RequestError;
import com.fyber.requesters.RewardedVideoRequester;
import com.fyber.utils.FyberLogger;

import java.util.HashMap;
import java.util.Map;

import static plugin.library.BL_Events.sendRuntimeEvent;

/*
import com.fyber.mediation.configs.*;
import com.fyber.annotations.MediationRuntimeConfigs;
import com.fyber.mediation.configs.AdMobConfigs;
import com.fyber.mediation.configs.AppLovinConfigs;
import com.fyber.mediation.configs.ChartboostConfigs;
import com.fyber.mediation.admob.AdMobMediationAdapter;
import com.fyber.mediation.applovin.AppLovinMediationAdapter;
import com.fyber.mediation.chartboost.ChartboostMediationAdapter;
*/

/*@ChartboostConfigs(
    logLevel = "ALL",
    cacheInterstitials = true,
    cacheRewardedVideo = true
)*/
/*@AdMobConfigs(
	addTestDevice  = {
	    "45A13240018909CDC2834C8FCAC8FC67",
	},
	isCOPPAcompliant = true,
	adUnitId = ""
)*/
/*@AppLovinConfigs(
    setVerboseLogging = true
)*/
public class FyberLuaFunction implements com.naef.jnlua.NamedJavaFunction {

	private static final String TAG = "FYBER SDK LOG";

	//codes def
	private static int rewarded_video_request_code;
	private static int interstitial_request_code;

	//vars from lua
	private String fyber_action;
	private String fyber_appid;
	private String fyber_security_token;

	//vars
	private boolean fyber_initialized = false;

	protected static Intent video_intent = null;
	protected static Intent interstitial_intent = null;


	/**
	 * Gets the name of the Lua function as it would appear in the Lua script.
	 * @return Returns the name of the custom Lua function.
	 */
	@Override
	public String getName() {
		return "loadFyberInterstitial";
	}

	private static void sendToCorona(String event , String status , String extras) {
		//send result to corona
		Map<String, String> params = new HashMap<String, String>();
		params.put("status", status);
		if (extras != null) {
			params.put("extras", extras);
		}
		sendRuntimeEvent(event, params);
	}

	/**
	 * This method is called when the Lua function is called.
	 * <p>
	 * Warning! This method is not called on the main UI thread.
	 * @param luaState Reference to the Lua state.
	 *                 Needed to retrieve the Lua function's parameters and to return values back to Lua.
	 * @return Returns the number of values to be returned by the Lua function.
	 */
	@Override
	public int invoke(com.naef.jnlua.LuaState luaState) {

		try {
			// Fetch the Lua function's first argument. Will throw an exception if it is not of type string.
			fyber_action 		 = luaState.checkString(1, ""); //init, load_interstitial, load_video, show_interstitial, show_video
			fyber_appid 		 = luaState.checkString(2, "");
			fyber_security_token = luaState.checkString(3, "");


		} catch (Exception ex) {
			// An exception will occur if given an invalid argument or no argument. Print the error.
			ex.printStackTrace();
			return 0;
		}

		com.ansca.corona.CoronaEnvironment.getCoronaActivity().runOnUiThread(new Runnable() {

			@Override
			public void run() {

				// Fetch the currently running CoronaActivity. Warning: Will return null if the activity has just been exited.
				com.ansca.corona.CoronaActivity activity = com.ansca.corona.CoronaEnvironment.getCoronaActivity();
				if (activity == null) {
					return;
				}

				FyberLogger.enableLogging(true);

				if ( fyber_initialized != true ) {

					try {
						// ** FYBER SDK INITIALIZATION **
						Fyber.Settings fyberSettings = Fyber
							.with(fyber_appid, activity)
							.withSecurityToken(fyber_security_token)
							// by default Fyber SDK will start precaching. If you wish to only start precaching at a later time you can uncomment this line and use 'CacheManager' to start, pause or resume on demand.
							//.withManualPrecaching()
							.start();

						fyber_initialized = true;
					} catch (IllegalArgumentException e) {
						FyberLogger.d(TAG, e.getLocalizedMessage());
					}

				} else {

					if (fyber_action.equals("load_interstitial")) {
						FyberLogger.d(TAG, "LOAD INTERSTITIAL");
						InterstitialRequester
							.create(requestInterstitialCallback)
							.request(activity);

					} else if (fyber_action.equals("load_video")) {
						FyberLogger.d(TAG, "LOAD VIDEO");
						RewardedVideoRequester
							.create(requestVideoCallback)
							.request(activity);

					} else if (fyber_action.equals("show_interstitial") && interstitial_intent != null ) {
						FyberLogger.d(TAG, "SHOW INTERSTITIAL");

						interstitial_request_code = activity.registerActivityResultHandler(new CoronaInterstitialHandler());
						activity.startActivityForResult(interstitial_intent, interstitial_request_code);

					} else if (fyber_action.equals("show_video") && video_intent != null) {
						FyberLogger.d(TAG, "SHOW VIDEO");

						rewarded_video_request_code = activity.registerActivityResultHandler(new CoronaVideoHandler());
						activity.startActivityForResult(video_intent, rewarded_video_request_code);
					}

				}
			}
		});

		// Return 0 to indicate that this Lua function returns 0 values.
		return 0;
	}

	// Video on activity result via handler
	// https://forums.coronalabs.com/topic/37282-how-can-one-capture-cameragallery-return-result-in-android-native-code/?p=193386
	private static class CoronaVideoHandler implements CoronaActivity.OnActivityResultHandler {
	    public CoronaVideoHandler() {}

	    @Override
	    public void onHandleActivityResult(CoronaActivity activity, int requestCode, int resultCode, android.content.Intent data)
	    {

	    	FyberLogger.d(TAG, "on onHandleVideoActivityResult");

		    // Unregister this handler.
		    activity.unregisterActivityResultHandler(this);
		    video_intent = null;

		    //video
	        if (resultCode == activity.RESULT_OK && requestCode == rewarded_video_request_code) {
				String engagementStatus = data.getStringExtra(RewardedVideoActivity.ENGAGEMENT_STATUS);
					switch (engagementStatus) {
					case RewardedVideoActivity.REQUEST_STATUS_PARAMETER_FINISHED_VALUE:
						FyberLogger.d(TAG, "The video has finished after completing. The user will be rewarded.");

						sendToCorona("VideoEvent","show_video_finished",null);

						break;
					case RewardedVideoActivity.REQUEST_STATUS_PARAMETER_ABORTED_VALUE:
						FyberLogger.d(TAG, "The video has finished before completing. The user might have aborted it, either explicitly (by tapping the close button) or implicitly (by switching to another app) or it was interrupted by an asynchronous event like an incoming phone call.");

						sendToCorona("VideoEvent","show_video_aborted",null);

						break;
					case RewardedVideoActivity.REQUEST_STATUS_PARAMETER_ERROR:
						FyberLogger.d(TAG, "The video was interrupted or failed to play due to an error.");

						sendToCorona("VideoEvent","show_video_error",null);

						break;
					default:
						break;
				}
			}

	   }
	}

	// Interstitial on activity result via handler
	private static class CoronaInterstitialHandler implements CoronaActivity.OnActivityResultHandler {
	    public CoronaInterstitialHandler() {}

	    @Override
	    public void onHandleActivityResult(CoronaActivity activity, int requestCode, int resultCode, android.content.Intent data)
	    {

	    	FyberLogger.d(TAG, "on onHandleInterstitialActivityResult");

		    // Unregister this handler.
		    activity.unregisterActivityResultHandler(this);
		    interstitial_intent = null;

			//for interstitial
			if (resultCode == activity.RESULT_OK && requestCode == interstitial_request_code) {
		        InterstitialAdCloseReason adStatus = (InterstitialAdCloseReason) data.getSerializableExtra(InterstitialActivity.AD_STATUS);
		        FyberLogger.d(TAG, "Interstitial closed with status - " + adStatus);
		        if (adStatus.equals(InterstitialAdCloseReason.ReasonError)) {
		            String error = data.getStringExtra(InterstitialActivity.ERROR_MESSAGE);
		            FyberLogger.d(TAG, "Interstitial closed and error - " + error);
       		        sendToCorona("InterstitialEvent","show_interstitial_error", error.toString());
		        } else {
		        	sendToCorona("InterstitialEvent","show_interstitial_closed", adStatus.toString());
		        }

	    	}

	   }
	}

	//video callback
	RequestCallback requestVideoCallback = new RequestCallback() {
        @Override
        public void onAdAvailable(Intent intent) {
			FyberLogger.d(TAG, "on Video Ad available");
			video_intent = intent;

			sendToCorona("VideoEvent","load_video_available",null);

        }

        @Override
        public void onAdNotAvailable(AdFormat adFormat) {
       		FyberLogger.d(TAG, "Video ad not available");
       		video_intent = null;

       		sendToCorona("VideoEvent","load_video_not_available",null);
        }

        @Override
       	public void onRequestError(RequestError requestError) {
	       	FyberLogger.d(TAG, "Video onRequestError");
       		video_intent = null;

       		sendToCorona("VideoEvent","load_video_request_error",null);
        }
    };

    //interstitial callback
	RequestCallback requestInterstitialCallback = new RequestCallback() {
       @Override
        public void onAdAvailable(Intent intent) {
        	FyberLogger.d(TAG, "on Interstitial Ad available");
        	interstitial_intent = intent;

        	sendToCorona("InterstitialEvent","load_interstitial_available",null);
        }

        @Override
        public void onAdNotAvailable(AdFormat adFormat) {
        	FyberLogger.d(TAG, "on Interstitial Ad NOT available");
        	interstitial_intent = null;

        	sendToCorona("InterstitialEvent","load_interstitial_not_available",null);
        }

        @Override
        public void onRequestError(RequestError requestError) {
        	FyberLogger.d(TAG, "on Interstitial Ad Request ERROR");
        	interstitial_intent = null;

        	sendToCorona("InterstitialEvent","load_interstitial_request_error",null);
        }
    };

}