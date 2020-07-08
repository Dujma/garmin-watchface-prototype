using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Time;

(:background)
class prototypewatchfaceApp extends App.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
    
    }

    function onStop(state) {

    }

    function getInitialView() {
    	if(Toybox.System has :ServiceDelegate) {
    		if(App.getApp().getProperty("WeatherUpdated") == null) {
    			var lastRunTime = Background.getLastTemporalEventTime();
    			
				if(new Time.Moment(Time.now().value()).subtract(lastRunTime).value() < new Time.Duration(5 * 60).value()) {
				    var nextRunTime = lastRunTime.add(new Time.Duration(5 * 60));
				    
				    Background.registerForTemporalEvent(nextRunTime);
				} else {
				    var fiveSecondsFromNow = new Time.Moment(Time.now().value());
    			
	    			fiveSecondsFromNow.add(new Time.Duration(5));
	    			
	    			Background.registerForTemporalEvent(fiveSecondsFromNow);
				}
    		} else {
    			Background.registerForTemporalEvent(new Time.Duration(App.getApp().getProperty("WeatherRefreshInterval") * 60));
    		}
    	}
        return [ new prototypewatchfaceView() ];
    }

    function onSettingsChanged() {
    	MainController.handleSettingUpdate();
    
        Ui.requestUpdate();
    }
    
    function getServiceDelegate(){
        return [ new prototypewatchfaceServiceDelegate() ];
    }
    
    function onBackgroundData(data) {
    	if(App.getApp().getProperty("WeatherUpdated") == null) {
			Background.registerForTemporalEvent(new Time.Duration(App.getApp().getProperty("WeatherRefreshInterval") * 60));
    	}
    	updateWeather(data);
    }
    
    function updateWeather(data) {
    	if(data != null) {
    		var app = App.getApp();
    		var today = Time.today().value();
    	
	    	app.setProperty("WeatherUpdated", data["updated"]);
	        app.setProperty("Sunrise", data["sunrise"].toNumber() - today);
	        app.setProperty("Sunset", data["sunset"].toNumber() - today);
	        app.setProperty("WindDeg", data["windDeg"]);
	        app.setProperty("WindSpeed", data["windSpeed"]);
	        app.setProperty("City", data["city"]);
	        app.setProperty("WeatherId", data["weatherId"]);
	        app.setProperty("Temp", data["temp"]);
	        app.setProperty("Pressure", data["pressure"]);
	        app.setProperty("Humidity", data["humidity"]);
	        
	        var location = Utils.getCurrentLocation();

	        if(location != null) {
	        	app.setProperty("LocationUpdated", data["updated"]);
		        app.setProperty("Lat", location[0]);
	    		app.setProperty("Lon", location[1]);

	    		Sys.println("Location in cache is updated to: " + location[0] + ", " + location[1]);
	        }
	        Ui.requestUpdate();
    	}
    }
}