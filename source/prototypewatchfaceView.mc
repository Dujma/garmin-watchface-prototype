using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;

class prototypewatchfaceView extends WatchUi.WatchFace {
	// Hours
	hidden var fontRobotoBlack76;
	hidden var hoursText;
	hidden var hoursFormat;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        
        clipTest = WatchUi.loadResource(Rez.Drawables.clipTest);
        backgroundTest = WatchUi.loadResource(Rez.Drawables.backgroundTest);
        
        var test = WatchUi.loadResource(Rez.Fonts.RobotoBlack76);

        hoursText = new WatchUi.Text({
            :color => Graphics.COLOR_WHITE,
            :font  => test,
            :locX  => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY  => WatchUi.LAYOUT_VALIGN_CENTER
        });
        hoursFormat = Application.getApp().getProperty("AddLeadingZero") ? "%02d" : "%d";
    }
	var clipTest;
	var backgroundTest;
    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    	
    }

    // Update the view
    function onUpdate(dc) {

        var clockTime = System.getClockTime();
        var hours = clockTime.hour;

        // Update the view
        var view = View.findDrawableById("TimeLabel");
        //view.setColor(Application.getApp().getProperty("ForegroundColor"));
        //view.setText(timeString);

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
		
		hoursText.setText((hours - 12).format(hoursFormat));
		hoursText.draw(dc);

		// implement onHoursUpdate onMinuteUpdate onSettingsChanged
		
		/*dc.drawBitmap(cx, cy, clipTest);
		dc.setClip(cx - 100, cy, 10, 10);
		dc.drawBitmap(cx - 100, cy, clipTest);*/
		
		//dc.drawBitmap(0, 0, backgroundTest);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}
