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
        
        Icons.init();
        
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
	            :locX  => Math.round(cx * 0.723 + (self.dc.getTextWidthInPixels("00", fntAsapBold81) / 2)),
	            :locY  => Math.round(cy * yOffsetFntAsapBold81)
	        });

	        minutesText = new WatchUi.Text({
	            :color => Graphics.COLOR_LT_GRAY,
	            :font  => fntAsapSemibold55,
	            :locX  => Math.round(cx * 1.423),
	            :locY  => Math.round(cy * 0.930 * yOffsetFntAsapSemibold55)
	        });
	        minutesColon = new WatchUi.Text({
	            :color => Graphics.COLOR_LT_GRAY,
	            :font  => fntAsapSemibold55,
	            :locX  => Math.round(cx * 1.123),
	            :locY  => Math.round(cy * 0.930 * yOffsetFntAsapSemibold55)
	        });
	        dateText = new WatchUi.Text({
	            :color => Graphics.COLOR_WHITE,
	            :font  => fntAsapCondensedBold20,
	            :locX  => Math.round(cx * 1.423),
	            :locY  => Math.round(cy * 1.161 * yOffsetFntAsapSmall)
	        });
	        partOfDayText = new WatchUi.Text({
	            :color => Graphics.COLOR_WHITE,
	            :font  => fntAsapBold14,
	            :locX  => Math.round(cx * 0.315),
	            :locY  => Math.round( cy * 1.176)
	        });
	        secondsText = new WatchUi.Text({
	            :color => Graphics.COLOR_LT_GRAY,
	            :font  => fntAsapBold14,
	            :locX  => Math.round(cx * 1.707),
	            :locY  => Math.round(cy * 0.823 * yOffsetFntAsapSmall)
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
		var currentBatteryIcon;
		var batteryLvl;

		function initialize(dc) {
			self.dc = dc;
			
			var batteryLvl = Math.round(System.getSystemStats().battery);
			var fntAsapBold13 = WatchUi.loadResource(Rez.Fonts.AsapBold13);
			
			var cx = dc.getWidth() / 2;
	        var cy = dc.getWidth() / 2;
			
			currentBatteryIcon = new WatchUi.Bitmap({
	        	:rezId => Rez.Drawables.Lvl100
    		});
    		
    		batteryText = new WatchUi.Text({
	            :color => Graphics.COLOR_WHITE,
	            :font  => fntAsapBold13,
	            :locX  => cx,
	            :locY  => Math.round(cy * 0.030)
	        });
	        batteryText.setJustification(Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
    		
    		Utils.Helpers.positionBitmap(currentBatteryIcon, cx, Math.round(cy * 0.13));
		}
		
		function draw() {
			var batteryLvl = Math.round(System.getSystemStats().battery);
			
			getBatteryIconByBatteryLvl(batteryLvl);
			batteryText.setText(Lang.format("$1$%", [ (batteryLvl + 0.5).format( "%d" ) ]));
			
			batteryText.draw(dc);
			currentBatteryIcon.draw(dc);
		}
		
		function getBatteryIconByBatteryLvl(lvl) {
			var targetBitmap = null;
			
			if(lvl > 90) {
				targetBitmap = Rez.Drawables.Lvl100;
			} else if(lvl > 80 && lvl <= 90) {
				targetBitmap = Rez.Drawables.Lvl90;
			} else if(lvl > 70 && lvl <= 80) {
				targetBitmap = Rez.Drawables.Lvl80;
			} else if(lvl > 60 && lvl <= 70) {
				targetBitmap = Rez.Drawables.Lvl70;
			} else if(lvl > 50 && lvl <= 60) {
				targetBitmap = Rez.Drawables.Lvl60;
			} else if(lvl > 40 && lvl <= 50) {
				targetBitmap = Rez.Drawables.Lvl50;
			} else if(lvl > 30 && lvl <= 40) {
				targetBitmap = Rez.Drawables.Lvl40;
			} else if(lvl > 20 && lvl <= 30) {
				targetBitmap = Rez.Drawables.Lvl30;
			} else if(lvl > 10 && lvl <= 20) {
				targetBitmap = Rez.Drawables.Lvl20;
			} else if(lvl > 5 && lvl <= 10) {
				targetBitmap = Rez.Drawables.Lvl10;
			} else if(lvl > 1 && lvl <= 5) {
				targetBitmap = Rez.Drawables.Lvl5;
			} else {
				targetBitmap = Rez.Drawables.Lvl0;
			}
			currentBatteryIcon.setBitmap(targetBitmap);
		}
	}
	
}

module Icons {
	var iconsFont;
	
	function init() {
		iconsFont = WatchUi.loadResource(Rez.Fonts.Icons);
	}
	
	function getIconByName(name) {
		var result = new WatchUi.Text({
            :color => Graphics.COLOR_WHITE,
            :font  => iconsFont,
            :locX  => 130,
            :locY  => 130
        });
        
        result.setJustification(Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
	
		switch(name) {
			case "Battery100":
				result.setText("B");
				break;
			default:
				break;
		}
		return result;
	}
	
	class Icon {
		
	}
}

module Utils {
	class Helpers {
		function positionBitmap(bitmap, x, y) {
			x -= bitmap.width / 2;
			y -= bitmap.height / 2;
			
			bitmap.locX = x;
			bitmap.locY = y;
			
			return bitmap;
		}
	}
}