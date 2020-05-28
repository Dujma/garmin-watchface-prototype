using Toybox.Application;
using Toybox.WatchUi;

class prototypewatchfaceApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
    
    }

    function onStop(state) {
    
    }

    function getInitialView() {
        return [ new prototypewatchfaceView() ];
    }

    function onSettingsChanged() {
    	MainController.handleSettingUpdate();
    
        WatchUi.requestUpdate();
    }
}