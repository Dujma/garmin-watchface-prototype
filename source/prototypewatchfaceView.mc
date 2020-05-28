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
using Toybox.UserProfile;

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
	private var powerSavingMode;
	private var topIconsPowerSaving;
	private var bottomIconsPowerSaving;
	private var bottomLine;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        application = Application.getApp();
        
        Textures.init();
        
        mockBackground = new WatchUi.Bitmap({
        	:rezId => Rez.Drawables.MockBackground,
        	:locX  => 0,
        	:locY  => 0
    	});
    	var fntAsapCondensedBold14 = WatchUi.loadResource(Rez.Fonts.AsapCondensedBold14);
    	var fntAsapBold12 = WatchUi.loadResource(Rez.Fonts.AsapBold12);
    	var fntAsapCondensedBold16 = WatchUi.loadResource(Rez.Fonts.AsapCondensedBold16);
    	
    	powerSavingMode = application.getProperty("PowerSavingMode");
    	
        clockArea = new UiElements.ClockArea(dc, fntAsapCondensedBold14, application);
        topIcons = new UiElements.TopIcons(dc, fntAsapCondensedBold14);
        bottomIcons = new UiElements.BottomIcons(dc);
        top = new UiElements.Top(dc, application, fntAsapBold12, fntAsapCondensedBold16);
        bottom = new UiElements.Bottom(dc, fntAsapCondensedBold16);
        right = new UiElements.Right(dc, fntAsapCondensedBold14);
        left = new UiElements.Left(dc, fntAsapCondensedBold14, fntAsapBold12);
        topIconsPowerSaving = new UiElements.TopIconsLarge(dc, fntAsapCondensedBold16);
        bottomIconsPowerSaving = new UiElements.BottomIconsLarge(dc);
        bottomLine = new UiElements.BottomLine(dc, application);
    }

    function onShow() {
		
    }
    
    function onUpdate(dc) {
    	// Background
    	drawBackground(dc);
		
    	var deviceSettings = System.getDeviceSettings();
    	var systemStats = System.getSystemStats();
   	 	var userProfile = UserProfile.getProfile();
   	 	var activityMonitorInfo = ActivityMonitor.getInfo();
   	 	var powerSavingModeActive = isPowerSavingModeActive(deviceSettings.doNotDisturb);
   	 	
   	 	if(!powerSavingModeActive) {
   	 		bottomLine.draw(activityMonitorInfo);
   	 		mockBackground.draw(dc);
   	 	}
		clockArea.draw(deviceSettings, powerSavingModeActive);
		
		// UiElements
		if(!powerSavingModeActive) {
			topIcons.draw(deviceSettings, systemStats);
			bottomIcons.draw(deviceSettings, userProfile, activityMonitorInfo);
			top.draw();
			bottom.draw(activityMonitorInfo);
			right.draw(activityMonitorInfo);
			left.draw(userProfile);
		} else {
			topIconsPowerSaving.draw(deviceSettings, systemStats);
			bottomIconsPowerSaving.draw(deviceSettings, userProfile, activityMonitorInfo);
		}
    }
    
    function isPowerSavingModeActive(doNotDisturb) {
    	return powerSavingMode == 1 || (powerSavingMode == 2 && doNotDisturb);
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
    	powerSavingMode = application.getProperty("PowerSavingMode");
    
    	clockArea.onSettingUpdate();
    	top.onSettingUpdate();
    	bottomLine.onSettingUpdate();
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
		private var isSleep;
		private var hoursText;
		private var hoursFormat;
		private var minutesText;
		private var minutesColon;
		private var secondsText;
		private var dateText;
		private var partOfDayText;
		private var application;
		private var clockElements;
		private var displaySeconds;
		private var powerSavingModeActive;

	    function initialize(dc, fntAsapCondensedBold14, application) {
			UiElementBase.initialize(dc);
			self.application = application;
			
			isSleep = false;
			clockElements = new [0];

			var fntAsapBold81 = WatchUi.loadResource(Rez.Fonts.AsapBold81);
	        var fntAsapSemibold55 = WatchUi.loadResource(Rez.Fonts.AsapSemibold55);
	        var fntAsapCondensedSemiBold20 = WatchUi.loadResource(Rez.Fonts.AsapCondensedSemiBold20);

			hoursText = clockElements.add(new Extensions.Text({
	            :color         => Graphics.COLOR_WHITE,
	            :typeface      => fntAsapBold81,
	            :locX          => 89 + (self.dc.getTextWidthInPixels("00", fntAsapBold81) / 2),
	            :locY          => 129,
	            :justification => Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_RIGHT
	        }, dc, false))[clockElements.size() - 1];
	        minutesText = clockElements.add(new Extensions.Text({
	            :color    => Graphics.COLOR_LT_GRAY,
	            :typeface => fntAsapSemibold55,
	            :locX     => 178,
	            :locY     => 119
	        }, dc, true))[clockElements.size() - 1];
	        minutesColon = clockElements.add(new Extensions.Text({
	            :color    => Graphics.COLOR_LT_GRAY,
	            :typeface => fntAsapSemibold55,
	            :locX     => 139,
	            :locY     => 119
	        }, dc, true))[clockElements.size() - 1];
	        dateText = clockElements.add(new Extensions.Text({
	            :color    => Graphics.COLOR_WHITE,
	            :typeface => fntAsapCondensedSemiBold20,
	            :locX     => 178,
	            :locY     => 150
	        }, dc, true))[clockElements.size() - 1];
	        partOfDayText = clockElements.add(new Extensions.Text({
	            :color    => Graphics.COLOR_WHITE,
	            :typeface => fntAsapCondensedBold14,
	            :locX     => 43,
	            :locY     => 152
	        }, dc, true))[clockElements.size() - 1];
	        secondsText = new Extensions.Text({
	            :color    => Graphics.COLOR_LT_GRAY,
	            :typeface => fntAsapCondensedBold14,
	            :locX     => 215,
	            :locY     => 106
	        }, dc, true);

	        hoursFormat = application.getProperty("AddLeadingZero") ? "%02d" : "%d";
	        displaySeconds = application.getProperty("DisplaySeconds");
	    }
	
	    function draw(deviceSettings, powerSavingModeActive) {
	    	self.powerSavingModeActive = powerSavingModeActive;
	    	
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

			if(!isSleep && !self.powerSavingModeActive) {
				secondsText.setText(now.sec.format("%02d"));
				secondsText.draw(dc);
			}
			Utils.drawLine(dc, 130, 96, 185, 3, Graphics.COLOR_RED);
			Utils.drawLine(dc, 130, 162, 185, 3, Graphics.COLOR_RED);
	    }

	    function onSettingUpdate() {
	    	hoursFormat = application.getProperty("AddLeadingZero") ? "%02d" : "%d";
	    	displaySeconds = application.getProperty("DisplaySeconds");
	    }
	    
	    function onEnterSleep() {
	        isSleep = true;
	        
	    	secondsText.setColor(Graphics.COLOR_TRANSPARENT);
	    }
	    
	    function onExitSleep() {
	    	isSleep = false;
	    	
	    	secondsText.setColor(Graphics.COLOR_LT_GRAY);
	    }
	    
	    function setClockPosition(secondsEnabled) {
	    	// TODO: Old state needs to be checked
	    	if(shouldDisplaySeconds()) {
		    	for(var i = 0; i < clockElements.size(); ++i) {
		    		
		    	}
	    	} else {
	    	
	    	}
	    }
	    
	    function shouldDisplaySeconds() {
	    	if(!powerSavingModeActive) {
	    		return (displaySeconds == 0 && !isSleep) || displaySeconds == 1 ? true : false;
	    	}
	    	return false;
	    }
	}
	
	class TopIconsBase extends UiElementBase {
		protected var batteryText;
		protected var batteryIcon;
		protected var notificationIcon;
		protected var alarmIcon;
		
		function initialize(dc) {
			UiElementBase.initialize(dc);
			
			return self;
		}
		
		function draw(deviceSettings, systemStats, batteryIcons) {
			var batteryLvl = Math.round(systemStats.battery);

			batteryText.setText(Lang.format("$1$%", [ (batteryLvl + 0.5).format( "%d" ) ]));
			batteryText.draw(dc);
			
			setBatteryIcon(batteryLvl, batteryIcons);
			
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
		
		function setBatteryIcon(lvl, icons) {
			var targetIcon = null;
			var batteryIconsValues = icons.values();
			
			for(var i = 0; i < icons.size(); ++i) {
				if(lvl > batteryIconsValues[i]["min"] && lvl <= batteryIconsValues[i]["max"]) {
					targetIcon = icons.keys()[i];
					break;
				}
			}
			if(targetIcon != null) {
				if(batteryIcon.getName() != targetIcon) {
					batteryIcon.setIcon(targetIcon);
				}
			}
		}
	}
	
	class TopIcons extends TopIconsBase {
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

		function initialize(dc, fntAsapCondensedBold14) {
			TopIconsBase.initialize(dc);
		
			batteryIcon = new Textures.Icon("Battery-100", dc);
			batteryIcon.setPosition(130, 19);
			
			batteryText = new Extensions.Text({
	            :color    => Graphics.COLOR_WHITE,
	            :typeface => fntAsapCondensedBold14,
	            :locX     => 130,
	            :locY     => 8
	        }, dc, true);
	        
			notificationIcon = new Textures.Icon("Notification", dc);
			notificationIcon.setPosition(154, 16);
			
			alarmIcon = new Textures.Icon("Alarm", dc);
			alarmIcon.setPosition(104, 15);
		}
		
		function draw(deviceSettings, systemStats) {
			TopIconsBase.draw(deviceSettings, systemStats, batteryIcons);
		}
	}
	
	class TopIconsLarge extends TopIconsBase {
		private var batteryIcons = { 
			"Battery-100-L" => { "max" => 100, "min" => 90 },
			"Battery-90-L"  => { "max" => 90,  "min" => 80 },
			"Battery-80-L"  => { "max" => 80,  "min" => 70 },
			"Battery-70-L"  => { "max" => 70,  "min" => 60 },
			"Battery-60-L"  => { "max" => 60,  "min" => 50 },
			"Battery-50-L"  => { "max" => 50,  "min" => 40 },
			"Battery-40-L"  => { "max" => 40,  "min" => 30 },
			"Battery-30-L"  => { "max" => 30,  "min" => 20 },
			"Battery-20-L"  => { "max" => 20,  "min" => 10 },
			"Battery-10-L"  => { "max" => 10,  "min" => 5  },
			"Battery-5-L"   => { "max" => 5,   "min" => 1  },
			"Battery-0-L"   => { "max" => 1,   "min" => -1 }
		};

		function initialize(dc, fntAsapCondensedBold16) {
			TopIconsBase.initialize(dc);
		
			batteryIcon = new Textures.Icon("Battery-100-L", dc);
			batteryIcon.setPosition(130, 50);
			
			batteryText = new Extensions.Text({
	            :color    => Graphics.COLOR_WHITE,
	            :typeface => fntAsapCondensedBold16,
	            :locX     => 130,
	            :locY     => 33
	        }, dc, true);

			notificationIcon = new Textures.Icon("Notification-L", dc);
			notificationIcon.setPosition(180, 55);
			
			alarmIcon = new Textures.Icon("Alarm-L", dc);
			alarmIcon.setPosition(80, 55);
		}
		
		function draw(deviceSettings, systemStats) {
			TopIconsBase.draw(deviceSettings, systemStats, batteryIcons);
		}
	}
	
	class BottomIconsBase extends UiElementBase {
		protected var moveIcon;
		protected var dndIcon;
		protected var btIcon;
		
		function initialize(dc) {
			UiElementBase.initialize(dc);
		}
		
		function draw(deviceSettings, userProfile, activityMonitorInfo, isLarge) {
			var moveBarLevel = activityMonitorInfo.moveBarLevel;

			dndIcon.setColor(deviceSettings.doNotDisturb ? Graphics.COLOR_RED : Graphics.COLOR_WHITE); // 2.1.0
			btIcon.setColor(deviceSettings.phoneConnected ? Graphics.COLOR_RED : Graphics.COLOR_WHITE);
			setMoveIcon(moveBarLevel, userProfile, isLarge);
			
			moveIcon.draw();
			dndIcon.draw();
			btIcon.draw();
		}
		
		function setMoveIcon(lvl, userProfile, isLarge) {
			var targetIcon = null;
			var isInSleeptTime = isInSleepTime(userProfile);
			
			if(!isInSleeptTime) {
				if(lvl == 0) {
					targetIcon = "Move-0" + (isLarge ? "-L" : "");
				} else if(lvl > 0 && lvl < 3) {
					targetIcon = "Move-1" + (isLarge ? "-L" : "");
				} else {
					targetIcon = "Move-5" + (isLarge ? "-L" : "");
				}
			} else {
				targetIcon = "Sleep" + (isLarge ? "-L" : "");
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
	
	class BottomIcons extends BottomIconsBase {
		function initialize(dc) {
			BottomIconsBase.initialize(dc);
			
			moveIcon = new Textures.Icon("Move-1", dc);
			moveIcon.setPosition(104, 243);
			
			dndIcon = new Textures.Icon("Dnd", dc);
			dndIcon.setPosition(130, 247);
			
			btIcon = new Textures.Icon("Bluetooth", dc);
			btIcon.setPosition(155, 244);
		}
		
		function draw(deviceSettings, userProfile, activityMonitorInfo) {
			BottomIconsBase.draw(deviceSettings, userProfile, activityMonitorInfo, false);
		}
	}
	
	class BottomIconsLarge extends BottomIconsBase {
		function initialize(dc) {
			BottomIconsBase.initialize(dc);
			
			moveIcon = new Textures.Icon("Move-1-L", dc);
			moveIcon.setPosition(80, 205);
			
			dndIcon = new Textures.Icon("Dnd-L", dc);
			dndIcon.setPosition(130, 215);
			
			btIcon = new Textures.Icon("Bluetooth-L", dc);
			btIcon.setPosition(180, 205);
		}
		
		function draw(deviceSettings, userProfile, activityMonitorInfo) {
			BottomIconsBase.draw(deviceSettings, userProfile, activityMonitorInfo, true);
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
		private var iconLeft;
		private var iconMiddle;
		private var iconRight;
		private var iconTextLeft;
		private var iconTextMiddle;
		private var iconTextRight;

		function initialize(dc, application, fntAsapBold12, fntAsapCondensedBold16) {
			UiElementBase.initialize(dc);
			self.application = application;

			arrowIcon = new Textures.Icon("Arrow-Up", dc);
			arrowIcon.setColor(Graphics.COLOR_RED);
			arrowIcon.setPosition(56, 93);
			
			iconLeft = new Textures.Icon("Calendar", dc);
			iconLeft.setColor(Graphics.COLOR_WHITE);
			iconLeft.setPosition(93, 65);
			
			iconMiddle = new Textures.Icon("Moon-0", dc);
			iconMiddle.setColor(Graphics.COLOR_WHITE);
			iconMiddle.setPosition(138, 65);
			
			iconRight = new Textures.Icon("Elevation", dc);
			iconRight.setColor(Graphics.COLOR_WHITE);
			iconRight.setPosition(192, 65);
			
			iconTextLeft = new Extensions.Text({
	            :color         => Graphics.COLOR_WHITE,
	            :typeface      => fntAsapCondensedBold16,
	            :locX          => 83,
	            :locY          => 58,
	            :justification => Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_RIGHT
        	}, dc, false);
        	
        	iconTextMiddle = new Extensions.Text({
	            :color         => Graphics.COLOR_WHITE,
	            :typeface      => fntAsapCondensedBold16,
	            :locX          => 133,
	            :locY          => 58,
	            :justification => Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_RIGHT
        	}, dc, false);
        	
        	iconTextRight = new Extensions.Text({
	            :color         => Graphics.COLOR_WHITE,
	            :typeface      => fntAsapCondensedBold16,
	            :locX          => 182,
	            :locY          => 58,
	            :justification => Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_RIGHT
        	}, dc, false);

			daysText = new [7];

			for(var i = 0; i < daysText.size(); ++i) {
				daysText[i] = new Extensions.Text({
					:text     => dayNames[i],
		            :color    => Graphics.COLOR_WHITE,
		            :typeface => fntAsapBold12,
		            :locY     => daysInitialY
	        	}, dc, true);
			}
			orderDaysOfWeek(application.getProperty("FirstDayOfWeek"));
			
			infoText = new Extensions.Text({
	            :color    => Graphics.COLOR_WHITE,
	            :typeface => fntAsapBold12,
	            :locX     => 130,
	            :locY     => 40
        	}, dc, true);
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
			// infoText.setText("Week " + Utils.getCurrentWeekNumber());
			infoText.setText(Utils.getTimeByOffset(application));
			infoText.draw(dc);
			
			// TODO: Store this and update it only once a day
			var currentMoonPhase = Utils.getCurrentMoonPhase();
			
			iconTextLeft.setText(Utils.getCurrentWeekNumber().toString());
			iconTextMiddle.setText(currentMoonPhase["angle"] + "°");
			iconTextRight.setText(Utils.kFormatter(Utils.getCurrentElevation(), 1));
			
			iconMiddle.setIcon(currentMoonPhase["icon"]);
			
			iconLeft.draw();
			iconMiddle.draw();
			iconRight.draw();
			
			iconTextLeft.draw(dc);
			iconTextMiddle.draw(dc);
			iconTextRight.draw(dc);
		}
		
		function getXLocationsBasedOnFirstDayOfWeek(firstDayOfWeek) {
			var xLocations = [ 55, 80, 105, 130, 155, 180, 205 ];

			if(firstDayOfWeek == Gregorian.DAY_MONDAY) {
				xLocations = [ 205, 55, 80, 105, 130, 155, 180 ];
				
				             
			} else if(firstDayOfWeek == Gregorian.DAY_SATURDAY) {
				xLocations = [ 80, 105, 130, 155, 180, 205, 55 ];
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
		private var moveBarLvl1;
		private var moveBarOtherLvls;
		
		private var icon1;
		private var icon2;
		private var icon3;
		private var icon4;
		
		private var textIcon1;
		private var textIcon2; 
		private var textIcon3;
		private var textIcon4;

		function initialize(dc, fntAsapCondensedBold16) {
			UiElementBase.initialize(dc);
			
    		moveBarLvl1 = new Textures.Icon("MoveBar-1", dc);
    		moveBarLvl1.setPosition(101, 219);
    		
    		moveBarOtherLvls = new [4];
    		
    		for(var i = 0; i < moveBarOtherLvls.size(); ++i) {
    			moveBarOtherLvls[i] = new Textures.Icon("MoveBar-2", dc);
    			moveBarOtherLvls[i].setPosition(120 + (i * 14), 219);
    		}
    		icon1 = new Textures.Icon("Distance", dc);
    		icon2 = new Textures.Icon("Calories", dc);
    		icon3 = new Textures.Icon("Stopwatch", dc);
    		icon4 = new Textures.Icon("Stairs-Up", dc);
    		
    		icon1.setColor(Graphics.COLOR_RED);
    		icon2.setColor(Graphics.COLOR_RED);
    		icon3.setColor(Graphics.COLOR_RED);
    		icon4.setColor(Graphics.COLOR_RED);
    		
    		icon1.setPosition(72, 174);
    		icon2.setPosition(110, 185);
    		icon3.setPosition(150, 185);
    		icon4.setPosition(188, 175);
    		
    		textIcon1 = new Extensions.Text({
	            :color    => Graphics.COLOR_WHITE,
	            :typeface => fntAsapCondensedBold16,
	            :locX     => 72,
	            :locY     => 190
        	}, dc, true);
        	textIcon2 = new Extensions.Text({
	            :color    => Graphics.COLOR_WHITE,
	            :typeface => fntAsapCondensedBold16,
	            :locX     => 110,
	            :locY     => 201
        	}, dc, true);
        	textIcon3 = new Extensions.Text({
	            :color    => Graphics.COLOR_WHITE,
	            :typeface => fntAsapCondensedBold16,
	            :locX     => 150,
	            :locY     => 201
        	}, dc, true);
        	textIcon4 = new Extensions.Text({
	            :color    => Graphics.COLOR_WHITE,
	            :typeface => fntAsapCondensedBold16,
	            :locX     => 188,
	            :locY     => 190
        	}, dc, true);
		}
		
		function draw(activityMonitorInfo) {
			var moveBarLevel = activityMonitorInfo.moveBarLevel;

			if(moveBarLevel > 0) {
				moveBarLvl1.setColor(Graphics.COLOR_RED);
				moveBarLvl1.draw();
				
				for(var i = 0; i < moveBarLevel - 1; ++i) {
					moveBarOtherLvls[i].setColor(Graphics.COLOR_RED);
					moveBarOtherLvls[i].draw();
				}
				for(var i = moveBarLevel - 1; i < moveBarOtherLvls.size(); ++i) {
					moveBarOtherLvls[i].setColor(Graphics.COLOR_DK_GRAY);
					moveBarOtherLvls[i].draw();
				}
			} else {
				moveBarLvl1.setColor(Graphics.COLOR_DK_GRAY);
				moveBarLvl1.draw();
				
				for(var i = 0; i < moveBarOtherLvls.size(); ++i) {
					moveBarOtherLvls[i].setColor(Graphics.COLOR_DK_GRAY);
					moveBarOtherLvls[i].draw();
				}
			}
			var distance = activityMonitorInfo.distance != null ? activityMonitorInfo.distance : 0;
			var calories = activityMonitorInfo.calories != null ? activityMonitorInfo.calories : 0;
			var activeMinutesWeek = activityMonitorInfo.activeMinutesWeek != null ? activityMonitorInfo.activeMinutesWeek.total : 0;
			var floorsClimbed = activityMonitorInfo.floorsClimbed != null ? activityMonitorInfo.floorsClimbed : 0;
			
			icon1.draw();
			icon2.draw();
			icon3.draw();
			icon4.draw();
			
			textIcon1.setText(Utils.kFormatter(distance * 0.01, 1));
			textIcon2.setText(Utils.kFormatter(calories, 1));
			textIcon3.setText(Utils.kFormatter(activeMinutesWeek, 1));
			textIcon4.setText(Utils.kFormatter(floorsClimbed, 1));
			
			textIcon1.draw(dc);
			textIcon2.draw(dc);
			textIcon3.draw(dc);
			textIcon4.draw(dc);
		}
	}
	
	// TODO: Think about having a base class for right and left
	class Right extends UiElementBase {
		private var topValueText;
		private var bottomValueText;
		private var icon;
		private var trophyIcon;
		private var initialX = 242;
		private var arrowIcon;
		private var maxAngle = 37;
		private var radius = 104;
		private var centerAngle = 18;
		private var lineBitmap;
		
		function initialize(dc, fntAsapCondensedBold14) {
			UiElementBase.initialize(dc);
			
			topValueText = new Extensions.Text({
	            :color    => Graphics.COLOR_WHITE,
	            :typeface => fntAsapCondensedBold14,
	            :locX     => initialX,
	            :locY     => 87
        	}, dc, true);
        	bottomValueText = new Extensions.Text({
	            :color    => Graphics.COLOR_WHITE,
	            :typeface => fntAsapCondensedBold14,
	            :locX     => initialX,
	            :locY     => 171
        	}, dc, true);

        	icon = new Textures.Icon("Steps-Side", dc);
        	icon.setColor(Graphics.COLOR_WHITE);
			icon.setPosition(251, 130);
			
			trophyIcon = new Textures.Icon("Trophy", dc);
			
			trophyIcon.setColor(Graphics.COLOR_YELLOW);
			trophyIcon.setPosition(251, 115);
			
			arrowIcon = new Textures.Icon("Arrow-Right", dc);
			
			arrowIcon.setColor(Graphics.COLOR_RED);
			
			lineBitmap = new Textures.Bitmap("Line-Right", dc);
			
			lineBitmap.setPosition(241, 130);
		}
		
		function draw(activityMonitorInfo) {
			var topValue = activityMonitorInfo.stepGoal != null ? activityMonitorInfo.stepGoal : 0;
			var bottomValue = activityMonitorInfo.steps != null ? activityMonitorInfo.steps : 0;

			topValueText.setText(Utils.kFormatter(topValue, topValue > 99999 ? 0 : 1));
			bottomValueText.setText(Utils.kFormatter(bottomValue, bottomValue > 99999 ? 0 : 1));
			
			topValueText.locX = offSetXBasedOnWidth(topValueText.getDimensions()[0]);
			bottomValueText.locX = offSetXBasedOnWidth(bottomValueText.getDimensions()[0]);
			
			topValueText.draw(dc);
			bottomValueText.draw(dc);
			
			if(bottomValue >= topValue) {
				trophyIcon.draw();
			}
			icon.draw();
			
			lineBitmap.draw();
			drawArrow(topValue, bottomValue);
		}
		
		function drawArrow(topValue, bottomValue) {
			var percentage = bottomValue >= topValue ? 1.0 : bottomValue / topValue.toFloat();
			var targetPosition = maxAngle * percentage;
			
			var pointOnCircle = Utils.getPointOnCircle(dc.getWidth() / 2, dc.getHeight() / 2, radius, -1 * targetPosition, centerAngle);
			
	   	 	var x = pointOnCircle[0];
	   	 	var y = pointOnCircle[1];
	   	 	
	   	 	arrowIcon.setPosition(x, y);
			arrowIcon.draw();
		}
		
		function offSetXBasedOnWidth(width) {
			if(width <= 16) {
				return initialX;
			} else if(width > 16 && width <= 24) {
				return initialX - 2;
			} else if(width > 24 && width <= 26) {
				return initialX - 3;
			} else if(width > 26 && width <= 31) {
				return initialX - 6;
			} else {
				return initialX - 7;
			}
		}
	}
	
	class Left extends UiElementBase {
		private var topValueText;
		private var bottomValueText;
		private var icon;
		private var initialX = 18;
		private var arrowIcon;
		private var maxAngle = 37;
		private var radius = 104;
		private var centerAngle = 162; // Reference to "Right". 180 - 18 = 162
		private var lineBitmap;
		
		// Feature only when heart rate is shown
		var heartRateText;
		var isSleep;
		var heartFilled;
		
		function initialize(dc, fntAsapCondensedBold14, fntAsapBold12) {
			UiElementBase.initialize(dc);
			
			isSleep = false;
			heartFilled = true;
			
			topValueText = new Extensions.Text({
	            :color    => Graphics.COLOR_WHITE,
	            :typeface => fntAsapCondensedBold14,
	            :locX     => initialX,
	            :locY     => 87
        	}, dc, true);
        	bottomValueText = new Extensions.Text({
	            :color    => Graphics.COLOR_WHITE,
	            :typeface => fntAsapCondensedBold14,
	            :locX     => initialX,
	            :locY     => 171
        	}, dc, true);
        	heartRateText = new Extensions.Text({
        		:text     => "--",
	            :color    => Graphics.COLOR_WHITE,
	            :typeface => fntAsapBold12,
	            :locX     => 9,
	            :locY     => 118
        	}, dc, true);

        	icon = new Textures.Icon("Heart-1", dc);
        	icon.setColor(Graphics.COLOR_RED);
			icon.setPosition(9, 130);
			
			arrowIcon = new Textures.Icon("Arrow-Left", dc);
			
			arrowIcon.setColor(Graphics.COLOR_RED);
			
			lineBitmap = new Textures.Bitmap("Line-Left", dc);
			
			lineBitmap.setPosition(19, 130);
		}
		
		function draw(userProfile) {
			var topValue = Utils.getMaxHeartRate();
			var bottomValue = userProfile.restingHeartRate;

			topValueText.setText(Utils.kFormatter(topValue, topValue > 99999 ? 0 : 1));
			bottomValueText.setText(Utils.kFormatter(bottomValue, bottomValue > 99999 ? 0 : 1));

			topValueText.locX = offSetXBasedOnWidth(topValueText.getDimensions()[0]);
			bottomValueText.locX = offSetXBasedOnWidth(bottomValueText.getDimensions()[0]);

			topValueText.draw(dc);
			bottomValueText.draw(dc);

			icon.draw();
			
			drawHeartRate();
			
			lineBitmap.draw();
			drawArrow(topValue, bottomValue);
		}
		
		function drawHeartRate() {
			if(!isSleep) {
				var currentHeartRate = Utils.getCurrentHeartRate();
				
				heartRateText.setText(currentHeartRate.toString());

				icon.setIcon(heartFilled ? "Heart-1" : "Heart-2");
				
				heartFilled = !heartFilled;
				
				heartRateText.setColor(Graphics.COLOR_WHITE);
			} else {
				icon.setIcon("Heart-1");
				heartRateText.setColor(Graphics.COLOR_TRANSPARENT);
			}
			heartRateText.draw(dc);
		}
		
		function drawArrow(topValue, bottomValue) {
			var percentage = bottomValue >= topValue ? 1.0 : bottomValue / topValue.toFloat();
			var targetPosition = maxAngle * percentage;
			
			var pointOnCircle = Utils.getPointOnCircle(dc.getWidth() / 2, dc.getHeight() / 2, radius, targetPosition, centerAngle);
			
	   	 	var x = pointOnCircle[0];
	   	 	var y = pointOnCircle[1];
	   	 	
	   	 	arrowIcon.setPosition(x, y);
			arrowIcon.draw();
		}
		
		function onEnterSleep() {
			isSleep = true;
			heartFilled = true;
			
			icon.setIcon("Heart-1");
			heartRateText.setColor(Graphics.COLOR_TRANSPARENT);
	    }
	    
	    function onExitSleep() {
			isSleep = false;
			heartFilled = false;
			
			icon.setIcon("Heart-2");
			heartRateText.setColor(Graphics.COLOR_WHITE);
	    }
	    
	    function offSetXBasedOnWidth(width) {
			if(width <= 16) {
				return initialX;
			} else if(width > 16 && width <= 24) {
				return initialX + 2;
			} else if(width > 24 && width <= 26) {
				return initialX + 3;
			} else if(width > 26 && width <= 31) {
				return initialX + 6;
			} else {
				return initialX + 7;
			}
		}
	}
	
	class BottomLine extends UiElementBase {
		private var caloriesGoal;
		private var application;
		
		private var line;		
		private var lineFill;
		private var dot;
		
		private var maxAngle = 124;
		private var radius = 109.5;
		private var centerAngle = 152;
		private var maxRectangleWidth = 196;
		private var rectangleLocX = 32;
		private var rectangleLocY = 208;
		private var rectangleHeight = 51;
		
		private var lastX;
		private var lastY;

		function initialize(dc, application) {
			UiElementBase.initialize(dc);
			
			self.application = application;
		
			line = new Textures.Bitmap("Line-Bottom", dc);
        	lineFill = new Textures.Bitmap("Line-Bottom", dc);
        	dot = new Textures.Icon("Dot", dc);

        	lineFill.setColor(Graphics.Graphics.COLOR_TRANSPARENT);
        	lineFill.setBackgroundColor(Graphics.COLOR_BLACK);
        	
        	line.setColor(Graphics.COLOR_DK_GRAY);
			
			line.setPosition(130, 208);
        	lineFill.setPosition(130, 208);
        	
        	caloriesGoal = application.getProperty("ActiveCaloriesGoal");
		}

		function draw(activityMonitorInfo) {
			var leftValue = Utils.getActiveCalories(activityMonitorInfo.calories);
			var rightValue = caloriesGoal;
			
			var percentage = leftValue >= rightValue ? 1.0 : leftValue / rightValue.toFloat();
			var targetPosition = maxAngle * percentage;
			
			var pointOnCircle = Utils.getPointOnCircle(dc.getWidth() / 2, dc.getHeight() / 2, radius, -1 * targetPosition, centerAngle);
			
			line.draw();
			
			Utils.drawRectangleStartingFromLeft(dc, rectangleLocX, rectangleLocY, pointOnCircle[0] - rectangleLocX, rectangleHeight, Graphics.COLOR_RED);
			
			lineFill.draw();

			if(pointOnCircle[0] >= 89 && pointOnCircle[0] <= 170) {
				pointOnCircle[1] = 231;
			}
			if(pointOnCircle[1] != 231) {
				if(lastX != pointOnCircle[0] && lastY != pointOnCircle[1]) {
					dot.setPosition(pointOnCircle[0], pointOnCircle[1]);
					
					lastX = pointOnCircle[0];
					lastY = pointOnCircle[1];
				}
			} else {
				dot.setPosition(pointOnCircle[0], pointOnCircle[1]);
					
				lastX = pointOnCircle[0];
				lastY = pointOnCircle[1];
			}
			dot.draw();
		}
		
		function onSettingUpdate() {
	    	caloriesGoal = application.getProperty("ActiveCaloriesGoal");
	    }
	}
}

module Textures {
	var iconsFont;
	var bitmapsFont;
	
	var icons = {
		"Battery-100"    => "B",
		"Battery-90"     => "A",
		"Battery-80"     => "9",
		"Battery-70"     => "8",
		"Battery-60"     => "7",
		"Battery-50"     => "6",
		"Battery-40"     => "5",
		"Battery-30"     => "4",
		"Battery-20"     => "3",
		"Battery-10"     => "2",
		"Battery-5"      => "1",
		"Battery-0"      => "0",
		"Notification"   => "C",
		"Alarm"          => "D",
		"Move-1"         => "E",
		"Move-5"         => "F",
		"Dnd"            => "G",
		"Bluetooth"      => "H",
		"Arrow-Up"       => "I",
		"MoveBar-1"      => "J",
		"MoveBar-2"      => "K",
		"Move-0"         => "L",
		"Sleep"          => "M",
		"Heart-1"        => "N",
		"Heart-2"        => "O",
		"Steps-Side"     => "P",
		"Distance"       => "Q",
		"Calories"       => "R",
		"Stopwatch"      => "S",
		"Stairs-Up"      => "T",
		"Trophy"         => "U",
		"Arrow-Left"     => "V",
		"Arrow-Right"    => "X",
		"Battery-100-L"  => "j",
		"Battery-90-L"   => "i",
		"Battery-80-L"   => "h",
		"Battery-70-L"   => "g",
		"Battery-60-L"   => "f",
		"Battery-50-L"   => "e",
		"Battery-40-L"   => "d",
		"Battery-30-L"   => "c",
		"Battery-20-L"   => "b",
		"Battery-10-L"   => "a",
		"Battery-5-L"    => "Z",
		"Battery-0-L"    => "Y",
		"Elevation"      => "k",
		"Calendar"       => "l",
		"Moon-0"         => "m", // New Moon
		"Moon-1"         => "n", // Waxing Crescent
		"Moon-2"         => "o", // First Quarter
		"Moon-3"         => "p", // Waxing Gibbous
		"Moon-4"         => "q", // Full Moon
		"Moon-5"         => "r", // Waning Gibbous
		"Moon-6"         => "s", // Third Quarter
		"Moon-7"         => "t", // Waning Crescent
		"Alarm-L"        => "u",
		"Notification-L" => "#",
		"Dnd-L"          => "$",
		"Bluetooth-L"    => "%",
		"Move-1-L"       => "(",
		"Move-5-L"       => "&",
		"Move-0-L"       => ")",
		"Sleep-L"        => "*",
		"Dot"            => "+",
		"Dot-L"          => ",",
	};
	
	var bitmaps = {
		"Line-Top"    => "012345",
		"Line-Bottom" => "6789AB",
		"Line-Right"  => "C",
		"Line-Left"   => "G"
	};
	
	function init() {
		iconsFont = WatchUi.loadResource(Rez.Fonts.Icons);
		bitmapsFont = WatchUi.loadResource(Rez.Fonts.Bitmaps);
	}
	
	class Texture {
		var text;
		
		protected var name;
		protected var dimensions;
		protected var dc;
		protected var char;
		
		private var color;
		private var backgroundColor;

		function initialize(dc) {
        	text.setJustification(Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
        	
        	setColor(Graphics.COLOR_WHITE);
        	setBackgroundColor(Graphics.COLOR_TRANSPARENT);
        	
        	self.dc = dc;
        	
        	return self;
		}
		
		function setColor(color) {
			if(color != self.color) {
				self.color = color;
				
				text.setColor(color);
			}
			return text;
		}
		
		function setBackgroundColor(color) {
			if(color != self.color) {
				backgroundColor = color;
				
				text.setBackgroundColor(color);
			}
			return text;
		}

		function setPosition(x, y) {
			text.locX = x;
			text.locY = y;
			
			return text;
		}
		
		function getName() {
			return name;
		}
		
		function getDimensions() {
			return dimensions;
		}
		
		function draw() {
			text.draw(dc);
		}
	}

	class Icon extends Texture {
		function initialize(name, dc) {
			text = new WatchUi.Text({
	            :font  => iconsFont,
	            :locX  => 0,
	            :locY  => 0
        	});
        	Textures.Texture.initialize(dc);

        	setIcon(name);

        	return self;
		}
		
		function setIcon(name) {
			if(name != self.name) {
				self.name = name;
				char = Textures.icons[name];
				
				text.setText(char);
				dimensions = dc.getTextDimensions(char, iconsFont);
			}
			return text;
		}
	}
	
	class Bitmap extends Texture {
		function initialize(name, dc) {
			text = new WatchUi.Text({
	            :font  => bitmapsFont,
	            :locX  => 0,
	            :locY  => 0
        	});
        	Textures.Texture.initialize(dc);

        	setBitmap(name);
        	
        	return self;
		}

		function setBitmap(name) {
			if(name != self.name) {
				self.name = name;
				char = Textures.bitmaps[name];
				
				text.setText(char);
				dimensions = dc.getTextDimensions(char, bitmapsFont);
			}
			return text;
		}
	}
}

module Extensions {
	class Text extends WatchUi.Text {
		private var text;
		private var color;
		private var dc;
		private var typeface;
		
		function initialize(settings, dc, centerJustification) {
			WatchUi.Text.initialize(settings);
			
			self.dc = dc;
			
			var typeface = settings.get(:typeface);
			var text = settings.get(:text);
			var color = settings.get(:color);

			self.setFont(typeface);
			
			if(text != null) {
				self.setText(text);
			}
			if(color != null) {
				self.setColor(color);
			}
			if(centerJustification) {
				WatchUi.Text.setJustification(Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
			}
			return self;
		}
		
		function setText(text) {
			if(text != self.text) {
				WatchUi.Text.setText(text);
				
				self.text = text;
			}
			return self;
		}
		
		function setFont(font) {
			if(font != typeface) {
				WatchUi.Text.setFont(font);
				
				typeface = font;
			}
			return self;
		}
		
		function setColor(color) {
			if(color != self.color) {
				WatchUi.Text.setColor(color);
				
				self.color = color;
			}
			return self;
		}
		
		function getFont() {
			return typeface;
		}
		
		function getColor() {
			return color;
		}
		
		function getText() {
			return text;
		}
		
		function getTextLength() {
			return text.length();
		}
		
		function getDimensions() {
			return dc.getTextDimensions(text, typeface);
		}
	}
}

// TODO: All heart rate related functions need to be checked if they have heart rate monitor
module Utils {
	var moonPhases = { 
		0  => { "name" => "New Moon",             "angle" => 0,   "icon" => "Moon-0" },
		1  => { "name" => "Waxing Crescent Moon", "angle" => 45,  "icon" => "Moon-1" },
		2  => { "name" => "First Quarter Moon",   "angle" => 90,  "icon" => "Moon-2" },
		3  => { "name" => "Waxing Gibbous Moon",  "angle" => 135, "icon" => "Moon-3" },
		4  => { "name" => "Full Moon",            "angle" => 180, "icon" => "Moon-4" },
		5  => { "name" => "Waning Gibbous Moon",  "angle" => 225, "icon" => "Moon-5" },
		6  => { "name" => "Third Quarter Moon",   "angle" => 270, "icon" => "Moon-6" },
		7  => { "name" => "Waning Crescent Moon", "angle" => 315, "icon" => "Moon-7" }
	};
	
	function getDayWithMondayStarting(daySundayStarting) {
    	if(daySundayStarting != 1) {
    		return daySundayStarting - 1;
    	}
    	return 7; // Sunday
    }
    
    function getCurrentWeekNumber() {
		var today = new Time.Moment(Time.today().value() + System.getClockTime().timeZoneOffset);

		var options = {
		    :year   => Gregorian.info(today, Time.FORMAT_SHORT).year,
		    :month  => 1,
		    :day    => 1,
		    :hour   => 0,
		    :min    => 0,
		    :sec    => 0
		};
		var firstDayOfYear = Gregorian.moment(options);

		return Math.ceil((today.subtract(firstDayOfYear).add(new Time.Duration(Gregorian.SECONDS_PER_DAY * getDayWithMondayStarting(Gregorian.info(firstDayOfYear, Time.FORMAT_SHORT).day_of_week))).value() / 86400).toFloat() / 7).toNumber();
    }
    
    function kFormatter(num, precision) {
    	if(num != null) {
	    	var formatted = (num / 1000.0).format("%." + precision + "f");
	    	var rounded = Math.round(num / 1000.0);
			var isWholeNumber = formatted.toFloat() - rounded == 0;
	
	    	return num > 999 ? (!isWholeNumber ? formatted : rounded.format("%d")) + "k" : Math.round(num).toNumber() + "";
    	}
    	return "0";
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
	
	function getCurrentElevation() {
		if((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getElevationHistory)) {
        	return Toybox.SensorHistory.getElevationHistory({}).next().data;
	    }
	    return null;
	}
	
	function getPointOnCircle(cx, cy, radius, angle, startAngleOffset) {
		var x = Math.round(cx + radius * Math.cos(Math.toRadians(angle + startAngleOffset)));
   	 	var y = Math.round(cy + radius * Math.sin(Math.toRadians(angle + startAngleOffset)));
   	 	
   	 	return [ x, y ];
	}
	
	function getCurrentMoonPhase() {
		var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
		
		var year = now.year;
		var month = now.month;
		var day = now.day;

	    if(month < 3) {
	        year--;
	        month += 12;
	    }
	    ++month;
	
	    var julian = ((365.25 * year) + (30.6 * month) + day - 694039.09) / 29.5305882;
	    var result = julian.toNumber();
	
	    julian -= result;
	    result = Math.round(julian * 8).toNumber();
		result = result >= 8 ? 0 : result;

	    return moonPhases[result];
	}
	
	function getMoonPhaseForDate(year, month, day) {
	    if(month < 3) {
	        year--;
	        month += 12;
	    }
	    ++month;
	
	    var julian = ((365.25 * year) + (30.6 * month) + day - 694039.09) / 29.5305882;
	    var result = julian.toNumber();
	
	    julian -= result;
	    result = Math.round(julian * 8).toNumber();
		result = result >= 8 ? 0 : result;

	    return moonPhases[result];
	}
	
	function getTimeByOffset(application) {
		var offset = application.getProperty("AlternativeTimezone");
		var time = new Time.Moment(Time.now().value() + offset * 3600);
		
		var info = Gregorian.utcInfo(time, Time.FORMAT_SHORT);

		return Lang.format("$1$:$2$ (GMT$3$$4$)", [ info.hour.format(application.getProperty("AddLeadingZero") ? "%02d" : "%d"), info.min.format("%02d"), offset >= 0 ? "+" : "-", offset.abs() ]);
	}
	
	function drawLine(dc, x, y, width, height, color) {
		dc.setColor(color, Graphics.COLOR_TRANSPARENT);

		dc.fillRectangle((x - width / 2).abs(), (y - height / 2).abs(), width, height);
	}
	
	function drawRectangleStartingFromLeft(dc, x, y, width, height, color) {
		dc.setColor(color, Graphics.COLOR_TRANSPARENT);

		dc.fillRectangle(x, (y - height / 2).abs(), width, height);
	}
	
	function drawRectangleStartingFromMiddle(dc, x, y, width, height, color) {
		dc.setColor(color, Graphics.COLOR_TRANSPARENT);

		dc.fillRectangle((x - width / 2).abs(), (y - height / 2).abs(), width, height);
	}
	
	function getActiveCalories(calories) {
		var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);		
		var profile = UserProfile.getProfile();
		var age = today.year - profile.birthYear;
		var weight = profile.weight / 1000.0;
		var restCalories = (profile.gender == UserProfile.GENDER_MALE ? 5.2 : -197.6) - 6.116 * age + 7.628 * profile.height + 12.2 * weight;

		restCalories = Math.round((today.hour * 60 + today.min) / 1440.0 * restCalories).toNumber();
		
		return calories > restCalories ? calories - restCalories : 0;
	}
}