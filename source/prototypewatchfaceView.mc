using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Math;
using Toybox.ActivityMonitor;
using Toybox.Activity;

class prototypewatchfaceView extends WatchUi.WatchFace {
	private var application;
	private var mockBackground;
	
	// UiElements
	private var clockArea;
	private var topIcons;
	private var bottomIcons;
	private var top;
	private var bottom;
	private var right;
	private var left;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        application = Application.getApp();
        
        Icons.init();
        
        mockBackground = new WatchUi.Bitmap({
        	:rezId => Rez.Drawables.MockBackground,
        	:locX  => 0,
        	:locY  => 0
    	});
    	var fntAsapCondensedBold14 = WatchUi.loadResource(Rez.Fonts.AsapCondensedBold14);
    	var fntAsapBold12 = WatchUi.loadResource(Rez.Fonts.AsapBold12);
    	
        clockArea = new UiElements.ClockArea(dc, fntAsapCondensedBold14, application);
        topIcons = new UiElements.TopIcons(dc, fntAsapCondensedBold14);
        bottomIcons = new UiElements.BottomIcons(dc);
        top = new UiElements.Top(dc, application, fntAsapBold12);
        bottom = new UiElements.Bottom(dc);
        right = new UiElements.Right(dc, fntAsapCondensedBold14);
        left = new UiElements.Left(dc, fntAsapCondensedBold14, fntAsapBold12);
    }

    function onShow() {

    }
    
    function onUpdate(dc) {
    	// Background
    	drawBackground(dc);
    	
    	mockBackground.draw(dc);
    	
    	var deviceSettings = System.getDeviceSettings();
    	var systemStats = System.getSystemStats();
   	 	var userProfile = UserProfile.getProfile();
		
		// UiElements
		clockArea.draw(deviceSettings);
		topIcons.draw(deviceSettings, systemStats);
		bottomIcons.draw(deviceSettings, userProfile);
		top.draw();
		bottom.draw();
		right.draw();
		left.draw(userProfile);
    }

    function onHide() {
    
    }

    function onExitSleep() {
    	clockArea.onExitSleep();
    	left.onExitSleep();
    }

    function onEnterSleep() {
    	clockArea.onEnterSleep();
    	left.onEnterSleep();
    }
    
    function drawBackground(dc) {
    	dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
    }
    
    function handleSettingUpdate() {
    	clockArea.onSettingUpdate();
    	top.onSettingUpdate();
    }
}

module UiElements {
	class UiElementBase {
		protected var dc;
		
		function initialize(dc) {
			self.dc = dc;
		}
	}
	
	class ClockArea extends UiElementBase {
		var isSleep;
	
		private var hoursText;
		private var hoursFormat;
		private var minutesText;
		private var minutesColon;
		private var secondsText;
		private var dateText;
		private var partOfDayText;
		private var application;

	    function initialize(dc, fntAsapCondensedBold14, application) {
			UiElementBase.initialize(dc);
			self.application = application;
			
			isSleep = false;

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
	        
	        hoursFormat = application.getProperty("AddLeadingZero") ? "%02d" : "%d";
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

			if(!isSleep) {
				secondsText.setText(now.sec.format("%02d"));
				secondsText.draw(dc);
			}
	    }

	    function onSettingUpdate() {
	    	hoursFormat = application.getProperty("AddLeadingZero") ? "%02d" : "%d";
	    }
	    
	    function onEnterSleep() {
	        isSleep = true;
	        
	    	secondsText.setColor(Graphics.COLOR_TRANSPARENT);
	    }
	    
	    function onExitSleep() {
	    	isSleep = false;
	    	
	    	secondsText.setColor(Graphics.COLOR_LT_GRAY);
	    }
	}
	
	class TopIcons extends UiElementBase {
		private var batteryIcons = { 
			"Battery-100" => { "max" => 100, "min" => 90 },
			"Battery-90"  => { "max" => 90,  "min" => 80 },
			"Battery-80"  => { "max" => 80,  "min" => 70 },
			"Battery-70"  => { "max" => 70,  "min" => 60 },
			"Battery-60"  => { "max" => 60,  "min" => 50 },
			"Battery-50"  => { "max" => 50,  "min" => 40 },
			"Battery-40"  => { "max" => 40,  "min" => 30 },
			"Battery-30"  => { "max" => 30,  "min" => 20 },
			"Battery-20"  => { "max" => 20,  "min" => 10 },
			"Battery-10"  => { "max" => 10,  "min" => 5  },
			"Battery-5"   => { "max" => 5,   "min" => 1  },
			"Battery-0"   => { "max" => 1,   "min" => -1 }
		};
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
			var batteryLvl = Math.round(systemStats.battery);

