using Toybox.Background;
using Toybox.System as Sys;

(:background)
class prototypewatchfaceServiceDelegate extends Sys.ServiceDelegate {
	function initialize() {
		Sys.ServiceDelegate.initialize();
	}
	
    function onTemporalEvent() {
    	getCurrentWeather();
    }
    
    function onWeatherReceived(responseCode, data) {
   		if(responseCode == 200) {
   			data["updated"] = new Time.Moment(Time.now().value()).value();

       		Background.exit(data);
       	}
	}

   	function getCurrentWeather() {
		var url = "https://api.openweathermap.org/data/2.5/weather",
			currentLocation = getCurrentLocation(),
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
       	Communications.makeWebRequest(url, params, options, method(:onWeatherReceived));
  	}
  	
  	function getCurrentLocation() {
		var currentLocation = Activity.getActivityInfo().currentLocation;
		
		if(currentLocation != null) {
			return currentLocation.toDegrees();
		}
		return currentLocation;
	}
}