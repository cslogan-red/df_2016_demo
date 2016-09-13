/** 
 * CurrentWeatherController.cls
 * 
 * @description: Server-side controller for myWeather Lightning app. 
 * Responsible for inflating UI view objects and handling interactions with service layer and data model via Weather__c 
 * custom object.
 *
 * @author: Chase Logan
 */
public class CurrentWeatherController {
	
	// default ctor
	public CurrentWeatherController() {}

	
	/* begin @AuraEnabled methods for interactions with client-side controller code */
	
	/** 
	 * @description: AuraEnabled method for retrieving current weather details by zip code via Lightning component.
	 *
	 * @param inputZip, the zip code to search by location for
	 *
	 * @param inputSessionId, the current device session Id
	 *
	 * @return WeatherData, a constructed WeatherData view object containing current weather details.
	 */
	@AuraEnabled
	public static WeatherData serverGetCurrentWeatherDetailsByZip( String inputZip, String inputSessionId) {
		WeatherData returnVal;
		
		if ( ( inputZip == null || inputZip == '') || 
				inputZip.length() != 5 || !inputZip.isNumeric() ) {
			
			// invalid data, let client side controller handle error
			returnVal = new WeatherData();
			returnVal.currentLocation = WeatherStatics.NO_DATA_FOUND_ERR;
		} else {

			// Create a new session, send and parse REST request/response, store
			// session data in Weather__c, inflate WeatherData view object
			String sessionId = WeatherService.generateSessionId();

			String httpEndpoint = WeatherStatics.BASE_WEATHER_URL + WeatherStatics.API_KEY + 
								  	WeatherStatics.CURRENT_COND_QUERY + inputZip + 
										WeatherStatics.JSON_FORMAT;
			String httpResp = HttpService.sendHttpRequest( httpEndpoint, WeatherStatics.GET_METHOD);
			
			if ( httpResp != WeatherStatics.SERVICE_UNAVAILABLE) {
				
				// inflate WeatherData view object with WeatherModel object data
				WeatherModel wModel = WeatherModel.parseJSONResponseToWeatherModel( httpResp);
				
				if ( wModel.displayLocationMap != null && wModel.displayLocationMap.size() == 0) {
					
					// invalid data, let client side controller handle error
					returnVal = new WeatherData();
					returnVal.currentLocation = WeatherStatics.NO_DATA_FOUND_ERR;
				} else {
					
					returnVal = new WeatherData();
					returnVal.currentLocation = ( String)wModel.displayLocationMap.get( 
					WeatherModel.DISPLAY_LOC_FULL_KEY);
					returnVal.currentZip = ( String)wModel.displayLocationMap.get( 
						WeatherModel.DISPLAY_LOC_ZIP_KEY);
					returnVal.currentTemp = ( String)wModel.currentObservationMap.get( 
						WeatherModel.CURRENT_OBV_TEMP_KEY);
					returnVal.currentWeather = ( String)wModel.currentObservationMap.get( 
						WeatherModel.CURRENT_OBV_WEATHER_KEY);
					returnVal.currentHumidity = ( String)wModel.currentObservationMap.get( 
						WeatherModel.CURRENT_OBV_HUMIDITY_KEY);
					returnVal.currentWind = ( String)wModel.currentObservationMap.get( 
						WeatherModel.CURRENT_OBV_WIND_KEY);
					returnVal.currentWeatherImageURL = ( String)wModel.currentObservationMap.get(
						WeatherModel.CURRENT_OBV_ICON_KEY);
					returnVal.sessionId = sessionId;

					// request three day forecast data and add to response, this is done via a separate API call
					httpEndpoint = WeatherStatics.BASE_WEATHER_URL + WeatherStatics.API_KEY + 
								  	WeatherStatics.FORECAST_QUERY + inputZip + 
										WeatherStatics.JSON_FORMAT;
					httpResp = HttpService.sendHttpRequest( httpEndpoint, WeatherStatics.GET_METHOD);

					if ( httpResp != WeatherStatics.SERVICE_UNAVAILABLE) {

						WeatherModel forecastModel = 
							WeatherModel.parseForecastJSONResponseToWeatherModel( httpResp);

						if ( forecastModel.forecastMapList != null && forecastModel.forecastMapList.size() > 0 &&
							 forecastModel.simpleForecastMapList != null && forecastModel.simpleForecastMapList.size() > 0) {

							Map<String,Object> highTempMap = new Map<String,Object>();
							Map<String,Object> lowTempMap = new Map<String,Object>();

							for ( Integer i = 0; i < forecastModel.forecastMapList.size(); i++) {

								WeatherData.ForecastWrapper fW = new WeatherData.ForecastWrapper();
								fW.title = ( String)forecastModel.forecastMapList[i].get(
									WeatherModel.FORECAST_TITLE_KEY);
								fW.imageURL = ( String)forecastModel.forecastMapList[i].get(
									WeatherModel.FORECAST_ICON_KEY);
								highTempMap = ( Map<String,Object>)forecastModel.simpleForecastMapList[i].get(
									WeatherModel.FORECAST_HIGH_KEY);
								lowTempMap = ( Map<String,Object>)forecastModel.simpleForecastMapList[i].get(
									WeatherModel.FORECAST_LOW_KEY);
								fW.text = WeatherStatics.WEATHER_HIGH_STRING + 
												String.valueOf( highTempMap.get( WeatherModel.FORECAST_FAHRENHEIT_KEY)) + 
									      	WeatherStatics.WEATHER_LOW_STRING + 
									   			String.valueOf( lowTempMap.get( WeatherModel.FORECAST_FAHRENHEIT_KEY));
								returnVal.forecastList.add ( fW);
							}

							// prepare for caching			   		
							wModel.forecastMapList = forecastModel.forecastMapList;
							Integer i = 0;
							wModel.dayOneCachedText = returnVal.forecastList[i].text;
							i++;
							wModel.dayTwoCachedText = returnVal.forecastList[i].text;
							i++;
							wModel.dayThreeCachedText = returnVal.forecastList[i].text;
						} else {

							// invalid data, let client side controller handle error
							returnVal = new WeatherData();
							returnVal.currentLocation = WeatherStatics.NO_DATA_FOUND_ERR;
						}
					} else {

						// invalid data, let client side controller handle error
						returnVal = new WeatherData();
						returnVal.currentLocation = WeatherStatics.NO_DATA_FOUND_ERR;
					}
				}

				// cache new session data in Weather__c object
				WeatherService.cacheWeatherData( wModel, sessionId);
			
				// if a inputSessionId was passed into a new location search, delete the previous
				// Weather__c record that was tied to this session as a new session ID
				// has already been issued and Weather__c record created
				if ( inputSessionId != null && inputSessionId != '' && 
						inputSessionId != WeatherStatics.COOKIE_UNDEFINED) {

					WeatherService.deleteWeatherData( inputSessionId);
				}
			} else {

				// invalid data, let client side controller handle error
				returnVal = new WeatherData();
				returnVal.currentLocation = WeatherStatics.NO_DATA_FOUND_ERR;
			}

		}

		return returnVal;
	}


