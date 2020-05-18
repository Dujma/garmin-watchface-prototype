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
	
	// Elements
	var clockArea;
	var topIcons;

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
        topIcons = new UiElements.TopIcons(dc);
    }

    function onShow() {
		
    }
    
    function onUpdate(dc) {
    	drawBackground(dc);
    	
    	mockBackground.draw(dc);

		clockArea.draw();
		topIcons.draw();
    }

    function onHide() {
    
    }

    function onExitSleep() {
    	$.isSleep = false;

    	clockArea.onExitSleep();
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

	    function initialize(dc) {
			self.dc = dc;
			var yOffsetFntAsapBold81 = 0.962;
			var yOffsetFntAsapSemibold55 = 0.97;
			var yOffsetFntAsapSmall = 0.99;
			
			var fntAsapBold81 = WatchUi.loadResource(Rez.Fonts.AsapBold81);
	        var fntAsapSemibold55 = WatchUi.loadResource(Rez.Fonts.AsapSemibold55);
	        var fntAsapCondensedBold20 = WatchUi.loadResource(Rez.Fonts.AsapCondensedBold20);
	        var fntAsapBold14 = WatchUi.loadResource(Rez.Fonts.AsapBold14);
	        
	        var cx = dc.getWidth() / 2;
	        var cy = dc.getWidth() / 2;
	        var addLeadingZero = Application.getApp().getProperty("AddLeadingZero");

			hoursText = new WatchUi.Text({
	            :color => Graphics.COLOR_WHITE,
	            :font  => fntAsapBold81,
	            :locX  => cx * 0.723 + (self.dc.getTextWidthInPixels("00", fntAsapBold81) / 2),
	            :locY  => cy * yOffsetFntAsapBold81
	        });

	        minutesText = new WatchUi.Text({
	            :color => Graphics.COLOR_LT_GRAY,
	            :font  => fntAsapSemibold55,
	            :locX  => cx * 1.423,
	            :locY  => cy * 0.930 * yOffsetFntAsapSemibold55
	        });
	        minutesColon = new WatchUi.Text({
	            :color => Graphics.COLOR_LT_GRAY,
	            :font  => fntAsapSemibold55,
	            :locX  => cx * 1.123,
	            :locY  => cy * 0.930 * yOffsetFntAsapSemibold55
	        });
	        dateText = new WatchUi.Text({
	            :color => Graphics.COLOR_WHITE,
	            :font  => fntAsapCondensedBold20,
	            :locX  => cx * 1.423,
	            :locY  => cy * 1.161 * yOffsetFntAsapSmall
	        });
	        partOfDayText = new WatchUi.Text({
	            :color => Graphics.COLOR_WHITE,
	            :font  => fntAsapBold14,
	            :locX  => cx * 0.315,
	            :locY  => cy * 1.176
	        });
	        secondsText = new WatchUi.Text({
	            :color => Graphics.COLOR_LT_GRAY,
	            :font  => fntAsapBold14,
	            :locX  => cx * 1.707,
	            :locY  => cy * 0.823 * yOffsetFntAsapSmall
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

	    function onSettingUpdate() {
	    	var addLeadingZero = Application.getApp().getProperty("AddLeadingZero");
	    	
	    	hoursFormat = addLeadingZero ? "%02d" : "%d";
	    }
	    
	    function onEnterSleep() {
	    	secondsText.setColor(Graphics.COLOR_TRANSPARENT);
	    }
	    
	    function onExitSleep() {
	    	secondsText.setColor(Graphics.COLOR_LT_GRAY);
	    }
	}
	
	class TopIcons {
		var dc;
		var batteryText;
		
		function initialize(dc) {
			self.dc = dc;
		}
		
		function draw() {
			var batteryLevel = Math.round(System.getSystemStats().battery);

			updateIcon(batteryLevel);
		}
		
		function updateIcon(batteryLevel) {
			switch(batteryLevel) {
				case batteryLevel >= 75:
					break;
				case batteryLevel >= 50 && batteryLevel < 75:
					break;
				case batteryLevel >= 25 && batteryLevel < 50:
					break;
				case batteryLevel >= 0 && batteryLevel < 25:
					break;
				default:
					break;
			}
		}
	}
}