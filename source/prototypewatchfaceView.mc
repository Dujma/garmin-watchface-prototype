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
	private var bottomIcons;
	private var dayOfWeek;
	private var moveBar;

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
    	var fntAsapCondensedBold14 = WatchUi.loadResource(Rez.Fonts.AsapCondensedBold14);
    	
        clockArea = new UiElements.ClockArea(dc, fntAsapCondensedBold14);
        topIcons = new UiElements.TopIcons(dc, fntAsapCondensedBold14);
        bottomIcons = new UiElements.BottomIcons(dc);
        dayOfWeek = new UiElements.DayOfWeek(dc);
        moveBar = new UiElements.MoveBar(dc);
    }

    function onShow() {
		
    }
    
    function onUpdate(dc) {
    	// Background
    	drawBackground(dc);
    	
    	mockBackground.draw(dc);
    	
    	var deviceSettings = System.getDeviceSettings();
    	var systemStats = System.getSystemStats();
		
		// UiElements
		clockArea.draw(deviceSettings);
		topIcons.draw(deviceSettings, systemStats);
		bottomIcons.draw(deviceSettings);
		dayOfWeek.draw();
		moveBar.draw();
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
    	dayOfWeek.onSettingUpdate();
    }
}

module UiElements {
	class UiElementBase {
		protected var dc;
		
		function initialize(dc) {
			self.dc = dc;
		}

		function onSettingUpdate() {
			
	    }
	}
	
	class ClockArea extends UiElementBase {
		private var hoursText;
		private var hoursFormat;
		private var minutesText;
		private var minutesColon;
		private var secondsText;
		private var dateText;
		private var partOfDayText;

