using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;
using Toybox.Time;
using Toybox.Time.Gregorian;

var isSleep = false;

class prototypewatchfaceView extends WatchUi.WatchFace {
	private var mockBackground;
	private var clockArea;
	private var topIcons;

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
    	var fntAsapCondensedSemiBold14 = WatchUi.loadResource(Rez.Fonts.AsapCondensedSemiBold14);
    	
        clockArea = new UiElements.ClockArea(dc, fntAsapCondensedSemiBold14);
        topIcons = new UiElements.TopIcons(dc, fntAsapCondensedSemiBold14);
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

	    function initialize(dc, fntAsapCondensedSemiBold14) {
			self.dc = dc;
			var yOffsetFntAsapBold81 = 0.962;
			var yOffsetFntAsapSemibold55 = 0.97;
			var yOffsetFntAsapSmall = 0.99;
			
			var fntAsapSemiBold81 = WatchUi.loadResource(Rez.Fonts.AsapSemiBold81);
	        var fntAsapSemibold55 = WatchUi.loadResource(Rez.Fonts.AsapSemibold55);
	        var fntAsapCondensedSemiBold20 = WatchUi.loadResource(Rez.Fonts.AsapCondensedSemiBold20);

	        var addLeadingZero = Application.getApp().getProperty("AddLeadingZero");

			hoursText = new WatchUi.Text({
	            :color => Graphics.COLOR_WHITE,
	            :font  => fntAsapSemiBold81,
	            :locX  => 91 +(self.dc.getTextWidthInPixels("00", fntAsapSemiBold81) / 2),
	            :locY  => 129
	        });
	        minutesText = new WatchUi.Text({
	            :color => Graphics.COLOR_LT_GRAY,
	            :font  => fntAsapSemibold55,
	            :locX  => 180,
	            :locY  => 119
	        });
	        minutesColon = new WatchUi.Text({
	            :color => Graphics.COLOR_LT_GRAY,
	            :font  => fntAsapSemibold55,
	            :locX  => 142,
	            :locY  => 119
	        });
	        dateText = new WatchUi.Text({
	            :color => Graphics.COLOR_WHITE,
	            :font  => fntAsapCondensedSemiBold20,
	            :locX  => 180,
	            :locY  => 150
	        });
	        partOfDayText = new WatchUi.Text({
	            :color => Graphics.COLOR_WHITE,
	            :font  => fntAsapCondensedSemiBold14,
	            :locX  => 43,
	            :locY  => 152
	        });
	        secondsText = new WatchUi.Text({
	            :color => Graphics.COLOR_LT_GRAY,
	            :font  => fntAsapCondensedSemiBold14,
	            :locX  => 215,
	            :locY  => 106
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
		    
			hoursText.setText(hours.format(hoursFormat));
			minutesText.setText(now.min.format("%02d"));
			minutesColon.setText(":");
			dateText.setText(now.day.format("%02d") + " " + now.month.toUpper());
			partOfDayText.setText(hours > 12 ? "P" : "A");

			hoursText.draw(dc);
			minutesText.draw(dc);
			minutesColon.draw(dc);
			dateText.draw(dc);
			partOfDayText.draw(dc);

			if(!$.isSleep) {
				secondsText.setText(now.sec.format("%02d"));
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
		private var alarmIcon;
		
		private var dc;

		function initialize(dc, fntAsapCondensedSemiBold14) {
			self.dc = dc;
			
			var cx = dc.getWidth() / 2;
	        var cy = dc.getWidth() / 2;
			
			currentBatteryIcon = new Icons.Icon("Battery100", dc);
			currentBatteryIcon.setPosition(130, 19);
			
			batteryText = new WatchUi.Text({
	            :color => Graphics.COLOR_WHITE,
	            :font  => fntAsapCondensedSemiBold14,
	            :locX  => 130,
	            :locY  => 8
	        });
	        batteryText.setJustification(Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
			
			notificationIcon = new Icons.Icon("Notification", dc);
			notificationIcon.setPosition(154, 16);
			
			alarmIcon = new Icons.Icon("Alarm", dc);
			alarmIcon.setPosition(104, 15);
		}
		
		function draw() {
			var batteryLvl = Math.round(System.getSystemStats().battery);

			batteryText.setText(Lang.format("$1$%", [ (batteryLvl + 0.5).format( "%d" ) ]));
			batteryText.draw(dc);
			
			setBatteryIcon(batteryLvl);
			
			var deviceSettings = System.getDeviceSettings();
			
			currentBatteryIcon.setColor(batteryLvl <= 20 ? Graphics.COLOR_RED : Graphics.COLOR_WHITE);
			notificationIcon.setColor(deviceSettings.notificationCount > 0 ? Graphics.COLOR_RED : Graphics.COLOR_WHITE);
			alarmIcon.setColor(deviceSettings.alarmCount > 0 ? Graphics.COLOR_RED : Graphics.COLOR_WHITE);

			currentBatteryIcon.draw();
			notificationIcon.draw();
			alarmIcon.draw();
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
        	
        	text.setJustification(Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
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
				case "Alarm":
					text.setText("D");
					char = "D";
					break;
				default:
					break;
			}
			dimensions = self.dc.getTextDimensions(name, iconsFont);
			
			return text;
		}

		function setPosition(x, y) {
			text.locX = x;
			text.locY = y;
			
			return text;
		}
		
		function draw() {
			text.draw(self.dc);
		}
	}
}