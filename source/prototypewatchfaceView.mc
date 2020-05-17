using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;
using Toybox.Time;
using Toybox.Time.Gregorian;

var isSleep = false;

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
        clockArea = new UiElements.ClockArea(dc);
    }

    function onShow() {
		
    }
    
    function onUpdate(dc) {
    	drawBackground(dc);
    	
    	mockBackground.draw(dc);

		clockArea.draw();
    }

    function onHide() {
    
    }

    function onExitSleep() {
    	$.isSleep = false;

    	secondsText.setColor(Graphics.COLOR_LT_GRAY);
    }

    function onEnterSleep() {
    	$.isSleep = true;
    	
    	clockArea.onEnterSleep();
    }
    
    function drawBackground(dc) {
    	dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
        dc.clear();
    }
    
    function handleSettingUpdate() {
    	clockArea.onSettingUpdate();
    }
}

module UiElements {
	class ClockArea {
		// Device Context
		var dc;
		
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
		var fontRobotoBlack80 = WatchUi.loadResource(Rez.Fonts.RobotoBlack80);
		
	    function initialize(dc) {
			self.dc = dc;

	        var fontRobotoBold55 = WatchUi.loadResource(Rez.Fonts.RobotoBold55);
	        var fontRobotoCondenseBold20 = WatchUi.loadResource(Rez.Fonts.RobotoCondenseBold20);
	        var fontRobotoCondenseBold12 = WatchUi.loadResource(Rez.Fonts.RobotoCondenseBold12);
	        
	        var cx = dc.getWidth() / 2;
	        var cy = dc.getWidth() / 2;
	        var addLeadingZero = Application.getApp().getProperty("AddLeadingZero");

			hoursText = new WatchUi.Text({
	            :color => Graphics.COLOR_WHITE,
	            :font  => fontRobotoBlack80
	        });
	        
	        setHoursPosition();
	        
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
	    }
	
	    function draw() {
	    	var now = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
		    
	        var hours = now.hour;
	        var minutes = now.min;
	        var seconds = now.sec;
	        
	        var day = now.day;
	        var month = now.month;
	        
	        var partOfDay = hours > 12 ? "PM" : "AM";
	        
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

			if(!$.isSleep) {
				secondsText.setText(seconds.format("%02d"));
				secondsText.draw(dc);
			}
	    }
	    
	    function setHoursPosition() {
	    	var addLeadingZero = Application.getApp().getProperty("AddLeadingZero");
	    	var cx = self.dc.getWidth() / 2;
	    	var cy = self.dc.getHeight() / 2;
	    	var hours = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM).hour;
	    	
	    	hoursFormat = addLeadingZero ? "%02d" : "%d";
	    	
	    	if(hours < 10) {
	    		hoursText.setLocation(cx * 0.723 + (self.dc.getTextWidthInPixels(addLeadingZero  ? "00" : "0", fontRobotoBlack80) / 2), cy);
	    	} else {
	    		hoursText.setLocation(cx * 0.723 + (self.dc.getTextWidthInPixels("00", fontRobotoBlack80) / 2), cy);
	    	}
	    }
	    
	    function onSettingUpdate() {
	    	setHoursPosition();
	    }
	    
	    function onEnterSleep() {
	    	secondsText.setColor(Graphics.COLOR_TRANSPARENT);
	    }
	}
}