	    function initialize(dc, fntAsapCondensedBold14) {
			UiElementBase.initialize(dc);

			var yOffsetFntAsapBold81 = 0.962;
			var yOffsetFntAsapSemibold55 = 0.97;
			var yOffsetFntAsapSmall = 0.99;
			
			var fntAsapBold81 = WatchUi.loadResource(Rez.Fonts.AsapBold81);
	        var fntAsapSemibold55 = WatchUi.loadResource(Rez.Fonts.AsapSemibold55);
	        var fntAsapCondensedSemiBold20 = WatchUi.loadResource(Rez.Fonts.AsapCondensedSemiBold20);

			hoursText = new WatchUi.Text({
	            :color => Graphics.COLOR_WHITE,
	            :font  => fntAsapBold81,
	            :locX  => 89 +(self.dc.getTextWidthInPixels("00", fntAsapBold81) / 2),
	            :locY  => 129
	        });
	        minutesText = new WatchUi.Text({
	            :color => Graphics.COLOR_LT_GRAY,
	            :font  => fntAsapSemibold55,
	            :locX  => 178,
	            :locY  => 119
	        });
	        minutesColon = new WatchUi.Text({
	            :color => Graphics.COLOR_LT_GRAY,
	            :font  => fntAsapSemibold55,
	            :locX  => 139,
	            :locY  => 119
	        });
	        dateText = new WatchUi.Text({
	            :color => Graphics.COLOR_WHITE,
	            :font  => fntAsapCondensedSemiBold20,
	            :locX  => 178,
	            :locY  => 150
	        });
	        partOfDayText = new WatchUi.Text({
	            :color => Graphics.COLOR_WHITE,
	            :font  => fntAsapCondensedBold14,
	            :locX  => 43,
	            :locY  => 152
	        });
	        secondsText = new WatchUi.Text({
	            :color => Graphics.COLOR_LT_GRAY,
	            :font  => fntAsapCondensedBold14,
	            :locX  => 215,
	            :locY  => 106
	        });
	        hoursText.setJustification(Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_RIGHT);
	        minutesText.setJustification(Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
	        minutesColon.setJustification(Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
	        dateText.setJustification(Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
	        partOfDayText.setJustification(Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
	        secondsText.setJustification(Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
	        
	        hoursFormat = Application.getApp().getProperty("AddLeadingZero") ? "%02d" : "%d";
	    }
	
	    function draw(deviceSettings) {
	    	var now = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
	    	var hours = now.hour;

		    partOfDayText.setText(hours > 12 ? "P" : "A");
		    
		    if(!deviceSettings.is24Hour) {
				hours -= hours > 12 ? 12 : 0;
			}
			hoursText.setText(hours.format(hoursFormat));
			minutesText.setText(now.min.format("%02d"));
			minutesColon.setText(":");
			dateText.setText(now.day.format("%02d") + " " + now.month.toUpper());
			
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
	    	UiElementBase.onSettingUpdate();
	    	
	    	hoursFormat = Application.getApp().getProperty("AddLeadingZero") ? "%02d" : "%d";
	    }
	    
	    function onEnterSleep() {
	    	secondsText.setColor(Graphics.COLOR_TRANSPARENT);
	    }
	    
	    function onExitSleep() {
	    	secondsText.setColor(Graphics.COLOR_LT_GRAY);
	    }
	}
	
	class TopIcons extends UiElementBase {
		private var batteryText;
		private var batteryIcon;
		private var notificationIcon;
		private var alarmIcon;

		function initialize(dc, fntAsapCondensedBold14) {
			UiElementBase.initialize(dc);
		
			batteryIcon = new Icons.Icon("Battery-100", dc);
			batteryIcon.setPosition(130, 19);
			
			batteryText = new WatchUi.Text({
	            :color => Graphics.COLOR_WHITE,
	            :font  => fntAsapCondensedBold14,
	            :locX  => 130,
	            :locY  => 8
	        });
	        batteryText.setJustification(Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
			
			notificationIcon = new Icons.Icon("Notification", dc);
			notificationIcon.setPosition(154, 16);
			
			alarmIcon = new Icons.Icon("Alarm", dc);
			alarmIcon.setPosition(104, 15);
		}
		
		function draw(deviceSettings, systemStats) {
			var batteryLvl = Math.round(systemStats.battery + 0.5);

			batteryText.setText(Lang.format("$1$%", [ batteryLvl.format( "%d" ) ]));
			batteryText.draw(dc);
			
			setBatteryIcon(batteryLvl);

			batteryIcon.setColor(batteryLvl <= 20 ? Graphics.COLOR_RED : Graphics.COLOR_WHITE);
			notificationIcon.setColor(deviceSettings.notificationCount > 0 ? Graphics.COLOR_RED : Graphics.COLOR_WHITE);
			alarmIcon.setColor(deviceSettings.alarmCount > 0 ? Graphics.COLOR_RED : Graphics.COLOR_WHITE);

			batteryIcon.draw();
			notificationIcon.draw();
			alarmIcon.draw();
		}
		
		function setBatteryIcon(lvl) {
			var targetIcon = null;
			
			// TODO: Think about how this can be prettier
			if(lvl > 90) {
				targetIcon = "Battery-100";
			} else if(lvl > 80 && lvl <= 90) {
				targetIcon = "Battery-90";
			} else if(lvl > 70 && lvl <= 80) {
				targetIcon = "Battery-80";
			} else if(lvl > 60 && lvl <= 70) {
				targetIcon = "Battery-70";
			} else if(lvl > 50 && lvl <= 60) {
				targetIcon = "Battery-60";
			} else if(lvl > 40 && lvl <= 50) {
				targetIcon = "Battery-50";
			} else if(lvl > 30 && lvl <= 40) {
				targetIcon = "Battery-40";
			} else if(lvl > 20 && lvl <= 30) {
				targetIcon = "Battery-30";
			} else if(lvl > 10 && lvl <= 20) {
				targetIcon = "Battery-20";
			} else if(lvl > 5 && lvl <= 10) {
				targetIcon = "Battery-10";
			} else if(lvl > 1 && lvl <= 5) {
				targetIcon = "Battery-5";
			} else {
				targetIcon = "Battery-0";
			}
			if(batteryIcon.name != targetIcon) {
				batteryIcon.setIcon(targetIcon);
			}
		}
	}
	
	class BottomIcons extends UiElementBase {
		private var moveIcon;
		private var dndIcon;
		private var btIcon;

		function initialize(dc) {
			UiElementBase.initialize(dc);
			
			moveIcon = new Icons.Icon("Move-1", dc);
			moveIcon.setPosition(104, 243);
			
			dndIcon = new Icons.Icon("Dnd", dc);
			dndIcon.setPosition(130, 247);
			
			btIcon = new Icons.Icon("Bluetooth", dc);
			btIcon.setPosition(155, 244);
		}
		
		function draw(deviceSettings) {
			var moveBarLevel = ActivityMonitor.getInfo().moveBarLevel;

			dndIcon.setColor(deviceSettings.doNotDisturb ? Graphics.COLOR_RED : Graphics.COLOR_WHITE);
			btIcon.setColor(deviceSettings.phoneConnected ? Graphics.COLOR_RED : Graphics.COLOR_WHITE);
			setMoveIcon(moveBarLevel);
			
			moveIcon.draw();
			dndIcon.draw();
			btIcon.draw();
		}
		
		function setMoveIcon(lvl) {
			var targetIcon = null;
			
			if(lvl == 0) {
				targetIcon = "Move-1";
			} else {
				targetIcon = "Move-5";
			}
			moveIcon.setIcon(targetIcon);
			
			if(lvl >= 3) {
				moveIcon.setColor(Graphics.COLOR_RED);
			} else {
				moveIcon.setColor(Graphics.COLOR_WHITE);
			}
		}
	}
	
	// TODO: Missing implementation onSettingChange and also when the first day of week is changed from device settings
	class DayOfWeek extends UiElementBase {
		private var days;
		private var fntAsapBold12;
		private var arrowIcon;
		private var initialY = 87;
		private var yOffset = 3;
		private var dayNames = [ "SU", "MO", "TU", "WE", "TH", "FR", "SA" ];

		function initialize(dc) {
			UiElementBase.initialize(dc);

			fntAsapBold12 = WatchUi.loadResource(Rez.Fonts.AsapBold12);

			arrowIcon = new Icons.Icon("Arrow-Up", dc);
			arrowIcon.setColor(Graphics.COLOR_RED);
			arrowIcon.setPosition(56, 93);

			days = new [7];

			for(var i = 0; i < days.size(); ++i) {
				days[i] = new WatchUi.Text({
					:text  => dayNames[i],
		            :color => Graphics.COLOR_WHITE,
		            :font  => fntAsapBold12,
		            :locY  => initialY
	        	});
	        	days[i].setJustification(Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
			}
			orderDaysOfWeek(System.getDeviceSettings().firstDayOfWeek);
		}
		
		function draw() {
			var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
			var dayOfWeek = now.day_of_week;

			for(var i = 0; i < days.size(); ++i) {
				if(i == dayOfWeek - 1) {
					days[i].setColor(Graphics.COLOR_RED);
					
					days[i].locY = initialY - yOffset;
					
					arrowIcon.setPosition(days[i].locX, arrowIcon.text.locY);
				} else {
					if(dayNames[i].equals("SA") || dayNames[i].equals("SU")) {
						days[i].setColor(Graphics.COLOR_LT_GRAY);
					} else {
						days[i].setColor(Graphics.COLOR_WHITE);
					}
					days[i].locY = initialY;
				}
				days[i].draw(dc);
				arrowIcon.draw();
			}
		}
		
		function getXLocationsBasedOnFirstDayOfWeek(firstDayOfWeek) {
			var xLocations = [ 56, 83, 109, 135, 159, 182, 206 ];

			if(firstDayOfWeek == Gregorian.DAY_MONDAY) {
				xLocations = [ 206, 56, 83, 109, 135, 159, 182 ];
			} else if(firstDayOfWeek == Gregorian.DAY_SATURDAY) {
				xLocations = [ 83, 109, 135, 159, 182, 206, 56 ];
			}
			return xLocations;
		}
		
		function orderDaysOfWeek(firstDayOfWeek) {
			var xLocations = getXLocationsBasedOnFirstDayOfWeek(firstDayOfWeek);
			
			for(var i = 0; i < days.size(); ++i) {
				days[i].locX = xLocations[i];
			}
		}
		
		function onSettingUpdate() {
	    	UiElementBase.onSettingUpdate();
	    	
	    	orderDaysOfWeek(System.getDeviceSettings().firstDayOfWeek);
	    }
	}
	
	class MoveBar extends UiElementBase {
		var lvl1;
		var lvls;
		
		function initialize(dc) {
			UiElementBase.initialize(dc);
			
    		lvl1 = new Icons.Icon("MoveBar-1", dc);
    		lvl1.setPosition(101, 219);
    		
    		lvls = new [4];
    		
    		for(var i = 0; i < lvls.size(); ++i) {
    			lvls[i] = new Icons.Icon("MoveBar-2", dc);
    			lvls[i].setPosition(120 + (i * 14), 219);
    		}
		}
		
		function draw() {
			var moveBarLevel = ActivityMonitor.getInfo().moveBarLevel;

			if(moveBarLevel > 0) {
				lvl1.setColor(Graphics.COLOR_RED);
				lvl1.draw();
				
				for(var i = 0; i < moveBarLevel - 1; ++i) {
					lvls[i].setColor(Graphics.COLOR_RED);
					lvls[i].draw();
				}
				for(var i = moveBarLevel - 1; i < lvls.size(); ++i) {
					lvls[i].setColor(Graphics.COLOR_DK_GRAY);
					lvls[i].draw();
				}
			} else {
				lvl1.setColor(Graphics.COLOR_DK_GRAY);
				lvl1.draw();
				
				for(var i = 0; i < lvls.size(); ++i) {
					lvls[i].setColor(Graphics.COLOR_DK_GRAY);
					lvls[i].draw();
				}
			}
		}
	}
}

module Icons {
	var iconsFont;
	var icons = {
		"Battery-100"  => "B",
		"Battery-90"   => "A",
		"Battery-80"   => "9",
		"Battery-70"   => "8",
		"Battery-60"   => "7",
		"Battery-50"   => "6",
		"Battery-40"   => "5",
		"Battery-30"   => "4",
		"Battery-20"   => "3",
		"Battery-10"   => "2",
		"Battery-5"    => "1",
		"Battery-0"    => "0",
		"Notification" => "C",
		"Alarm"        => "D",
		"Move-1"       => "E",
		"Move-5"       => "F",
		"Dnd"          => "G",
		"Bluetooth"    => "H",
		"Arrow-Up"     => "I",
		"MoveBar-1"    => "J",
		"MoveBar-2"    => "K"
	};
	
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
        	text.setJustification(Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
		}
		
		function setColor(color) {
			text.setColor(color);
			
			return text;
		}
		
		function setIcon(name) {
			self.name = name;
			char = Icons.icons[name];
			
			text.setText(char);
			dimensions = dc.getTextDimensions(char, iconsFont);
			
			return text;
		}

		function setPosition(x, y) {
			text.locX = x;
			text.locY = y;
			
			return text;
		}
		
		function draw() {
			text.draw(dc);
		}
	}
}