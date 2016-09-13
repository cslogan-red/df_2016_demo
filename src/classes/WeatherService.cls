/** 
 * WeatherService.cls
 * 
 * @description: Service class for providing data and performing weather related actions.
 *
 * @author: Chase Logan
 */
public abstract class WeatherService {

	/**
	 * Caches requested weather data in Weather__c custom object, on page load
	 * and as long as stale timeout is not yet hit, data is pulled from cache object
	 * instead of via API.
	 *
	 * @param wModel - a constructed WeatherModel object
	 * 
	 * @return returnVal - a boolean indicating success or failure of caching results
	 */ 
	public static boolean cacheWeatherData( WeatherModel wModel, String sessionId) {
		boolean returnVal = false;

			if ( wModel != null && wModel.displayLocationMap.size() != 0 &&
					sessionId != null && sessionId != '' ) {

				Weather__c weather = new Weather__c();
				weather.Session_ID__c = sessionId;
				weather.Previous_Location__c = (String)wModel.displayLocationMap.get( 
					WeatherModel.DISPLAY_LOC_FULL_KEY);
				weather.Location_Zip__c = (String)wModel.displayLocationMap.get( 
					WeatherModel.DISPLAY_LOC_ZIP_KEY);
				weather.Requested_Time__c = Datetime.now();
				weather.Temperature__c = (String)wModel.currentObservationMap.get( 
					WeatherModel.CURRENT_OBV_TEMP_KEY);
				weather.Weather__c = (String)wModel.currentObservationMap.get( 
					WeatherModel.CURRENT_OBV_WEATHER_KEY);
				weather.Windspeed__c = (String)wModel.currentObservationMap.get(
					WeatherModel.CURRENT_OBV_WIND_KEY);
				weather.Image_URL__c = (String)wModel.currentObservationMap.get(
    				WeatherModel.CURRENT_OBV_ICON_KEY);
				
				if ( wModel.forecastMapList != null && wModel.forecastMapList.size() > 0 ) {

					for ( Integer i = 0; i < wModel.forecastMapList.size(); i++) {

						weather.Day_One_Title__c = ( String)wModel.forecastMapList[i].get(
							WeatherModel.FORECAST_TITLE_KEY);
						weather.Day_One_Image_URL__c = ( String)wModel.forecastMapList[i].get(
							WeatherModel.FORECAST_ICON_KEY);
						i++;

						weather.Day_Two_Title__c = ( String)wModel.forecastMapList[i].get(
							WeatherModel.FORECAST_TITLE_KEY);
						weather.Day_Two_Image_URL__c = ( String)wModel.forecastMapList[i].get(
							WeatherModel.FORECAST_ICON_KEY);
						i++;

						weather.Day_Three_Title__c = ( String)wModel.forecastMapList[i].get(
							WeatherModel.FORECAST_TITLE_KEY);
						weather.Day_Three_Image_URL__c = ( String)wModel.forecastMapList[i].get(
							WeatherModel.FORECAST_ICON_KEY);
						i++;
					}
					
					weather.Day_One_Text__c = wModel.dayOneCachedText;
					weather.Day_Two_Text__c = wModel.dayTwoCachedText;
					weather.Day_Three_Text__c = wModel.dayThreeCachedText;
				}
				
				// upsert data
    			try {
    				
    				upsert weather;
    				returnVal = true;
    			} catch( Exception e) {
    				
    				System.debug( 'DEBUG:::Exception in cacheWeatherData, message: ' + 
    					e.getMessage() );
    			}			
			}

		return returnVal;
	}

