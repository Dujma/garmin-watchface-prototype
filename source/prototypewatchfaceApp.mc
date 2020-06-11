using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class prototypewatchfaceApp extends App.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
    
    }

    function onStop(state) {

    }

    function getInitialView() {
    	//! TODO: First check if weatherUpdated is null, if true, register for update in moment (5 seconds in future), delete the event and then register with duration
    	if(Toybox.System has :ServiceDelegate) {
    		Background.registerForTemporalEvent(new Time.Duration(5 * 60));
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