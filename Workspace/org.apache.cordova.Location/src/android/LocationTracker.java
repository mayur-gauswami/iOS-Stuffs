package org.apache.cordova.Location;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;
import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.content.Context;
import android.location.Criteria;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;

public class LocationTracker implements LocationListener {

	private final Context mContext;
	// flag for GPS status
	private boolean isGPSEnabled = false;
	// flag for network status
	private boolean isNetworkEnabled = false;
	private boolean canGetLocation = false;
	private double latitude; // latitude
	private double longitude; // longitude
	private Location new_location;
	private double new_latitude; // latitude
	private double new_longitude; // longitude
	private Criteria mCriteria;
	private static String TAG = LocationTracker.class.toString();

	public static Location location; // location
	// The minimum distance to change Updates in meters
	public static final long MIN_DISTANCE_CHANGE_FOR_UPDATES = 10; // 10 meters
	// The minimum time between updates in milliseconds
	public static final long MIN_TIME_BW_UPDATES = 1000 * 60 * 1; // 1 minute
	// Declaring a Location Manager
	protected LocationManager locationManager;
	// CallbackContext of getCurrentLocation
	private CallbackContext mPluginCallback;
	private JSONObject mJsonResult;

	public LocationTracker(Context context,CallbackContext callbackContext) {
		this.mContext = context;
		mPluginCallback=callbackContext;
		getLocation();
	}

	public Location getLocation() {
		try {
			locationManager = (LocationManager) mContext
					.getSystemService(Context.LOCATION_SERVICE);
			// getting GPS status
			isGPSEnabled = locationManager
					.isProviderEnabled(LocationManager.GPS_PROVIDER);
			// getting network status
			isNetworkEnabled = locationManager
					.isProviderEnabled(LocationManager.NETWORK_PROVIDER);
			// ///Criteria //////////
			mCriteria = new Criteria();
			if (Build.VERSION.SDK_INT > Build.VERSION_CODES.GINGERBREAD) {
				mCriteria.setAccuracy(Criteria.ACCURACY_FINE);
			}else{
				mCriteria.setAccuracy(Criteria.ACCURACY_MEDIUM);
			}
			mCriteria.setPowerRequirement(Criteria.POWER_LOW);
			String provider = locationManager.getBestProvider(mCriteria, true);
			if (!isGPSEnabled && !isNetworkEnabled) {
				Log.d(LocationTracker.class.toString(),
						"Location providers are disabled");
			} else {
				this.canGetLocation = true;
				if (isNetworkEnabled) {
					locationManager.requestLocationUpdates(provider,
							MIN_TIME_BW_UPDATES,
							MIN_DISTANCE_CHANGE_FOR_UPDATES, this);
					if (locationManager != null) {
						location = locationManager
								.getLastKnownLocation(LocationManager.NETWORK_PROVIDER);
						if (location != null) {
							latitude = location.getLatitude();
							longitude = location.getLongitude();
						}
					}
				}
				// if GPS Enabled get lat/long using GPS Services
				if (isGPSEnabled) {
					if (location == null) {
						locationManager.requestLocationUpdates(provider,
								MIN_TIME_BW_UPDATES,
								MIN_DISTANCE_CHANGE_FOR_UPDATES, this);
						if (locationManager != null) {
							location = locationManager
									.getLastKnownLocation(LocationManager.GPS_PROVIDER);
							if (location != null) {
								latitude = location.getLatitude();
								longitude = location.getLongitude();
							}
						}
					}
				}
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		return location;
	}

	/**
	 * Stop using Location listener Calling this function will stop using GPS in your
	 * app
	 * */
	public void stopUsingGPS() {
		if (locationManager != null) {
			locationManager.removeUpdates(LocationTracker.this);
		}
	}

	/**
	 * Function to get latitude
	 * */
	public double getLatitude() {
		if (location != null) {
			latitude = location.getLatitude();
		}

		return latitude;
	}

	/**
	 * Function to get longitude
	 * */
	public double getLongitude() {
		if (location != null) {
			longitude = location.getLongitude();
		}

		return longitude;
	}

	
	/**
	 * Function to check GPS/wifi enabled
	 * 
	 * @return boolean
	 * */
	public boolean canGetLocation() {
		return this.canGetLocation;
	}

	@Override
	public void onLocationChanged(Location changed_location) {
		new_location = changed_location;
		new_latitude = new_location.getLatitude();
		new_longitude = new_location.getLongitude();
		Log.d("Location", "Location Changed");
		Log.d(TAG,"Callback: "+mPluginCallback.isFinished());
		if(!mPluginCallback.isFinished()){
			mJsonResult = new JSONObject();

			try {
				mJsonResult.put("latitude",
						new_latitude);
				mJsonResult.put("longitude",
						new_longitude);

			} catch (JSONException e) {

				e.printStackTrace();
			}
			mPluginCallback.sendPluginResult(new PluginResult(
					PluginResult.Status.OK, mJsonResult));

		}
		stopUsingGPS();
		/* Changed the location object */
	}

	@Override
	public void onProviderDisabled(String provider) {
		Log.d(TAG, "Provider Disabled");
	}

	@Override
	public void onProviderEnabled(String provider) {
		Log.d(TAG, "Provider Enaabled");
	}

	@Override
	public void onStatusChanged(String provider, int status, Bundle extras) {
		Log.d(TAG, "Status Changed");
	}


	@SuppressLint({ "NewApi", "InlinedApi" })
	public void setLocationForHighAccuracy() {

		// locationManager.removeUpdates(this);
		// mCriteria.setAccuracy(Criteria.ACCURACY_FINE);

		mCriteria.setHorizontalAccuracy(Criteria.ACCURACY_HIGH);
		mCriteria.setVerticalAccuracy(Criteria.ACCURACY_HIGH);

		Log.i(TAG, "Accuracy High");

	}

	public void setLocationForNormalAccuracy() {

		locationManager.removeUpdates(this);
		mCriteria.setAccuracy(Criteria.ACCURACY_MEDIUM);

		Log.i("Accuracy", "Accuracy Normal");

	}

	public void setLatestLocation(Location newLocation) {
		if (newLocation != null) {
			location = newLocation;
		}
	}


}
