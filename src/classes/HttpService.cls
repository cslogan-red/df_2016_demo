/** 
 * HttpService.cls
 * 
 * @abstract: Service class for constructing and sending HTTP requests
 *
 * @author: Chase Logan
 */
public class HttpService {
	
	/** 
	 * Constructs an HttpRequest based on provided input endpoint and method, if no 
	 * method is provided, default to GET_METHOD
	 *
	 * @param httpEndpoint - the URL to send the request
	 * @param httpMethod - the http request method (IE GET, PUT, etc) 
	 */
	public static String sendHttpRequest( String httpEndpoint, String httpMethod) {
		String returnVal = '';
		
		if ( httpEndpoint != null && httpEndpoint != '') {
			
			try {
				
				// set request endpoint and method
				HttpRequest httpReq = new HttpRequest();
				httpReq.setEndpoint( httpEndpoint);
				httpReq.setMethod( 
					( httpMethod != null && httpMethod != '' ? httpMethod : 
						WeatherStatics.GET_METHOD));
				
				// execute request and return response body
				Http http = new Http();
				HttpResponse httpResp = http.send( httpReq);
				
				if ( httpResp.getStatusCode() == WeatherStatics.HTTP_OK) {
					returnVal = httpResp.getBody();
				} else {
					returnVal = WeatherStatics.SERVICE_UNAVAILABLE;
				}
				
			} catch ( Exception e) {
				
				System.debug( 'DEBUG:::Exception in HttpService.sendHttpRequest, message: ' 
					+ e.getMessage());
			}
			
		}

		return returnVal;
	}

}