	/** 
	 * @description: AuraEnabled method initializing the myWeather Lightning app on first load.
	 *
	 * @param  sessionId, if the page has been visited in the last week, sessionId cookie
	 * 		   will be present on user device, use this to pull previously requested location
	 *		   from cache.
	 *
	 * @return WeatherData, a constructed WeatherData view object containing current weather details.
	 */
	@AuraEnabled
	public static WeatherData serverInitWeatherDetails( String sessionId) {
		WeatherData returnVal;

		// no session Id, start fresh, let client side controller manage
		if ( sessionId == null || sessionId == WeatherStatics.COOKIE_UNDEFINED) {
			
			returnVal = new WeatherData();
			returnVal.currentLocation = WeatherStatics.NO_DATA_FOUND_ERR;

		} else {
			// get Weather__c data by session Id, if found, check for stale state
			// if data is stale, request update based on zip stored for location
			// else load previously requested data to initialize view
			Weather__c weather = WeatherService.getWeatherData( sessionId);

			if ( weather != null) {

				// check for stale request
				if ( WeatherService.checkForStaleData( weather.Requested_Time__c)) {
					
					String locationZip = weather.Location_Zip__c;					
					return CurrentWeatherController.serverGetCurrentWeatherDetailsByZip( locationZip, sessionId);
				} else {

					returnVal = new WeatherData();
					returnVal.currentLocation = weather.Previous_Location__c;
					returnVal.currentZip = weather.Location_Zip__c;
					returnVal.currentTemp = weather.Temperature__c;
					returnVal.currentWeather = weather.Weather__c;
					returnVal.currentWind = weather.Windspeed__c;
					returnVal.currentWeatherImageURL = weather.Image_URL__c;
					
					WeatherData.ForecastWrapper fW = new WeatherData.ForecastWrapper();
					fW.imageURL = weather.Day_One_Image_URL__c;
					fW.text = weather.Day_One_Text__c;
					fW.title = weather.Day_One_Title__c;
					returnVal.forecastList.add( fW);
					
					fW = new WeatherData.ForecastWrapper(); 
					fW.imageURL = weather.Day_Two_Image_URL__c;
					fW.text = weather.Day_Two_Text__c;
					fW.title = weather.Day_Two_Title__c;
					returnVal.forecastList.add( fW);

					fW = new WeatherData.ForecastWrapper(); 
					fW.imageURL = weather.Day_Three_Image_URL__c;
					fW.text = weather.Day_Three_Text__c;
					fW.title = weather.Day_Three_Title__c;
					returnVal.forecastList.add( fW);

					returnVal.sessionId = weather.Session_Id__c;
				}
			} else {

				returnVal = new WeatherData();
				returnVal.currentLocation = WeatherStatics.NO_DATA_FOUND_ERR;
			}
		}

		return returnVal;
	}

