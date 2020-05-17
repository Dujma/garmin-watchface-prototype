using Toybox.Application;
using Toybox.WatchUi;

class prototypewatchfaceApp extends Application.AppBase {
	var initialView;
	
    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
    
    }

    function onStop(state) {
    
    }

    function getInitialView() {
    	initialView = new prototypewatchfaceView();
    	
        return [ initialView ];
    }

    function onSettingsChanged() {
    	initialView.handleSettingUpdate();
    
        WatchUi.requestUpdate();
    }
}