			batteryText.setText(Lang.format("$1$%", [ (batteryLvl + 0.5).format( "%d" ) ]));
			batteryText.draw(dc);
			
			setBatteryIcon(batteryLvl);
			
			if(!systemStats.charging) { // 3.0.0
				batteryIcon.setColor(batteryLvl <= 20 ? Graphics.COLOR_RED : Graphics.COLOR_WHITE);
			} else {
				if(batteryLvl < 99.5) {
					batteryIcon.setColor(Graphics.COLOR_BLUE);
				} else {
					batteryIcon.setColor(Graphics.COLOR_GREEN);
				}
			}
			notificationIcon.setColor(deviceSettings.notificationCount > 0 ? Graphics.COLOR_RED : Graphics.COLOR_WHITE);
			alarmIcon.setColor(deviceSettings.alarmCount > 0 ? Graphics.COLOR_RED : Graphics.COLOR_WHITE);

			batteryIcon.draw();
			notificationIcon.draw();
			alarmIcon.draw();
		}
		
		function setBatteryIcon(lvl) {
			var targetIcon = null;
			var batteryIconsValues = batteryIcons.values();
			
			for(var i = 0; i < batteryIcons.size(); ++i) {
				if(lvl > batteryIconsValues[i]["min"] && lvl <= batteryIconsValues[i]["max"]) {
					targetIcon = batteryIcons.keys()[i];
					break;
				}
			}
			if(targetIcon != null) {
				if(batteryIcon.name != targetIcon) {
					batteryIcon.setIcon(targetIcon);
				}
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
		
		function draw(deviceSettings, userProfile) {
			var moveBarLevel = ActivityMonitor.getInfo().moveBarLevel;

			dndIcon.setColor(deviceSettings.doNotDisturb ? Graphics.COLOR_RED : Graphics.COLOR_WHITE); // 2.1.0
			btIcon.setColor(deviceSettings.phoneConnected ? Graphics.COLOR_RED : Graphics.COLOR_WHITE);
			setMoveIcon(moveBarLevel, userProfile);
			
			moveIcon.draw();
			dndIcon.draw();
			btIcon.draw();
		}
		
		function setMoveIcon(lvl, userProfile) {
			var targetIcon = null;
			var isInSleeptTime = isInSleepTime(userProfile);
			
			if(!isInSleeptTime) {
				if(lvl == 0) {
					targetIcon = "Move-0";
				} else if(lvl > 0 && lvl < 3) {
					targetIcon = "Move-1";
				} else {
					targetIcon = "Move-5";
				}
			} else {
				targetIcon = "Sleep";
			}
			moveIcon.setIcon(targetIcon);
			
			if(!isInSleeptTime) {
				if(lvl >= 1) {
					moveIcon.setColor(Graphics.COLOR_RED);
				} else {
					moveIcon.setColor(Graphics.COLOR_WHITE);
				}
			} else {
				moveIcon.setColor(Graphics.COLOR_RED);
			}
		}
		
		function isInSleepTime(userProfile) {
	        var today = Time.today().value();
	        
	        var sleepTime = new Time.Moment(today + userProfile.sleepTime.value());
	        var now = new Time.Moment(Time.now().value());
	        
	        if(now.value() >= sleepTime.value()) {
	       		return true;
	        } else {
	         	var wakeTime = new Time.Moment(today + userProfile.wakeTime.value());
	         	
	        	if(now.value() <= wakeTime.value()) {
	        		return true;
	        	} else {
	        		return false;
	        	}
	        }
    	}
	}

	class Top extends UiElementBase {
		private var daysText;
		private var arrowIcon;
		private var daysInitialY = 87;
		private var daysYOffset = 3;
		private var dayNames = [ "SU", "MO", "TU", "WE", "TH", "FR", "SA" ];
		private var application;
		private var infoText;

		function initialize(dc, application, fntAsapBold12) {
			UiElementBase.initialize(dc);
			self.application = application;

			arrowIcon = new Icons.Icon("Arrow-Up", dc);
			arrowIcon.setColor(Graphics.COLOR_RED);
			arrowIcon.setPosition(56, 93);

			daysText = new [7];

			for(var i = 0; i < daysText.size(); ++i) {
				daysText[i] = new WatchUi.Text({
					:text  => dayNames[i],
		            :color => Graphics.COLOR_WHITE,
		            :font  => fntAsapBold12,
		            :locY  => daysInitialY
	        	});
	        	daysText[i].setJustification(Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
			}
			orderDaysOfWeek(application.getProperty("FirstDayOfWeek"));
			
			infoText = new WatchUi.Text({
	            :color => Graphics.COLOR_WHITE,
	            :font  => fntAsapBold12,
	            :locX  => 130,
	            :locY  => 40
        	});
        	infoText.setJustification(Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
		}
		
		function draw() {
			var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
			var dayOfWeek = now.day_of_week;

			for(var i = 0; i < daysText.size(); ++i) {
				if(i == dayOfWeek - 1) {
					daysText[i].setColor(Graphics.COLOR_RED);
					
					daysText[i].locY = daysInitialY - daysYOffset;
					
					arrowIcon.setPosition(daysText[i].locX, arrowIcon.text.locY);
				} else {
					if(dayNames[i].equals("SA") || dayNames[i].equals("SU")) {
						daysText[i].setColor(Graphics.COLOR_LT_GRAY);
					} else {
						daysText[i].setColor(Graphics.COLOR_WHITE);
					}
					daysText[i].locY = daysInitialY;
				}
				daysText[i].draw(dc);
				arrowIcon.draw();
			}
			infoText.setText("Week " + Utils.getCurrentWeekNumber());
			infoText.draw(dc);
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
			
			for(var i = 0; i < daysText.size(); ++i) {
				daysText[i].locX = xLocations[i];
			}
		}
		
		function onSettingUpdate() {
	    	orderDaysOfWeek(application.getProperty("FirstDayOfWeek"));
	    }
	}
	
	class Bottom extends UiElementBase {
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
	
	class Right extends UiElementBase {
		var topValue;
		var bottomValue;
		
		function initialize(dc, fntAsapCondensedBold14) {
			UiElementBase.initialize(dc);
			
			topValue = new WatchUi.Text({
	            :color => Graphics.COLOR_WHITE,
	            :font  => fntAsapCondensedBold14,
	            :locX  => 241,
	            :locY  => 87
        	});
        	bottomValue = new WatchUi.Text({
	            :color => Graphics.COLOR_WHITE,
	            :font  => fntAsapCondensedBold14,
	            :locX  => 241,
	            :locY  => 171
        	});
        	topValue.setJustification(Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
        	bottomValue.setJustification(Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
		}
		
		function draw() {
			var info = ActivityMonitor.getInfo();
			var steps = info.steps != null ? info.steps : 0;
			var stepGoal = info.stepGoal != null ? info.stepGoal : 0;

			topValue.setText(Utils.kFormatter(stepGoal, 1));
			bottomValue.setText(Utils.kFormatter(steps, 1));
			
			topValue.draw(dc);
			bottomValue.draw(dc);
		}
	}
	
	class Left extends UiElementBase {
		var topValue;
		var bottomValue;
		var icon;
		var heartRate;
		var sleep;
		var heartShown;
		
		function initialize(dc, fntAsapCondensedBold14, fntAsapBold12) {
			UiElementBase.initialize(dc);
			
			sleep = false;
			heartShown = true;
			
			topValue = new WatchUi.Text({
	            :color => Graphics.COLOR_WHITE,
	            :font  => fntAsapCondensedBold14,
	            :locX  => 19,
	            :locY  => 87
        	});
        	bottomValue = new WatchUi.Text({
	            :color => Graphics.COLOR_WHITE,
	            :font  => fntAsapCondensedBold14,
	            :locX  => 19,
	            :locY  => 171
        	});
        	heartRate = new WatchUi.Text({
        		:text  => "0",
	            :color => Graphics.COLOR_WHITE,
	            :font  => fntAsapBold12,
	            :locX  => 9,
	            :locY  => 118
        	});
        	topValue.setJustification(Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
        	bottomValue.setJustification(Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
        	heartRate.setJustification(Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
        	
        	icon = new Icons.Icon("Heart-1", dc);
        	
        	icon.setColor(Graphics.COLOR_RED);
			icon.setPosition(9, 130);
		}
		
		function draw(userProfile) {
			var restingHeartRate = userProfile.restingHeartRate;
			var maxHeartRate = Utils.getMaxHeartRate();

			topValue.setText(Utils.kFormatter(maxHeartRate, 1));
			bottomValue.setText(Utils.kFormatter(restingHeartRate, 1));
			
			if(!sleep) {
				var currentHeartRate = Utils.getCurrentHeartRate();
				
				heartRate.setText(currentHeartRate.toString());

				icon.setIcon(heartShown ? "Heart-1" : "Heart-2");
				
				heartShown = !heartShown;
				
				heartRate.setColor(Graphics.COLOR_WHITE);
			} else {
				icon.setIcon("Heart-1");
				heartRate.setColor(Graphics.COLOR_TRANSPARENT);
			}
			topValue.draw(dc);
			bottomValue.draw(dc);
			heartRate.draw(dc);
			icon.draw();
		}
		
		function onEnterSleep() {
			sleep = true;
	    }
	    
	    function onExitSleep() {
			sleep = false;
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
		"MoveBar-2"    => "K",
		"Move-0"       => "L",
		"Sleep"        => "M",
		"Heart-1"      => "N",
		"Heart-2"      => "O"
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

// TODO: All heart rate related functions need to be checked if they have heart rate monitor
module Utils {
	function getDayWithMondayStarting(daySundayStarting) {
    	if(daySundayStarting != 1) {
    		return daySundayStarting - 1;
    	}
    	return 7; // Sunday
    }
    
    function getCurrentWeekNumber() {
		var today = new Time.Moment(Time.today().value() + System.getClockTime().timeZoneOffset);
		var todayGregorian = Gregorian.info(today, Time.FORMAT_SHORT);
		
		var options = {
		    :year   => todayGregorian.year,
		    :month  => 1,
		    :day    => 1,
		    :hour   => 0,
		    :min    => 0,
		    :sec    => 0
		};
		var firstDayOfYear = Gregorian.moment(options);
		var firstDayOfYearGregorian = Gregorian.info(firstDayOfYear, Time.FORMAT_SHORT);

		return Math.ceil((today.subtract(firstDayOfYear).add(new Time.Duration(Gregorian.SECONDS_PER_DAY * getDayWithMondayStarting(firstDayOfYearGregorian.day_of_week))).value() / 86400).toFloat() / 7).toNumber();
    }
    
    function kFormatter(num, precision) {
    	var sign = num >= 0 ? "" : "-";
    	
    	return num.abs() > 999 ? sign + ((num.abs() % 1000 != 0 ? (num.abs() / 1000.0).format("%." + precision + "f") : (num.abs() / 1000.0).format("%d"))) + "k" : num + "";
	}

	function getMaxHeartRate() {
		return ActivityMonitor.getHeartRateHistory(null, false).getMax();
	}
	
	function getMinHeartRate() {
		return ActivityMonitor.getHeartRateHistory(null, false).getMin();
	}
	
	function getAvgHeartRate() {
		var heartRateHistory = ActivityMonitor.getHeartRateHistory(null, false);
		var sum = 0;
		var count = 0;

		var sample = heartRateHistory.next();
		
		while(sample != null) {
			if(sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
				System.println(sample.heartRate);
				sum += sample.heartRate;
				++count;
			}
			sample = heartRateHistory.next();
		}
		return count > 0 ? sum / count : null;
	}
	
	function getCurrentHeartRate() {
		var heartRate = Activity.getActivityInfo().currentHeartRate;
		
		if(heartRate == null) {
			var heartRateHistory = ActivityMonitor.getHeartRateHistory(null, true);
			var sample = heartRateHistory.next();

			while(sample != null && heartRate == null) {
				if(sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
					heartRate = sample.heartRate;
				}
				sample = heartRateHistory.next();
			}
		}
		return heartRate;
	}
}