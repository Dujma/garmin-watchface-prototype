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
    		if(App.getApp().getProperty("weatherUpdated") == null) {
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
    	if(App.getApp().getProperty("weatherUpdated") == null) {
			Background.registerForTemporalEvent(new Time.Duration(App.getApp().getProperty("WeatherRefreshInterval") * 60));
    	}
    	updateWeather(data);
        
        Ui.requestUpdate();
    }
    
    function updateWeather(data) {
    	var app = App.getApp();
    	
        app.setProperty("weatherUpdated", data["updated"]);
        app.setProperty("sunrise", data["sunrise"]);
        app.setProperty("sunset", data["sunset"]);
        app.setProperty("windSpeed", data["windSpeed"]);
        app.setProperty("windDeg", data["windDeg"]);
        app.setProperty("city", data["city"]);
        app.setProperty("weatherId", data["weatherId"]);
        app.setProperty("temp", data["temp"]);
        app.setProperty("pressure", data["pressure"]);
        app.setProperty("humidity", data["humidity"]);
    }
}