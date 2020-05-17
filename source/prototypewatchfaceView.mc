using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;
using Toybox.Time;
using Toybox.Time.Gregorian;

class prototypewatchfaceView extends WatchUi.WatchFace {
	// Hours
	hidden var hoursText;
	hidden var hoursFormat;
	
	// Minutes
	hidden var minutesText;
	hidden var minutesColon;
	
	// Seconds
	hidden var secondsText;
	
	// Date
	hidden var dateText;
	
	// Part of day
	hidden var partOfDayText;

	// Fonts
	hidden var fontRobotoBlack81;
	hidden var fontRobotoBold55;
	hidden var fontRobotoCondenseBold20;
	hidden var fontRobotoCondenseBold12;
	
	// Other
	hidden var showSeconds;
	hidden var mockBackground;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        
        mockBackground = WatchUi.loadResource(Rez.Drawables.MockBackground);
        
        fontRobotoBlack81 = WatchUi.loadResource(Rez.Fonts.RobotoBlack81);
        fontRobotoBold55 = WatchUi.loadResource(Rez.Fonts.RobotoBold55);
        fontRobotoCondenseBold20 = WatchUi.loadResource(Rez.Fonts.RobotoCondenseBold20);
        fontRobotoCondenseBold12 = WatchUi.loadResource(Rez.Fonts.RobotoCondenseBold12);
        
        var cx = dc.getWidth() / 2;
        var cy = dc.getWidth() / 2;
        var addLeadingZero = Application.getApp().getProperty("AddLeadingZero");

        hoursText = new WatchUi.Text({
            :color => Graphics.COLOR_WHITE,
            :font  => fontRobotoBlack81,
            :locX  => cx * 0.723 + (dc.getTextWidthInPixels(addLeadingZero ? "00" : "0", fontRobotoBlack81) / 2),
            :locY  => cy * 0.992
        });
        minutesText = new WatchUi.Text({
            :color => Graphics.COLOR_LT_GRAY,
            :font  => fontRobotoBold55,
            :locX  => cx * 1.423,
            :locY  => cy * 0.930
        });
        minutesColon = new WatchUi.Text({
            :color => Graphics.COLOR_LT_GRAY,
            :font  => fontRobotoBold55,
            :locX  => cx * 1.123,
            :locY  => cy * 0.930
        });
        dateText = new WatchUi.Text({
            :color => Graphics.COLOR_WHITE,
            :font  => fontRobotoCondenseBold20,
            :locX  => cx * 1.423,
            :locY  => cy * 1.169
        });
        partOfDayText = new WatchUi.Text({
            :color => Graphics.COLOR_WHITE,
            :font  => fontRobotoCondenseBold12,
            :locX  => cx * 0.307,
            :locY  => cy * 1.192
        });
        secondsText = new WatchUi.Text({
            :color => Graphics.COLOR_LT_GRAY,
            :font  => fontRobotoCondenseBold12,
            :locX  => cx * 1.707,
            :locY  => cy * 0.815
        });
        hoursText.setJustification(Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_RIGHT);
        minutesText.setJustification(Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
        minutesColon.setJustification(Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
        dateText.setJustification(Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
        partOfDayText.setJustification(Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
        secondsText.setJustification(Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
        
        hoursFormat = addLeadingZero ? "%02d" : "%d";
        showSeconds = true;
    }

    function onShow() {
		
    }

    function onUpdate(dc) {
	    var now = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
	    
        var hours = now.hour;
        var minutes = now.min;
        var seconds = now.sec;
        var day = now.day;
        var month = now.month;
        
        var partOfDay = "AM";
        
        if(hours > 12) {
        	partOfDay = "PM";
        }
        View.onUpdate(dc);
        
        dc.drawBitmap(0, 0, mockBackground);
		
		hoursText.setText(hours.format(hoursFormat));
		minutesText.setText(minutes.format("%02d"));
		minutesColon.setText(":");
		dateText.setText(day.format("%02d") + " " + month.toUpper());
		partOfDayText.setText(partOfDay);
		
		hoursText.draw(dc);
		minutesText.draw(dc);
		minutesColon.draw(dc);
		dateText.draw(dc);
		partOfDayText.draw(dc);

		if(showSeconds) {
			secondsText.setText(seconds.format("%02d"));
			secondsText.draw(dc);
		}

		// TODO:
		// Put clock-related function in a separate drawable class
		// implement onHoursUpdate onMinuteUpdate onSettingsChanged
    }

    function onHide() {
    }

    function onExitSleep() {
    	showSeconds = true;

    	secondsText.setColor(Graphics.COLOR_LT_GRAY);
    }

    function onEnterSleep() {
    	showSeconds = false;
    	
    	secondsText.setColor(Graphics.COLOR_TRANSPARENT);
    }
}