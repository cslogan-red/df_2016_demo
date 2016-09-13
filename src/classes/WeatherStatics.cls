/** 
 * WeatherStatics.cls
 *
 * @description: Reusable constants class
 * 
 * @author: Chase Logan
 */
public class WeatherStatics {
	
	// req/resp related
	public static final Integer HTTP_OK = 200;
	public static final String GET_METHOD = 'GET';
	public static final String SERVICE_UNAVAILABLE = 'SERVICE UNAVAILABLE';
	
	// endpoint related
	public static final String API_KEY = '<insert your api key value here>';
	public static final String BASE_WEATHER_URL = 'http://api.wunderground.com/api/';
	public static final String CURRENT_COND_QUERY = '/conditions/q/';
	public static final String FORECAST_QUERY = '/forecast/q/';
	public static final String FORECAST_10_DAY_QUERY = '/forecast10day/q/';
	public static final String RADAR_QUERY = '/animatedradar/q/';
	public static final String RADAR_QUERY_PARAMS = '?newmaps=1&timelabel=1&timelabel.y=20&timelabel.x=5&num=10&delay=30&noclutter=1&smooth=1&width=500';
	public static final String JSON_FORMAT = '.json';
	public static final String GIF_FORMAT = '.gif';
	
	// error messages
	public static final String NO_MATCH_ERR = 'No locations match provided search criteria, please try again.';
	public static final String SERVICE_UNAVAIL_ERR = 'Service unavailable, please try again.';
	public static final String INVALID_DATA_ERR = 'Invalid search criteria, please try again.';
	public static final String NO_DATA_FOUND_ERR = 'NO_DATA';

	// general
	public static final String COOKIE_UNDEFINED = 'undefined';
	public static final Integer CACHED_REQUEST_STALE_TIME = 1800000; // 30 minutes in milliseconds
	public static final Integer RADAR_DEFAULT_ZOOM_LEVEL = 1;
	public static final Integer RADAR_MAX_ZOOM_LEVEL = 5;
	public static final Integer RADAR_MIN_ZOOM_LEVEL = 0;
	public static final Map<Integer,String> ZOOM_CONTROL_MAP = 
							new Map<Integer,String> { 0 => '&radius=10', 
													  1 => '&radius=25', 
													  2 => '&radius=50', 
													  3 => '&radius=100', 
													  4 => '&radius=250', 
													  5 => '&radius=500' };
	
	public static final String WEATHER_HIGH_STRING = 'High: ';
	public static final String WEATHER_LOW_STRING = ' Low: ';
	public static final String WEATHER_WIND_STRING = 'Wind @ ';
	public static final String WEATHER_WIND_MPH = 'MPH';
	public static final String ZOOM_OUT = 'zoom_out';
	public static final String ZOOM_IN = 'zoom_in';

}