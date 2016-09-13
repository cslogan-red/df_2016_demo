/** 
 * WeatherModel.cls
 *
 * @description: Model class for deserialization of JSON data into WeatherModel objects
 * 
 * @author: Chase Logan
 */
public class WeatherModel {
	
	/* static constants for retrieving map values from WeatherModel instances */
	public static final String DISPLAY_LOC_KEY = 'display_location';
	public static final String DISPLAY_LOC_FULL_KEY = 'full';
	public static final String DISPLAY_LOC_ZIP_KEY = 'zip';
	public static final String DISPLAY_LOC_LAT_KEY = 'latitude';
	public static final String DISPLAY_LOC_LNG_KEY = 'longitude';
	
	public static final String CURRENT_OBV_KEY = 'current_observation';
	public static final String CURRENT_OBV_TEMP_KEY = 'temperature_string';
	public static final String CURRENT_OBV_WEATHER_KEY = 'weather';
	public static final String CURRENT_OBV_HUMIDITY_KEY = 'relative_humidity';
	public static final String CURRENT_OBV_WIND_KEY = 'wind_string';
	public static final String CURRENT_OBV_ICON_KEY = 'icon_url';

	public static final String FORECAST_KEY = 'forecast';
	public static final String FORECAST_TXT_KEY = 'txt_forecast';
	public static final String FORECAST_SIMPLE_KEY = 'simpleforecast';
	public static final String FORECAST_DAY_KEY = 'forecastday';
	public static final String FORECAST_PERIOD_KEY = 'period';
	public static final String FORECAST_ICON_KEY = 'icon_url';
	public static final String FORECAST_TITLE_KEY = 'title';
	public static final String FORECAST_TEXT_KEY = 'fcttext';
	public static final String FORECAST_HIGH_KEY = 'high';
	public static final String FORECAST_LOW_KEY = 'low';
	public static final String FORECAST_DATE_KEY = 'date';
	public static final String FORECAST_WEEKDAY_KEY = 'weekday';
	public static final String FORECAST_MONTH_KEY = 'monthname';
	public static final String FORECAST_DAY_NUMERIC_KEY = 'day';
	public static final String FORECAST_FAHRENHEIT_KEY = 'fahrenheit';
	public static final String FORECAST_COND_KEY = 'conditions';
	public static final String FORECAST_AVE_WIND_KEY = 'avewind';
	public static final String FORECAST_MPH_KEY = 'mph';
	public static final Integer FORECAST_DAY_ONE = 0;
	public static final Integer FORECAST_DAY_TWO = 2;
	public static final Integer FORECAST_DAY_THREE = 4;
	
	public Map<String,Object> currentObservationMap { get; set; }
	public Map<String,Object> displayLocationMap { get; set; }
	public List<Map<String,Object>> forecastMapList { get; set; }
	public List<Map<String,Object>> simpleForecastMapList { get; set; }
	public String dayOneCachedText { get; set; }
	public String dayTwoCachedText { get; set; }
	public String dayThreeCachedText { get; set; }
	
	/* default ctor */
	public WeatherModel() {
		
		currentObservationMap = new Map<String,Object>();
		displayLocationMap = new Map<String,Object>();
		forecastMapList = new List<Map<String,Object>>();
		simpleForecastMapList = new List<Map<String,Object>>();
	}
	
	/** 
	 * Takes the provided input JSON string and parses to a new WeatherModel object
	 *
	 * @param jsonString - the raw JSON string
	 * @returns WeatherModel - a new WeatherModel object
	 */
	public static WeatherModel parseJSONResponseToWeatherModel( String jsonString) {
		WeatherModel returnVal = null;
		
		if ( jsonString != null && jsonString != '') {
			
			try {
				
				Map<String,Object> topLevelMap = 
					( Map<String,Object>)JSON.deserializeUntyped( jsonString);
					System.debug( 'DEBUG:::' + topLevelMap);
					
				Map<String,Object> currentObvMap = 
					( Map<String,Object>)topLevelMap.get( WeatherModel.CURRENT_OBV_KEY);
					System.debug( 'DEBUG:::' + currentObvMap);
					
				Map<String,Object> displayMap = 
					( Map<String,Object>)currentObvMap.get( WeatherModel.DISPLAY_LOC_KEY);
					System.debug( 'DEBUG:::' + displayMap);
					
				returnVal = new WeatherModel();
				returnVal.currentObservationMap = currentObvMap;
				returnVal.displayLocationMap = displayMap;
			} catch ( Exception e) {
				
				System.debug( 'DEBUG:::Exception in WeatherModel.parseJSONResponseToWeatherModel, message: ' + 
					e.getMessage());
				returnVal = new WeatherModel();
			}
		}
		
		return returnVal;
	}

