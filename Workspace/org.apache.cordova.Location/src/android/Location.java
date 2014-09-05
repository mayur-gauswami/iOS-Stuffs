package org.apache.cordova.Location;

import java.util.List;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.content.Context;
import android.location.LocationManager;
import android.util.Log;

public class Location extends CordovaPlugin {

	private LocationTracker mLocationTracker;
	private LocationManager mLocationManager;
	private JSONObject mJsonResult;
	
	@Override
	public boolean execute(String action, JSONArray args,
			CallbackContext callbackContext) throws JSONException {
		if ("getCurrentLocation".equals(action)) {
			this.getCurrentLocation(action, callbackContext, args);
			return true;
		}
		return false;
	}

	private void getCurrentLocation(String action,
			CallbackContext callbackContext, JSONArray args) {
		mLocationTracker = new LocationTracker(this.cordova.getActivity(),callbackContext);
		mLocationManager = (LocationManager) this.cordova.getActivity()
				.getSystemService(Context.LOCATION_SERVICE);

		List<String> providers = mLocationManager.getProviders(true);

		if(mLocationTracker.getLocation()!=null){
			mJsonResult = new JSONObject();

			try {
				mJsonResult.put("latitude",
						mLocationTracker.getLatitude());
				mJsonResult.put("longitude",
						mLocationTracker.getLongitude());

			} catch (JSONException e) {

				e.printStackTrace();
			}
			PluginResult pluginResult =new PluginResult(PluginResult.Status.OK, mJsonResult);
			pluginResult.setKeepCallback(true);
			//callbackContext.sendPluginResult(pluginResult);
			//mLocationTracker.stopUsingGPS();
			return;

		} else if(!providers.contains("network") && !providers.contains("gps")){
			Log.d(Location.class.toString(),"Network and GPS both disabled");
			PluginResult pluginResult =new PluginResult(PluginResult.Status.ERROR, "Network and GPS disabled");
			pluginResult.setKeepCallback(true);
			callbackContext.sendPluginResult(pluginResult);
			mLocationTracker.stopUsingGPS();
			/* Show Settings dialog */
		} else {
			Log.d(Location.class.toString(),"Unknown error");
			PluginResult pluginResult =new PluginResult(PluginResult.Status.ERROR, "Unknown error");
			pluginResult.setKeepCallback(true);
			callbackContext.sendPluginResult(pluginResult);
			mLocationTracker.stopUsingGPS();
		}
		
	}
	
	
	
}