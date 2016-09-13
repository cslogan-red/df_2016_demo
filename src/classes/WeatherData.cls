/** 
 * WeatherData.cls
 * 
 * @description: View class with @AuraEnabled properties for representing data in Lightning components.
 *
 * @author: Chase Logan
 */
public class WeatherData {

	private final String COLON_CHAR = ':';
	private final String HTTPS_PREFIX = 'https';

	// default ctor
	public WeatherData() {}
	
	@AuraEnabled
	public String currentLocation { get; set; }
	
	@AuraEnabled
	public String currentZip { get; set; }
	
	@AuraEnabled
	public String currentTemp { get; set; }
	
	@AuraEnabled
	public String currentWeather { get; set; }
	
	@AuraEnabled
	public String currentHumidity { get; set; }
	
	@AuraEnabled
	public String currentWind { get; set; }

	@AuraEnabled
	public String currentWeatherImageURL { 
		
		get; 
		set {
			this.currentWeatherImageURL = this.HTTPS_PREFIX + 
				value.substring( value.indexOf( this.COLON_CHAR));
		}
	}

	@AuraEnabled
	public String currentWeatherRadarImageURL { 

		get; 
		set {
			this.currentWeatherRadarImageURL = this.HTTPS_PREFIX +
				value.substring( value.indexOf( this.COLON_CHAR));
		}
	}

	@AuraEnabled
	public String sessionId { get; set; }

	@AuraEnabled
	public List<ForecastWrapper> forecastList { 

		get { 
			return ( this.forecastList == null ? 
						this.forecastList = new List<ForecastWrapper>() : this.forecastList); 
		} 
		set;
	}
	
	// wrapper class for displaying forecastDay data
	// 1-n days are returned as a List to client-side controller
	// for presentation
	public class ForecastWrapper {

		private final String COLON_CHAR = ':';
		private final String HTTPS_PREFIX = 'https';
		
		@AuraEnabled
		public String title { get; set; }
		@AuraEnabled	
		public String text { get; set; }
		@AuraEnabled
		public String windText { get; set; }
		@AuraEnabled
		public String imageText { get; set; }
		@AuraEnabled
		public String imageURL { 

			get; 
			set {
				this.imageURL = this.HTTPS_PREFIX +
					value.substring( value.indexOf( this.COLON_CHAR));
			}
		}
		
	}
	
}