	/** 
	 * Takes the provided input JSON string and parses to a new WeatherModel object, overloaded option defaults to three day
	 * forecast only
	 *
	 * @param jsonString, the raw JSON string to parse
	 *
	 * @return WeatherModel - a constructed WeatherModel object
	 */	
	public static WeatherModel parseForecastJSONResponseToWeatherModel( String jsonString) {

		return WeatherModel.parseForecastJSONResponseToWeatherModel( jsonString, false, false);
	}

	/** 
	 * Takes the provided input JSON string and parses to a new WeatherModel object, overloaded option to specify
	 * either a three day or ten day forecast
	 *
	 * @param jsonString, the raw JSON string to parse
	 *
	 * @param includeTenDay, if ten day API request was made, data is returned in same format, set to true to parse ten day
	 *
	 * @return WeatherModel - a constructed WeatherModel object
	 */	
	public static WeatherModel parseForecastJSONResponseToWeatherModel( String jsonString, Boolean includeTenDay) {

		return WeatherModel.parseForecastJSONResponseToWeatherModel( jsonString, includeTenDay, false);
	}

	/** 
	 * Takes the provided input JSON string and parses to a new WeatherModel object
	 *
	 * @param jsonString, the raw JSON string to parse
	 *
	 * @param includeTenDay, if ten day API request was made, data is returned in same format, set to true to parse ten day
	 *
	 * @param isDebug, if true, include debug output
	 *
	 * @return WeatherModel - a constructed WeatherModel object
	 */
	public static WeatherModel parseForecastJSONResponseToWeatherModel( String jsonString, Boolean includeTenDay, Boolean isDebug) {
		WeatherModel returnVal = null;
		Integer THREE_DAY_FORECAST = 3;
		Integer TEN_DAY_FORECAST = 10;

		if ( jsonString != null && jsonString != '') {

			try {

				Map<String,Object> topLevelMap = 
					( Map<String,Object>)JSON.deserializeUntyped( jsonString);
					if ( isDebug) System.debug( 'DEBUG:::' + topLevelMap);

				Map<String,Object> currForecastMap = 
					( Map<String,Object>)topLevelMap.get( WeatherModel.FORECAST_KEY);
					if ( isDebug) System.debug( 'DEBUG:::' + currForecastMap);

				Map<String,Object> txtForecastMap = 
					( Map<String,Object>)currForecastMap.get( WeatherModel.FORECAST_TXT_KEY);
					if ( isDebug) System.debug( 'DEBUG:::' + txtForecastMap);

				Map<String,Object> simpleForecastMap = 
					( Map<String,Object>)currForecastMap.get( WeatherModel.FORECAST_SIMPLE_KEY);
					if ( isDebug) System.debug( 'DEBUG:::' + simpleForecastMap);

				List<Object> objectList = 
					( List<Object>)txtForecastMap.get( WeatherModel.FORECAST_DAY_KEY);
					if ( isDebug) System.debug( 'DEBUG:::' + objectList);

				List<Object> simpleForecastList = 
					( List<Object>)simpleForecastMap.get( WeatherModel.FORECAST_DAY_KEY);
					if ( isDebug) System.debug( 'DEBUG:::' + simpleForecastList);

				// two forecast types are returned as JSON array's, both are used
				// to get different pieces of data only present in each type
				returnVal = new WeatherModel();
				returnVal.forecastMapList.add(
					( Map<String,Object>)objectList[ WeatherModel.FORECAST_DAY_ONE] );
				returnVal.forecastMapList.add(
					( Map<String,Object>)objectList[ WeatherModel.FORECAST_DAY_TWO] );
				returnVal.forecastMapList.add(
					( Map<String,Object>)objectList[ WeatherModel.FORECAST_DAY_THREE] );
				
				// include 10 day? default to a 3 day forecast unless 10 day flag is set
				if ( includeTenDay != null && includeTenDay) {

					for ( Integer i = 0; i < TEN_DAY_FORECAST; i++) {

						returnVal.simpleForecastMapList.add(
							( Map<String,Object>)simpleForecastList[ i] );
					}
				} else {

					for ( Integer i = 0; i < THREE_DAY_FORECAST; i++) {

						returnVal.simpleForecastMapList.add(
							( Map<String,Object>)simpleForecastList[ i] );
					}
				}
			} catch ( Exception e) {

				System.debug( 'DEBUG:::Exception in WeatherModel.parseForecastJSONResponseToWeatherModel, message: ' +
					e.getMessage());
				returnVal = new WeatherModel();
			}
		}

		return returnVal;
	}
	
}