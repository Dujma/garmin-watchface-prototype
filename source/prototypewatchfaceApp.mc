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
        App.getApp().setProperty("weather", data);
        
        Ui.requestUpdate();
    } 
}