using Toybox.Background;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Application as App;

(:background)
class prototypewatchfaceServiceDelegate extends Sys.ServiceDelegate {
	function initialize() {
		Sys.ServiceDelegate.initialize();
	}
	
    function onTemporalEvent() {
    	getCurrentWeather(method(:onWeatherReceived));
    }
    
    function onWeatherReceived(responseCode, data) {
    	var info = null;
    	
   		if(responseCode == 200) {
   			info = { 
   				"updated" => new Time.Moment(Time.now().value()).value(),
   				"sunrise" => data["sys"]["sunrise"],
   				"sunset" => data["sys"]["sunset"],
   				"windSpeed" => data["wind"]["speed"],
   				"windDeg" => data["wind"]["deg"],
   				"city" => data["name"],
   				"weatherId" => data["weather"][0]["id"],
   				"temp" => data["main"]["temp"],
   				"pressure" => data["main"]["pressure"],
   				"humidity" => data["main"]["humidity"],
   			};
       	} else {
       		var currentLocation = Utils.getCurrentLocation();
       		
       		if(currentLocation == null) {
	       		//! TODO: Notify user that location needs to be updated...
	       		Sys.println("Location needs to be updated!");
       		} else {
       			Sys.println("There was a problem processing the request.");
       		}
       	}
       	Background.exit(info);
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
	   		Sys.println("Location for weather request is taken from the watch (" + params["lat"] + ", " + params["lon"] + ")");
		} else if(App.getApp().getProperty("locationUpdated") != null) {
			params = {
	      		"lat" => App.getApp().getProperty("lat").toString(),
	      		"lon" => App.getApp().getProperty("lon").toString(),
	      		"appid" => "02dc664d36e7cf1693b2ea91c42db7ef"
	   		};
	   		Sys.println("Location for weather request is taken from the cache (" + params["lat"] + ", " + params["lon"] + ")");
		} else {
			Sys.println("Location information needed for weather request is not available.");
		}
   		var options = {
           	:method => Communications.HTTP_REQUEST_METHOD_GET
   		};
       	Communications.makeWebRequest(url, params, options, callback);
  	}
}