	/** 
	 * @description: AuraEnabled method for requesting the ten day forecast of the current location
	 *
	 * @param sessionId, if the page has been visited in the last week, sessionId cookie
	 * 		  will be present on user device, use this to pull previously requested location
	 *		  from cache.
	 *
	 * @return WeatherData, a constructed WeatherData view object containing current weather details.
	 */
	@AuraEnabled
	public static WeatherData serverGetTenDayForecast( String sessionId) {
		WeatherData returnVal;

		// no session Id, start fresh, let client side controller manage
		if ( sessionId == null || sessionId == WeatherStatics.COOKIE_UNDEFINED) {
			
			returnVal = new WeatherData();
			returnVal.currentLocation = WeatherStatics.NO_DATA_FOUND_ERR;

		} else {
			// get Weather__c data by session Id, if found, grab zip code from
			// currently cached location and make API request to get ten day
			// forecast data
			Weather__c weather = WeatherService.getWeatherData( sessionId);

			if ( weather != null) {

				String locationZip = weather.Location_Zip__c;
				String httpEndpoint = WeatherStatics.BASE_WEATHER_URL + WeatherStatics.API_KEY + 
									  	WeatherStatics.FORECAST_10_DAY_QUERY + locationZip + 
											WeatherStatics.JSON_FORMAT;
				String httpResp = HttpService.sendHttpRequest( httpEndpoint, WeatherStatics.GET_METHOD);

				// on succesful request, inflate new WeatherData view object for client-side
				// controller to handle presentation of
				if ( httpResp != WeatherStatics.SERVICE_UNAVAILABLE) {

					WeatherModel forecastModel = 
						WeatherModel.parseForecastJSONResponseToWeatherModel( httpResp, true);

					if ( forecastModel.simpleForecastMapList != null && forecastModel.simpleForecastMapList.size() > 0) {

						returnVal = new WeatherData();
						Map<String,Object> highTempMap = new Map<String,Object>();
						Map<String,Object> lowTempMap = new Map<String,Object>();
						Map<String,Object> dateMap = new Map<String,Object>();
						Map<String,Object> windMap = new Map<String,Object>();

						for ( Integer i = 0; i < forecastModel.simpleForecastMapList.size(); i++) {

							WeatherData.ForecastWrapper fW = new WeatherData.ForecastWrapper();
							
							fW.imageURL = ( String)forecastModel.simpleForecastMapList[i].get(
										  	WeatherModel.FORECAST_ICON_KEY);
							dateMap = ( Map<String,Object>)forecastModel.simpleForecastMapList[i].get(
										WeatherModel.FORECAST_DATE_KEY);
							fW.title = String.valueOf( dateMap.get( WeatherModel.FORECAST_WEEKDAY_KEY)) + ', ' +
									   String.valueOf( dateMap.get( WeatherModel.FORECAST_MONTH_KEY)) + ' ' + 
									   String.valueOf( dateMap.get( WeatherModel.FORECAST_DAY_NUMERIC_KEY));
							String condString = String.valueof( forecastModel.simpleForecastMapList[i].get( 
												WeatherModel.FORECAST_COND_KEY));
							fw.imageText = condString;
							highTempMap = ( Map<String,Object>)forecastModel.simpleForecastMapList[i].get(
											WeatherModel.FORECAST_HIGH_KEY);
							lowTempMap = ( Map<String,Object>)forecastModel.simpleForecastMapList[i].get(
										   WeatherModel.FORECAST_LOW_KEY);
							fW.text = WeatherStatics.WEATHER_HIGH_STRING + 
											String.valueOf( highTempMap.get( WeatherModel.FORECAST_FAHRENHEIT_KEY)) + 
								      	WeatherStatics.WEATHER_LOW_STRING + 
								   			String.valueOf( lowTempMap.get( WeatherModel.FORECAST_FAHRENHEIT_KEY));
							windMap = ( Map<String,Object>)forecastModel.simpleForecastMapList[i].get(
										WeatherModel.FORECAST_AVE_WIND_KEY);
							fW.windText = WeatherStatics.WEATHER_WIND_STRING + 
											String.valueOf( windMap.get( WeatherModel.FORECAST_MPH_KEY)) + ' ' + 
											WeatherStatics.WEATHER_WIND_MPH;
							
							returnVal.forecastList.add ( fW);
						}
					} else {

						returnVal = new WeatherData();
						returnVal.currentLocation = WeatherStatics.NO_DATA_FOUND_ERR;
					}
				} else {

					returnVal = new WeatherData();
					returnVal.currentLocation = WeatherStatics.NO_DATA_FOUND_ERR;
				}
			} else {

				returnVal = new WeatherData();
				returnVal.currentLocation = WeatherStatics.NO_DATA_FOUND_ERR;
			}
		}

		return returnVal;
	}

