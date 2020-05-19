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
		private var dc;
		private var hoursText;
		private var hoursFormat;
		private var minutesText;
		private var minutesColon;
		private var secondsText;
		private var dateText;
		private var partOfDayText;

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
		private var batteryText;
		private var currentBatteryIcon;
		private var batteryLvl;
		private var notificationIcon;
		
		private var dc;

		function initialize(dc) {
			self.dc = dc;
			
			var batteryLvl = Math.round(System.getSystemStats().battery);
			var fntAsapBold13 = WatchUi.loadResource(Rez.Fonts.AsapBold13);
			
			var cx = dc.getWidth() / 2;
	        var cy = dc.getWidth() / 2;
			
			currentBatteryIcon = new Icons.Icon("Battery100", dc);
			currentBatteryIcon.setPosition(cx, Math.round(cy * 0.125));
			
			notificationIcon = new Icons.Icon("Notification", dc);
			notificationIcon.setPosition(Math.round(cx * 1.176), Math.round(cy * 0.105));
			
			batteryText = new WatchUi.Text({
	            :color => Graphics.COLOR_WHITE,
	            :font  => fntAsapBold13,
	            :locX  => cx,
	            :locY  => Math.round(cy * 0.030)
	        });
	        batteryText.setJustification(Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
		}
		
		function draw() {
			var batteryLvl = Math.round(System.getSystemStats().battery);
			
			setBatteryIcon(batteryLvl);
			batteryText.setText(Lang.format("$1$%", [ (batteryLvl + 0.5).format( "%d" ) ]));
			
			batteryText.draw(dc);
			
			if(batteryLvl <= 20) {
				currentBatteryIcon.setColor(Graphics.COLOR_RED);
			} else {
				currentBatteryIcon.setColor(Graphics.COLOR_WHITE);
			}
			if(System.getDeviceSettings().notificationCount > 0) {
				notificationIcon.setColor(Graphics.COLOR_RED);
			} else {
				notificationIcon.setColor(Graphics.COLOR_WHITE);
			}
			System.println(System.getDeviceSettings().notificationCount);
			currentBatteryIcon.draw();
			notificationIcon.draw();
		}
		
		function setBatteryIcon(lvl) {
			var targetIcon = null;
			
			if(lvl > 90) {
				targetIcon = "Battery100";
			} else if(lvl > 80 && lvl <= 90) {
				targetIcon = "Battery90";
			} else if(lvl > 70 && lvl <= 80) {
				targetIcon = "Battery80";
			} else if(lvl > 60 && lvl <= 70) {
				targetIcon = "Battery70";
			} else if(lvl > 50 && lvl <= 60) {
				targetIcon = "Battery60";
			} else if(lvl > 40 && lvl <= 50) {
				targetIcon = "Battery50";
			} else if(lvl > 30 && lvl <= 40) {
				targetIcon = "Battery40";
			} else if(lvl > 20 && lvl <= 30) {
				targetIcon = "Battery30";
			} else if(lvl > 10 && lvl <= 20) {
				targetIcon = "Battery20";
			} else if(lvl > 5 && lvl <= 10) {
				targetIcon = "Battery10";
			} else if(lvl > 1 && lvl <= 5) {
				targetIcon = "Battery5";
			} else {
				targetIcon = "Battery0";
			}
			if(currentBatteryIcon.name != targetIcon) {
				currentBatteryIcon.setIcon(targetIcon);
			}
		}
	}
	
}

module Icons {
	var iconsFont;
	
	function init() {
		iconsFont = WatchUi.loadResource(Rez.Fonts.Icons);
	}

	class Icon {
		var text;
		var name;
		var dimensions;
		
		private var dc;
		private var char;

		function initialize(name, dc) {
			text = new WatchUi.Text({
	            :color => Graphics.COLOR_WHITE,
	            :font  => iconsFont,
	            :locX  => 0,
	            :locY  => 0
        	});
        	self.dc = dc;
        	
        	setIcon(name);

        	dimensions = self.dc.getTextDimensions(char, iconsFont);
		}
		
		function setColor(color) {
			self.text.setColor(color);
			
			return text;
		}
		
		function setIcon(name) {
			self.name = name;
			
			switch(name) {
				case "Battery100":
					text.setText("B");
					char = "B";
					break;
				case "Battery90":
					text.setText("A");
					char = "A";
					break;
				case "Battery80":
					text.setText("9");
					char = "9";
					break;
				case "Battery70":
					text.setText("8");
					char = "8";
					break;
				case "Battery60":
					text.setText("7");
					char = "7";
					break;
				case "Battery50":
					text.setText("6");
					char = "6";
					break;
				case "Battery40":
					text.setText("5");
					char = "5";
					break;
				case "Battery30":
					text.setText("4");
					char = "4";
					break;
				case "Battery20":
					text.setText("3");
					char = "3";
					break;
				case "Battery10":
					text.setText("2");
					char = "2";
					break;
				case "Battery5":
					text.setText("1");
					char = "1";
					break;
				case "Battery0":
					text.setText("0");
					char = "0";
					break;
				case "Notification":
					text.setText("C");
					char = "C";
					break;
				default:
					break;
			}
			dimensions = self.dc.getTextDimensions(name, iconsFont);
			
			return text;
		}

		function setPosition(x, y) {
			x -= dimensions[0] / 2;
			y -= dimensions[1] / 2;
			
			text.locX = x;
			text.locY = y;
			
			return text;
		}
		
		function draw() {
			text.draw(self.dc);
		}
	}
}