	/**
	 * Retrieves a previously created Weather__c record by session Id.
	 *
	 * @param sessionId - a previously stored session ID, retrieved via device cookie
	 * 
	 * @return returnVal - a Weather__c object containing previous request information
	 */
	public static Weather__c getWeatherData( String sessionId) {
		Weather__c returnVal;

		if ( sessionId != null && sessionId != '') {

			try {

				returnVal = [select Id, Session_ID__c, Previous_Location__c, Location_Zip__c,
									Requested_Time__c, Temperature__c, Weather__c, Windspeed__c, 
									Image_URL__c, Day_One_Title__c, Day_One_Image_URL__c, Day_One_Text__c,
									Day_Two_Title__c, Day_Two_Image_URL__c, Day_Two_Text__c, Day_Three_Title__c,
									Day_Three_Image_URL__c, Day_Three_Text__c
							   from Weather__c
							  where Session_ID__c = :sessionId];
			} catch ( DmlException e) {
				
				System.debug( 'DEBUG:::DmlException occurred in WeatherService.getWeatherData(), message: ' 
					+ e.getMessage());
			} catch ( Exception e) {

				System.debug( 'DEBUG:::Exception occurred in WeatherService.getWeatherData(), message: ' 
					+ e.getMessage());
			}
		}

		return returnVal;
	}

	/**
	 * Deletes a created Weather__c record(s) by session Id
	 *
	 * @param sessionId - the Session_Id__c value of the record to be deleted.
	 */
	public static void deleteWeatherData ( String sessionId) {

		if ( sessionId != null && sessionId != '') {

			try {
 
				List<Weather__c> weatherList = [select Id, Session_ID__c
												  from Weather__c
												 where Session_ID__c = :sessionId];

				if ( weatherList != null && weatherList.size() > 0) {
					
					delete weatherList;
				}
			} catch ( Exception e) {
				
				System.debug( 'DEBUG:::Exception occurred in WeatherServicec.deleteWeatherData(), message: '
					+ e.getMessage());
			}
		}
	}

	/**
	 * Constructs the API URL for the animated radar image; is a simple GET
	 * so URL is simply presented in an image tag to retrieve most recent
	 * animated gif
	 *
	 * @param inputZip - the Sting containing the input zip code
	 *
	 * @return returnVal - a String containing the completed image URL.
	 */
	public static String constructRadarImageURL( String inputZip) {
		String returnVal = '';

		if ( inputZip != null && inputZip != '') {

			returnVal = WeatherStatics.BASE_WEATHER_URL + WeatherStatics.API_KEY +
						WeatherStatics.RADAR_QUERY + inputZip + WeatherStatics.GIF_FORMAT + 
						WeatherStatics.RADAR_QUERY_PARAMS;
		}

 		return returnVal;
	}

	/**
	 * Creates a randomly generated session Id for caching weather results,
	 * session Id is stored in a cookie on user device and retrieved
	 * on page initialization.
	 *
	 * @return returnVal - a String containing the generated session Id.
	 */
	public static String generateSessionId() {
		String returnVal = '';

		Double randomDouble1 = Math.random();
		Double randomDouble2 = Math.random();
		String randomString1 = String.valueOf( randomDouble1);
		String randomString2 = String.valueOf( randomDouble2);

		if ( randomString1.contains( '.')) {
			
			randomString1 = randomString1.substring( randomString1.indexOf( '.') + 1);
		}

		if ( randomString2.contains( '.')) {
			
			randomString2 = randomString2.substring( randomString2.indexOf( '.') + 1);
		}

		returnVal = randomString1 + randomString2;
		
		return returnVal;
	}

	/**
	 * Checks for stale session data by comparing now to request time
	 * in milliseconds. If request is older than CACHED_REQUEST_STALE_TIME
	 * limit then data is marked as stale.
	 *
	 * @param weatherReqDT - the Datetime to compare against.
	 *
	 * @return returnVal - a Boolean indicating status of check.
	 */
	public static Boolean checkForStaleData( Datetime weatherReqDT) {
		Boolean returnVal = true;

		if ( weatherReqDT != null ) {

			Datetime dt = Datetime.now();
			if ( ( dt.getTime() - weatherReqDT.getTime()) >
					WeatherStatics.CACHED_REQUEST_STALE_TIME ) {

				returnVal = true;
			} else {
				
				returnVal = false;
			}
		}

		return returnVal;
	}

}