	/** 
	 * @description: AuraEnabled method initializing the CurrentWeatherRadar Lightning component
	 *
	 * @param sessionId, if the page has been visited in the last week, sessionId cookie
	 * 		  will be present on user device, use this to pull previously requested location
	 *		  from cache.
	 *
	 * @return WeatherData, a constructed WeatherData view object containing current weather details.
	 */
	@AuraEnabled
	public static WeatherData serverInitWeatherRadar( String sessionId) {
		WeatherData returnVal;

		// no session Id, start fresh, let client side controller manage
		if ( sessionId == null || sessionId == WeatherStatics.COOKIE_UNDEFINED) {
			
			returnVal = new WeatherData();
			returnVal.currentLocation = WeatherStatics.NO_DATA_FOUND_ERR;

		} else {
			// get Weather__c data by session Id, if found, build updated weather 
			// radar URL, weather radar requests are always current
			Weather__c weather = WeatherService.getWeatherData( sessionId);

			if ( weather != null) {

				String locationZip = weather.Location_Zip__c;
				returnVal = serverGetCurrentRadarDataByZip( locationZip);
				returnVal.currentZip = locationZip;
				returnVal.currentWeatherRadarImageURL = 
					returnVal.currentWeatherRadarImageURL + WeatherStatics.ZOOM_CONTROL_MAP.get( 
							WeatherStatics.RADAR_DEFAULT_ZOOM_LEVEL);
			} else {

				returnVal = new WeatherData();
				returnVal.currentLocation = WeatherStatics.NO_DATA_FOUND_ERR;
			}
		}

		return returnVal;
	}

	/**
	 * @description: AuraEnabled method for creating the animated current radar URL, 
	 * radar request is a simple URL GET returning an animated gif
	 *
	 * @param inputZip, the input zip code to query radar details for
	 *
	 * @return WeatherData, a constructed WeatherData view object containing current weather details.
	 */
	@AuraEnabled
	public static WeatherData serverGetCurrentRadarDataByZip( String inputZip) {
		WeatherData returnVal;

		if ( inputZip != null && inputZip != '') {

			returnVal = new WeatherData();
			returnVal.currentWeatherRadarImageURL = WeatherService.constructRadarImageURL( inputZip);
			returnVal.currentWeatherRadarImageURL = 
					returnVal.currentWeatherRadarImageURL + WeatherStatics.ZOOM_CONTROL_MAP.get( 
							WeatherStatics.RADAR_DEFAULT_ZOOM_LEVEL);
		}

		return returnVal;
	}

