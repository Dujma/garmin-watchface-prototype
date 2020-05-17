using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;
using Toybox.Time;
using Toybox.Time.Gregorian;

class prototypewatchfaceView extends WatchUi.WatchFace {
	
	var mockBackground;
	var clockArea;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        
        mockBackground = new WatchUi.Bitmap({
        	:rezId => Rez.Drawables.MockBackground,
        	:locX  => 0,
        	:locY  => 0
    	});
        clockArea = new ClockArea(dc);
        
        drawBackground(dc);
    }

    function onShow() {
		
    }
    var count = 0;
    function onUpdate(dc) {
    	
    	
		
		if(count < 5) {
		clearBuffer(dc);
		clockArea.render(dc, true);
		count++;
		} else {
			clockArea.render(dc, false);
		}
		
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
    
    function drawBackground(dc) {
    	dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
        dc.clear();
    }
    
    function clearBuffer(dc) {
    	var clearBufferBitmap = new WatchUi.Bitmap({
        	:rezId => Rez.Drawables.MockBackground,
        	:locX  => 0,
        	:locY  => 0
    	});
    	clearBufferBitmap.setSize(260, 260);
    	clearBufferBitmap.draw(dc);
    }
}

class ClockArea {
	// Hours
	var hoursText;
	var hoursFormat;
	
	// Minutes
	var minutesText;
	var minutesColon;
	
	// Seconds
	var secondsText;
	
	// Date
	var dateText;
	
	// Part of day
	var partOfDayText;

	// Fonts
	var fontRobotoBlack80;
	var fontRobotoBold55;
	var fontRobotoCondenseBold20;
	var fontRobotoCondenseBold12;
	
	// Other
	var showSeconds;
	
    function initialize(dc) {
		fontRobotoBlack80 = WatchUi.loadResource(Rez.Fonts.RobotoBlack80);
        fontRobotoBold55 = WatchUi.loadResource(Rez.Fonts.RobotoBold55);
        fontRobotoCondenseBold20 = WatchUi.loadResource(Rez.Fonts.RobotoCondenseBold20);
        fontRobotoCondenseBold12 = WatchUi.loadResource(Rez.Fonts.RobotoCondenseBold12);
        
        var cx = dc.getWidth() / 2;
        var cy = dc.getWidth() / 2;
        var addLeadingZero = Application.getApp().getProperty("AddLeadingZero");
        
		hoursText = new WatchUi.Text({
            :color => Graphics.COLOR_WHITE,
            :font  => fontRobotoBlack80,
            :locX  => cx * 0.723 + (dc.getTextWidthInPixels(addLeadingZero ? "00" : "0", fontRobotoBlack80) / 2),
            :locY  => cy
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

    function render(dc, all) {
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
		hoursText.setText(hours.format(hoursFormat));
		minutesText.setText(minutes.format("%02d"));
		minutesColon.setText(":");
		dateText.setText(day.format("%02d") + " " + month.toUpper());
		partOfDayText.setText(partOfDay);
		
		if(all) {
			hoursText.draw(dc);
			minutesText.draw(dc);
			minutesColon.draw(dc);
			dateText.draw(dc);
			partOfDayText.draw(dc);
		} else {
			minutesColon.draw(dc);
		}
		

		if(showSeconds) {
			secondsText.setText(seconds.format("%02d"));
			secondsText.draw(dc);
		}
    }
}