using Toybox.Background;
using Toybox.System as Sys;

(:background)
class prototypewatchfaceServiceDelegate extends Sys.ServiceDelegate {
	function initialize() {
		Sys.ServiceDelegate.initialize();
	}
	
    function onTemporalEvent() {
    	getCurrentWeather(method(:onWeatherReceived));
    }
    
    function onWeatherReceived(responseCode, data) {
   		if(responseCode == 200) {
   			var weather = { 
   				"updated" => new Time.Moment(Time.now().value()).value(),
   				"sunrise" => data["sys"]["sunrise"],
   				"sunset" => data["sys"]["sunset"],
   				"windSpeed" => data["wind"]["speed"],
   				"windDeg" => data["wind"]["deg"],
   				"city" => data["name"],
   				"weatherId" => data["weather"][0]["id"],
   				"temp" => data["main"]["temp"],
   				"pressure" => data["main"]["pressure"],
   				"humidity" => data["main"]["humidity"]
   			};
       		Background.exit(weather);
       	}
	}

	function getCurrentWeather(callback) {
		var url = "https://api.openweathermap.org/data/2.5/weather",
			currentLocation = Utils.getCurrentLocation(),
		    params = null;
		
		// Test in simulator
		// currentLocation = [43.34, 17.79];

		if(currentLocation != null) {
			params = {
	      		"lat" => currentLocation[0].toString(),
	      		"lon" => currentLocation[1].toString(),
	      		"appid" => "02dc664d36e7cf1693b2ea91c42db7ef"
	   		};
		}
   		var options = {
           	:method => Communications.HTTP_REQUEST_METHOD_GET
   		};
       	Communications.makeWebRequest(url, params, options, callback);
  	}
}