	/** 
	 * @description: AuraEnabled method for zooming the radar image out
	 *
	 * @param  zoomLevel, indicates the desired level of zoom
	 *
	 * @param inputZip, input zip code location
	 *
	 * @return WeatherData, a constructed WeatherData view object containing current weather details.
	 */
	@AuraEnabled
	public static WeatherData serverRadarZoomOut( String zoomLevel, String inputZip) {
		WeatherData returnVal;

		if ( zoomLevel != null && zoomLevel != '' && inputZip != null && inputZip != '') {

			returnVal = CurrentWeatherController.adjustRadarZoom( WeatherStatics.ZOOM_OUT, zoomLevel, inputZip);
		}

		return returnVal;
	}

	/** 
	 * @description: AuraEnabled method for zooming the radar image in
	 *
	 * @param  zoomLevel, indicates the desired level of zoom
	 *
	 * @param inputZip, input zip code location
	 *
	 * @return WeatherData, a constructed WeatherData view object containing current weather details.
	 */
	@AuraEnabled
	public static WeatherData serverRadarZoomIn( String zoomLevel, String inputZip) {
		WeatherData returnVal;

		if ( zoomLevel != null && zoomLevel != '' && inputZip != null && inputZip != '') {

			returnVal = CurrentWeatherController.adjustRadarZoom( WeatherStatics.ZOOM_IN, zoomLevel, inputZip);
		}

		return returnVal;
	}


	/* private instance methods */ 

	/** 
	 * @description: Handles the actual process of zooming the radar image in or out
	 *
	 * @param zoomDirection, indicates zoom in/out
	 *
	 * @param  zoomLevel, indicates the desired level of zoom
	 *
	 * @param inputZip, input zip code location
	 *
	 * @return WeatherData, a constructed WeatherData view object containing current weather details.
	 */
	private static WeatherData adjustRadarZoom( String zoomDirection, String zoomLevel, String inputZip) {
		WeatherData returnVal;

		if ( zoomDirection != null && zoomDirection != '' && zoomLevel != null && zoomLevel != '' &&
				inputZip != null && inputZip !='') {

			Integer zoomInt = Integer.valueOf( zoomLevel);
			// zoom out
			if ( zoomDirection == WeatherStatics.ZOOM_OUT) {

				if ( zoomInt < WeatherStatics.RADAR_MAX_ZOOM_LEVEL &&
					WeatherStatics.ZOOM_CONTROL_MAP.containsKey( zoomInt) ) {

					returnVal = new WeatherData();
					String radarURL = WeatherService.constructRadarImageURL( inputZip);
					radarURL = radarURL + WeatherStatics.ZOOM_CONTROL_MAP.get( zoomInt);
					returnVal.currentWeatherRadarImageURL = radarURL;
				} else {

					returnVal = new WeatherData();
					String radarURL = WeatherService.constructRadarImageURL( inputZip);
					radarURL = radarURL + WeatherStatics.ZOOM_CONTROL_MAP.get( WeatherStatics.RADAR_MAX_ZOOM_LEVEL);
					returnVal.currentWeatherRadarImageURL = radarURL;
				}
			// zoom in
			} else if ( zoomDirection == WeatherStatics.ZOOM_IN) {

				if ( zoomInt >= WeatherStatics.RADAR_MIN_ZOOM_LEVEL &&
					WeatherStatics.ZOOM_CONTROL_MAP.containsKey( zoomInt) ) {

					returnVal = new WeatherData();
					String radarURL = WeatherService.constructRadarImageURL( inputZip);
					radarURL = radarURL + WeatherStatics.ZOOM_CONTROL_MAP.get( zoomInt);
					returnVal.currentWeatherRadarImageURL = radarURL;
				} else {

					returnVal = new WeatherData();
					String radarURL = WeatherService.constructRadarImageURL( inputZip);
					radarURL = radarURL + WeatherStatics.ZOOM_CONTROL_MAP.get( WeatherStatics.RADAR_MIN_ZOOM_LEVEL);
					returnVal.currentWeatherRadarImageURL = radarURL;
				}
			}
		}

		return returnVal;
	}

}