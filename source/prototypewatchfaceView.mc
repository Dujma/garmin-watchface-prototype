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
    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        MainController.onLayout(dc);
    }

    function onUpdate(dc) {
    	MainController.onUpdate();
    }
    
    function onShow() {
		MainController.onShow();
    }

    function onHide() {
    	MainController.onHide();
    }

    function onExitSleep() {
    	MainController.onExitSleep();
    }

    function onEnterSleep() {
    	MainController.onEnterSleep();
    }
}

module MainController {
	// Watch Properties
	var environmentInfo;
	
	// Device Context
	var dc;
	
	var mockBackground;
	
	// UiElements
	var clockArea;
	var topIcons;
	var bottomIcons;
	var top;
	var bottom;
	var right;
	var left;
	var topIconsPowerSaving;
	var bottomIconsPowerSaving;
	var bottomLine;
	
	// Settings
	var powerSavingMode;
	var displayIconsOnPowerSavingMode;
	var oldDndState;
	var isSleep = false;
	
	function onLayout(dc) {
		self.dc = dc;
		
		environmentInfo = new Environment.Info();
		
		updateEnvironmentInfo();
		
		oldDndState = environmentInfo.doNotDisturb;
		
        Textures.init();
        
        mockBackground = new WatchUi.Bitmap({
        	:rezId => Rez.Drawables.MockBackground,
        	:locX  => 0,
        	:locY  => 0
    	});
    	powerSavingMode = Application.getApp().getProperty("PowerSavingMode");
    	displayIconsOnPowerSavingMode = Application.getApp().getProperty("DisplayIconsOnPowerSavingMode");

    	clockArea = new UiElements.ClockArea(WatchUi.loadResource(Rez.Fonts.Gobold14));

    	initElements();
    }

    function onUpdate() {
    	updateEnvironmentInfo();
    	
    	if(environmentInfo.doNotDisturb != oldDndState) {
			onDndChanged(environmentInfo.doNotDisturb);
			
			oldDndState = environmentInfo.doNotDisturb;
    	}
    	drawBackground();

   	 	var isPowerSavingModeActive = isPowerSavingModeActive();
   	 	
   	 	checkForInit();
   	 	
   	 	if(!isPowerSavingModeActive) {
   	 		bottomLine.draw();
   	 		mockBackground.draw(dc);
   	 	}
		clockArea.draw();

		if(!isPowerSavingModeActive) {
			topIcons.draw();
			bottomIcons.draw();
			top.draw();
			bottom.draw();
			right.draw();
			left.draw();
		} else {
			if(displayIconsOnPowerSavingMode) {
				topIconsPowerSaving.draw();
				bottomIconsPowerSaving.draw();
			}
		}
    }

    function onShow() {
		
    }

    function onHide() {
    
    }

    function onExitSleep() {
    	isSleep = false;
    	
    	if(!isPowerSavingModeActive()) {
	    	clockArea.onExitSleep();
	    	left.onExitSleep();
    	}
    }

    function onEnterSleep() {
    	isSleep = true;
    	
	    if(!isPowerSavingModeActive()) {
	    	clockArea.onEnterSleep();
	    	left.onEnterSleep();
	    }
    }
    
    function onDndChanged(newState) {
    	clockArea.onDndChanged();
    }
    
    function checkForInit() {
    	if(!isPowerSavingModeActive()) {
    		if(topIcons == null) {
    			mainElementsInit();
    		}
    	} else {
    		if(topIconsPowerSaving == null) {
    			powerSavingModeElementsInit();
    		}
    	}
    }
    
    function initElements() {
    	if(!isPowerSavingModeActive()) {
    		mainElementsInit();
    	} else {
    		powerSavingModeElementsInit();
    	}
    }
    
    function mainElementsInit() {
    	var fntGobold13Shrinked = WatchUi.loadResource(Rez.Fonts.Gobold13Shrinked);
    	var fntRobotoBold12 = WatchUi.loadResource(Rez.Fonts.RobotoBold12);
    	var fntGobold13 = WatchUi.loadResource(Rez.Fonts.Gobold13);
    	var fntGobold13Rotated1 = WatchUi.loadResource(Rez.Fonts.Gobold13Rotated1);
    	var fntGobold13Rotated2 = WatchUi.loadResource(Rez.Fonts.Gobold13Rotated2);
    	
        topIcons = new UiElements.TopIcons(fntGobold13Shrinked);
        bottomIcons = new UiElements.BottomIcons();
        top = new UiElements.Top(fntRobotoBold12, fntGobold13);
        bottom = new UiElements.Bottom(fntGobold13);
        right = new UiElements.Right(fntGobold13Shrinked);
        left = new UiElements.Left(fntGobold13Shrinked, WatchUi.loadResource(Rez.Fonts.RobotoCondensedBold12));
        bottomLine = new UiElements.BottomLine(fntGobold13Rotated1, fntGobold13Rotated2, fntGobold13);
        
        topIconsPowerSaving = null;
        bottomIconsPowerSaving = null;
    }
    
    function powerSavingModeElementsInit() {
    	var fntGobold13 = WatchUi.loadResource(Rez.Fonts.Gobold13);
    
     	topIconsPowerSaving = new UiElements.TopIconsLarge(fntGobold13);
        bottomIconsPowerSaving = new UiElements.BottomIconsLarge();
        
        topIcons = null;
        bottomIcons = null;
        top = null;
        bottom = null;
        right = null;
        left = null;
        bottomLine = null;
    }
    
    function handleSettingUpdate() {
    	powerSavingMode = Application.getApp().getProperty("PowerSavingMode");
    	displayIconsOnPowerSavingMode = Application.getApp().getProperty("DisplayIconsOnPowerSavingMode");
    	
    	initElements();
    
    	clockArea.onSettingUpdate();
    	
    	if(!isPowerSavingModeActive()) {
    		top.onSettingUpdate();
    		bottomLine.onSettingUpdate();
    	}
    }
    
    function updateEnvironmentInfo() {
   	 	environmentInfo.setValues(System.getDeviceSettings(), System.getSystemStats(), UserProfile.getProfile(), ActivityMonitor.getInfo());
    }
    
    function isPowerSavingModeActive() {
    	return powerSavingMode == 1 || (powerSavingMode == 2 && environmentInfo.doNotDisturb);
    }
    
    function drawBackground() {
    	dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
    }
}

module UiElements {
	class ClockArea {
		private var hoursText;
		private var hoursFormat;
		private var minutesText;
		private var minutesColon;
		private var secondsText;
		private var dateText;
		private var partOfDayText;
		private var clockElements;
		private var displaySeconds;
		private var wereSecondsDisplayed;

	    function initialize(fntGobold14) {
			clockElements = new [0];

			var fntGoboldBold78 = WatchUi.loadResource(Rez.Fonts.GoboldBold78);
	        var fntGoboldBold55 = WatchUi.loadResource(Rez.Fonts.GoboldBold55);
	        var fntGobold18 = WatchUi.loadResource(Rez.Fonts.Gobold18);

			hoursText = clockElements.add(new Extensions.Text({
			    :text => "00",
	            :color         => Graphics.COLOR_WHITE,
	            :typeface      => fntGoboldBold78,
	            :locX          => 88 + (MainController.dc.getTextWidthInPixels("00", fntGoboldBold78) / 2),
	            :locY          => 129,
	            :justification => Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_RIGHT
	        }, false))[clockElements.size() - 1];
	        minutesText = clockElements.add(new Extensions.Text({
	            :color    => Graphics.COLOR_LT_GRAY,
	            :typeface => fntGoboldBold55,
	            :locX     => 177,
	            :locY     => 121
	        }, true))[clockElements.size() - 1];
	        minutesColon = clockElements.add(new Extensions.Text({
	            :color    => Graphics.COLOR_LT_GRAY,
	            :typeface => fntGoboldBold55,
	            :locX     => 137,
	            :locY     => 121
	        }, true))[clockElements.size() - 1];
	        dateText = clockElements.add(new Extensions.Text({
	            :color    => Graphics.COLOR_WHITE,
	            :typeface => fntGobold18,
	            :locX     => 177,
	            :locY     => 151
	        }, true))[clockElements.size() - 1];
	        partOfDayText = clockElements.add(new Extensions.Text({
	            :color    => Graphics.COLOR_WHITE,
	            :typeface => fntGobold14,
	            :locX     => 44,
	            :locY     => 152
	        }, true))[clockElements.size() - 1];
	        secondsText = new Extensions.Text({
	        	:text     => "00",
	        	:typeface => fntGobold14,
	            :color    => Graphics.COLOR_LT_GRAY,
	            :locX     => 213,
	            :locY     => 106
	        }, true);

	        hoursFormat = Application.getApp().getProperty("AddLeadingZero") ? "%02d" : "%d";
	        displaySeconds = Application.getApp().getProperty("DisplaySeconds");
	        
	        var shouldDisplaySeconds = shouldDisplaySeconds();

	        if(!shouldDisplaySeconds) {
	        	setClockPosition();
	        } else {
	        	wereSecondsDisplayed = shouldDisplaySeconds;
	        }
	    }
	
	    function draw() {
	    	var now = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
	    	var hours = now.hour;

		    partOfDayText.setText(hours > 12 ? "P" : "A");
		    
		    if(!MainController.environmentInfo.is24Hour) {
				hours -= hours > 12 ? 12 : 0;
			}
			hoursText.setText(hours.format(hoursFormat));
			minutesText.setText(now.min.format("%02d"));
			minutesColon.setText(":");
			dateText.setText(now.day.format("%02d") + " " + now.month.toUpper());
			
			hoursText.draw();
			minutesText.draw();
			minutesColon.draw();
			dateText.draw();
			partOfDayText.draw();

			if(shouldDisplaySeconds()) {
				secondsText.setText(now.sec.format("%02d"));
				secondsText.draw();
			}
			Utils.drawLine(130, 96, 185, 3, Graphics.COLOR_RED);
			Utils.drawLine(130, 162, 185, 3, Graphics.COLOR_RED);
	    }

	    function onSettingUpdate() {
	    	hoursFormat = Application.getApp().getProperty("AddLeadingZero") ? "%02d" : "%d";
	    	displaySeconds = Application.getApp().getProperty("DisplaySeconds");
	    	
	    	setClockPosition();
	    }
	    
	    function onEnterSleep() {
	    	secondsText.setColor(Graphics.COLOR_TRANSPARENT);
	    }
	    
	    function onExitSleep() {
	    	secondsText.setColor(Graphics.COLOR_LT_GRAY);
	    	
	    	setClockPosition();
	    }
	    
	    function onDndChanged() {
	    	setClockPosition();
	    }
	    
	    function setClockPosition() {
	    	var shouldDisplaySeconds = shouldDisplaySeconds();

	    	if(shouldDisplaySeconds != wereSecondsDisplayed) {
	    		if(shouldDisplaySeconds) {
		    		for(var i = 0; i < clockElements.size(); ++i) {
			    		clockElements[i].locX -= secondsText.getDimensions()[0] / 2;
			    	}
	    		} else {
	    			for(var i = 0; i < clockElements.size(); ++i) {
			    		clockElements[i].locX += secondsText.getDimensions()[0] / 2;
			    	}
	    		}
		    	wereSecondsDisplayed = shouldDisplaySeconds;
	    	}
	    }
	    
	    function shouldDisplaySeconds() {
	    	if(!MainController.isPowerSavingModeActive()) {
	    		if(displaySeconds == 2) {
	    			return false;
	    		}
	    		return (displaySeconds == 0 && !MainController.isSleep) || displaySeconds == 1;
	    	}
	    	return false;
	    }
	}
	
	class TopIconsBase {
		protected var batteryText;
		protected var batteryIcon;
		protected var notificationIcon;
		protected var alarmIcon;
		protected var batteryRectX;
		protected var batteryRectY;
		protected var batteryRectWidth;
		protected var batteryRectHeight;
		
		function draw() {
			var batteryLvl = Math.round(MainController.environmentInfo.battery);

			batteryText.setText(Lang.format("$1$%", [ (batteryLvl + 0.5).format( "%d" ) ]));
			batteryText.draw();

			var color = Graphics.COLOR_WHITE;
			
			if(!MainController.environmentInfo.charging) { // 3.0.0
				if(batteryLvl <= 20) {
					color = Graphics.COLOR_RED;
				}
			} else {
				if(batteryLvl < 99.5) {
					color = Graphics.COLOR_BLUE;
				} else {
					color = Graphics.COLOR_GREEN;
				}
			}
			batteryIcon.setColor(color);
			setBatteryLevel(batteryLvl, color);
			
			notificationIcon.setColor(MainController.environmentInfo.notificationCount > 0 ? Graphics.COLOR_RED : Graphics.COLOR_WHITE);
			alarmIcon.setColor(MainController.environmentInfo.alarmCount > 0 ? Graphics.COLOR_RED : Graphics.COLOR_WHITE);

			batteryIcon.draw();
			notificationIcon.draw();
			alarmIcon.draw();
		}
		
		function setBatteryLevel(lvl, color) {
			Utils.drawRectangleStartingFromLeft(batteryRectX, batteryRectY, Math.ceil(lvl / 100.0 * batteryRectWidth), batteryRectHeight, color);
		}
	}
	
	class TopIcons extends TopIconsBase {
		function initialize(fntGobold13Shrinked) {
			batteryIcon = new Textures.Icon('B');
			batteryIcon.setPosition(130, 19);
			
			batteryText = new Extensions.Text({
	            :color    => Graphics.COLOR_WHITE,
	            :typeface => fntGobold13Shrinked,
	            :locX     => 130,
	            :locY     => 7
	        }, true);
	        
			notificationIcon = new Textures.Icon('C');
			notificationIcon.setPosition(154, 16);
			
			alarmIcon = new Textures.Icon('D');
			alarmIcon.setPosition(104, 15);

			batteryRectWidth = 14;
			batteryRectHeight = 4;
			batteryRectX = 129 - batteryRectWidth / 2;
			batteryRectY = 20;
		}
		
		function draw() {
			TopIconsBase.draw();
		}
	}
	
	class TopIconsLarge extends TopIconsBase {
		function initialize(fntGobold13) {
			batteryIcon = new Textures.Icon('A');
			batteryIcon.setPosition(130, 50);
			
			batteryText = new Extensions.Text({
	            :color    => Graphics.COLOR_WHITE,
	            :typeface => fntGobold13,
	            :locX     => 130,
	            :locY     => 33
	        }, true);

			notificationIcon = new Textures.Icon('Z');
			notificationIcon.setPosition(180, 55);
			
			alarmIcon = new Textures.Icon('Y');
			alarmIcon.setPosition(80, 55);

			batteryRectWidth = 19;
			batteryRectHeight = 6;
			batteryRectX = 129 - batteryRectWidth / 2;
			batteryRectY = 51;
		}
		
		function draw() {
			TopIconsBase.draw();
		}
	}
	
	class BottomIconsBase {
		protected var moveIcon;
		protected var dndIcon;
		protected var btIcon;

		function draw(isLarge) {
			var moveBarLevel = MainController.environmentInfo.moveBarLevel;

			dndIcon.setColor(MainController.environmentInfo.doNotDisturb ? Graphics.COLOR_RED : Graphics.COLOR_WHITE); // 2.1.0
			btIcon.setColor(MainController.environmentInfo.phoneConnected ? Graphics.COLOR_RED : Graphics.COLOR_WHITE);
			setMoveIcon(moveBarLevel, isLarge);
			
			moveIcon.draw();
			dndIcon.draw();
			btIcon.draw();
		}
		
		function setMoveIcon(lvl, isLarge) {
			var targetIcon = null;
			var isInSleeptTime = isInSleepTime();
			
			if(!isInSleeptTime) {
				if(lvl == 0) {
					targetIcon = isLarge ? 'e' : 'L';
				} else if(lvl > 0 && lvl < 3) {
					targetIcon = isLarge ? 'd' : 'E';
				} else {
					targetIcon = isLarge ? 'c' : 'F';
				}
			} else {
				targetIcon = isLarge ? 'f' : 'M';
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
		
		function isInSleepTime() {
	        var today = Time.today().value();
	        
	        var sleepTime = new Time.Moment(today + MainController.environmentInfo.sleepTime);
	        var now = new Time.Moment(Time.now().value());
	        
	        if(now.value() >= sleepTime.value()) {
	       		return true;
	        } else {
	         	var wakeTime = new Time.Moment(today + MainController.environmentInfo.wakeTime);
	         	
	        	if(now.value() <= wakeTime.value()) {
	        		return true;
	        	} else {
	        		return false;
	        	}
	        }
    	}
	}
	
	class BottomIcons extends BottomIconsBase {
		function initialize() {
			BottomIconsBase.initialize();
			
			moveIcon = new Textures.Icon('E');
			moveIcon.setPosition(104, 243);
			
			dndIcon = new Textures.Icon('G');
			dndIcon.setPosition(130, 247);
			
			btIcon = new Textures.Icon('H');
			btIcon.setPosition(155, 244);
		}
		
		function draw() {
			BottomIconsBase.draw(false);
		}
	}
	
	class BottomIconsLarge extends BottomIconsBase {
		function initialize() {
			BottomIconsBase.initialize();
			
			moveIcon = new Textures.Icon('d');
			moveIcon.setPosition(80, 205);
			
			dndIcon = new Textures.Icon('a');
			dndIcon.setPosition(130, 215);
			
			btIcon = new Textures.Icon('b');
			btIcon.setPosition(180, 205);
		}
		
		function draw() {
			BottomIconsBase.draw(true);
		}
	}

	class Top {
		private var daysText;
		private var arrowIcon;
		private var daysInitialY = 88;
		private var daysYOffset = 3;
		private var dayNames = [ "SU", "MO", "TU", "WE", "TH", "FR", "SA" ];
		private var infoText;
		private var iconLeft;
		private var iconMiddle;
		private var iconRight;
		private var iconTextLeft;
		private var iconTextMiddle;
		private var iconTextRight;

		function initialize(fntRobotoBold12, fntGobold13) {
			arrowIcon = new Textures.Icon('I');
			arrowIcon.setColor(Graphics.COLOR_RED);
			arrowIcon.setPosition(56, 93);
			
			iconLeft = new Textures.Icon('X');
			iconLeft.setColor(Graphics.COLOR_WHITE);
			iconLeft.setPosition(94, 66);
			
			iconMiddle = new Textures.Icon('O');
			iconMiddle.setColor(Graphics.COLOR_WHITE);
			iconMiddle.setPosition(143, 66);
			
			iconRight = new Textures.Icon('9');
			iconRight.setColor(Graphics.COLOR_WHITE);
			iconRight.setPosition(193, 66);
			
			iconTextLeft = new Extensions.Text({
	            :color         => Graphics.COLOR_WHITE,
	            :typeface      => fntGobold13,
	            :locX          => 83,
	            :locY          => 60,
	            :justification => Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_RIGHT
        	}, false);
        	
        	iconTextMiddle = new Extensions.Text({
	            :color         => Graphics.COLOR_WHITE,
	            :typeface      => fntGobold13,
	            :locX          => 136,
	            :locY          => 60,
	            :justification => Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_RIGHT
        	}, false);
        	
        	iconTextRight = new Extensions.Text({
	            :color         => Graphics.COLOR_WHITE,
	            :typeface      => fntGobold13,
	            :locX          => 182,
	            :locY          => 60,
	            :justification => Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_RIGHT
        	}, false);

			daysText = new [7];

			for(var i = 0; i < daysText.size(); ++i) {
				daysText[i] = new Extensions.Text({
					:text     => dayNames[i],
		            :color    => Graphics.COLOR_WHITE,
		            :typeface => fntRobotoBold12,
		            :locY     => daysInitialY
	        	}, true);
			}
			orderDaysOfWeek(Application.getApp().getProperty("FirstDayOfWeek"));
			
			infoText = new Extensions.Text({
	            :color    => Graphics.COLOR_WHITE,
	            :typeface => fntRobotoBold12,
	            :locX     => 130,
	            :locY     => 41
        	}, true);
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
				daysText[i].draw();
				arrowIcon.draw();
			}
			// infoText.setText("Week " + Utils.getCurrentWeekNumber());
			infoText.setText(Utils.getTimeByOffset());
			infoText.draw();
			
			// TODO: Store this and update it only once a day
			var currentMoonPhase = Utils.getCurrentMoonPhase();
			
			iconTextLeft.setText(Utils.getCurrentWeekNumber().toString());
			iconTextMiddle.setText(currentMoonPhase['a'] + "°");
			iconTextRight.setText(Utils.kFormatter(Utils.getCurrentElevation(), 1));
			
			iconMiddle.setIcon(currentMoonPhase['i']);
			
			iconLeft.draw();
			iconMiddle.draw();
			iconRight.draw();
			
			iconTextLeft.draw();
			iconTextMiddle.draw();
			iconTextRight.draw();
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
	    	orderDaysOfWeek(Application.getApp().getProperty("FirstDayOfWeek"));
	    }
	}
	
	class Bottom {
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

		function initialize(fntGobold13) {
    		moveBarLvl1 = new Textures.Icon('J');
    		moveBarLvl1.setPosition(101, 219);
    		
    		moveBarOtherLvls = new [4];
    		
    		for(var i = 0; i < moveBarOtherLvls.size(); ++i) {
    			moveBarOtherLvls[i] = new Textures.Icon('K');
    			moveBarOtherLvls[i].setPosition(120 + (i * 14), 219);
    		}
    		icon1 = new Textures.Icon('2');
    		icon2 = new Textures.Icon('3');
    		icon3 = new Textures.Icon('4');
    		icon4 = new Textures.Icon('5');
    		
    		icon1.setColor(Graphics.COLOR_RED);
    		icon2.setColor(Graphics.COLOR_RED);
    		icon3.setColor(Graphics.COLOR_RED);
    		icon4.setColor(Graphics.COLOR_RED);
    		
    		icon1.setPosition(72, 174);
    		icon2.setPosition(110, 183);
    		icon3.setPosition(150, 183);
    		icon4.setPosition(188, 175);
    		
    		textIcon1 = new Extensions.Text({
	            :color    => Graphics.COLOR_WHITE,
	            :typeface => fntGobold13,
	            :locX     => 71,
	            :locY     => 190
        	}, true);
        	textIcon2 = new Extensions.Text({
	            :color    => Graphics.COLOR_WHITE,
	            :typeface => fntGobold13,
	            :locX     => 109,
	            :locY     => 199
        	}, true);
        	textIcon3 = new Extensions.Text({
	            :color    => Graphics.COLOR_WHITE,
	            :typeface => fntGobold13,
	            :locX     => 149,
	            :locY     => 199
        	}, true);
        	textIcon4 = new Extensions.Text({
	            :color    => Graphics.COLOR_WHITE,
	            :typeface => fntGobold13,
	            :locX     => 187,
	            :locY     => 190
        	}, true);
		}
		
		function draw() {
			var moveBarLevel = MainController.environmentInfo.moveBarLevel;

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
			var distance = MainController.environmentInfo.distance != null ? MainController.environmentInfo.distance : 0;
			var calories = MainController.environmentInfo.calories != null ? MainController.environmentInfo.calories : 0;
			var activeMinutesWeek = MainController.environmentInfo.activeMinutesWeek != null ? MainController.environmentInfo.activeMinutesWeek : 0;
			var floorsClimbed = MainController.environmentInfo.floorsClimbed != null ? MainController.environmentInfo.floorsClimbed : 0;
			
			icon1.draw();
			icon2.draw();
			icon3.draw();
			icon4.draw();
			
			textIcon1.setText(Utils.kFormatter(distance * 0.01, 1));
			textIcon2.setText(Utils.kFormatter(calories, 1));
			textIcon3.setText(Utils.kFormatter(activeMinutesWeek, 1));
			textIcon4.setText(Utils.kFormatter(floorsClimbed, 1));
			
			textIcon1.draw();
			textIcon2.draw();
			textIcon3.draw();
			textIcon4.draw();
		}
	}
	
	// TODO: Think about having a base class for right and left
	class Right {
		private var topValueText;
		private var bottomValueText;
		private var icon;
		private var trophyIcon;
		private var initialX = 242;
		private var arrowIcon;
		private var startAngle = 108;
		private var endAngle = 71;
		private var radius = 104;
		private var lineBitmap;
		
		function initialize(fntGobold13Shrinked) {
			topValueText = new Extensions.Text({
	            :color    => Graphics.COLOR_WHITE,
	            :typeface => fntGobold13Shrinked,
	            :locX     => initialX,
	            :locY     => 87
        	}, true);
        	bottomValueText = new Extensions.Text({
	            :color    => Graphics.COLOR_WHITE,
	            :typeface => fntGobold13Shrinked,
	            :locX     => initialX,
	            :locY     => 171
        	}, true);

        	icon = new Textures.Icon('1');
        	icon.setColor(Graphics.COLOR_WHITE);
			icon.setPosition(251, 130);
			
			trophyIcon = new Textures.Icon('6');
			
			trophyIcon.setColor(Graphics.COLOR_YELLOW);
			trophyIcon.setPosition(251, 115);
			
			arrowIcon = new Textures.Icon('8');
			
			arrowIcon.setColor(Graphics.COLOR_RED);
			
			lineBitmap = new Textures.Bitmap('C');
			
			lineBitmap.setPosition(241, 130);
		}
		
		function draw() {
			var topValue = MainController.environmentInfo.stepGoal != null ? MainController.environmentInfo.stepGoal : 0;
			var bottomValue = MainController.environmentInfo.steps != null ? MainController.environmentInfo.steps : 0;

			topValueText.setText(Utils.kFormatter(topValue, topValue > 99999 ? 0 : 1));
			bottomValueText.setText(Utils.kFormatter(bottomValue, bottomValue > 99999 ? 0 : 1));
			
			topValueText.locX = offSetXBasedOnWidth(topValueText.getDimensions()[0]);
			bottomValueText.locX = offSetXBasedOnWidth(bottomValueText.getDimensions()[0]);
			
			topValueText.draw();
			bottomValueText.draw();
			
			if(bottomValue >= topValue) {
				trophyIcon.draw();
			}
			icon.draw();
			
			lineBitmap.draw();
			drawArrow(topValue, bottomValue);
		}
		
		function drawArrow(topValue, bottomValue) {
			var percentage = bottomValue >= topValue ? 1.0 : bottomValue / topValue.toFloat();
			var targetAngle = (endAngle - startAngle) * percentage;
			
			var pointOnCircle = Utils.getPointOnCircle(MainController.dc.getWidth() / 2, MainController.dc.getHeight() / 2, radius, startAngle + targetAngle);
			
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
	
	class Left {
		private var topValueText;
		private var bottomValueText;
		private var icon;
		private var initialX = 18;
		private var arrowIcon;
		private var radius = 104;
		private var startAngle = 252; // Reference to "Right". 180 - 18 = 162
		private var endAngle = 289;
		private var lineBitmap;
		
		// Feature only when heart rate is shown
		var heartRateText;
		var heartFilled;
		
		function initialize(fntGobold13Shrinked, fntRobotoCondensedBold12) {
			heartFilled = true;
			
			topValueText = new Extensions.Text({
	            :color    => Graphics.COLOR_WHITE,
	            :typeface => fntGobold13Shrinked,
	            :locX     => initialX,
	            :locY     => 87
        	}, true);
        	bottomValueText = new Extensions.Text({
	            :color    => Graphics.COLOR_WHITE,
	            :typeface => fntGobold13Shrinked,
	            :locX     => initialX,
	            :locY     => 171
        	}, true);
        	heartRateText = new Extensions.Text({
        		:text     => "--",
	            :color    => Graphics.COLOR_WHITE,
	            :typeface => fntRobotoCondensedBold12,
	            :locX     => 9,
	            :locY     => 118
        	}, true);

        	icon = new Textures.Icon('N');
        	icon.setColor(Graphics.COLOR_RED);
			icon.setPosition(9, 130);
			
			arrowIcon = new Textures.Icon('7');
			
			arrowIcon.setColor(Graphics.COLOR_RED);
			
			lineBitmap = new Textures.Bitmap('G');
			
			lineBitmap.setPosition(19, 130);
		}
		
		function draw() {
			var topValue = Utils.getMaxHeartRate();
			var bottomValue = MainController.environmentInfo.restingHeartRate;

			topValueText.setText(Utils.kFormatter(topValue, topValue > 99999 ? 0 : 1));
			bottomValueText.setText(Utils.kFormatter(bottomValue, bottomValue > 99999 ? 0 : 1));

			topValueText.locX = offSetXBasedOnWidth(topValueText.getDimensions()[0]);
			bottomValueText.locX = offSetXBasedOnWidth(bottomValueText.getDimensions()[0]);

			topValueText.draw();
			bottomValueText.draw();

			icon.draw();
			
			drawHeartRate();
			
			lineBitmap.draw();
			drawArrow(topValue, bottomValue);
		}
		
		function drawHeartRate() {
			if(!MainController.isSleep) {
				var currentHeartRate = Utils.getCurrentHeartRate();
				
				heartRateText.setText(currentHeartRate.toString());

				icon.setIcon(heartFilled ? 'N' : '0');
				
				heartFilled = !heartFilled;
				
				heartRateText.setColor(Graphics.COLOR_WHITE);
			} else {
				icon.setIcon('N');
				heartRateText.setColor(Graphics.COLOR_TRANSPARENT);
			}
			heartRateText.draw();
		}
		
		function drawArrow(topValue, bottomValue) {
			var percentage = bottomValue >= topValue ? 1.0 : bottomValue / topValue.toFloat();
			var targetAngle = (endAngle - startAngle) * percentage;
			
			var pointOnCircle = Utils.getPointOnCircle(MainController.dc.getWidth() / 2, MainController.dc.getHeight() / 2, radius, startAngle + targetAngle);
			
	   	 	var x = pointOnCircle[0];
	   	 	var y = pointOnCircle[1];
	   	 	
	   	 	arrowIcon.setPosition(x, y);
			arrowIcon.draw();
		}
		
		function onEnterSleep() {
			heartFilled = true;
			
			icon.setIcon('N');
			heartRateText.setColor(Graphics.COLOR_TRANSPARENT);
	    }
	    
	    function onExitSleep() {
			heartFilled = false;
			
			icon.setIcon('0');
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
	
	class BottomLine {
		private var caloriesGoal;

		private var line;		
		private var lineFill;
		private var dot;
		private var rectangleLocX = 32;
		private var rectangleLocY = 206;
		private var rectangleHeight = 51;
		private var maxRectangleWidth = 196;
		private var startAngle = 242;
		private var endAngle = 118;
		private var radius = 107.5;
		
		private var fntGobold13Rotated1;
		private var fntGobold13Rotated2;
		private var fntGobold13RotatedBase;

		function initialize(fntGobold13Rotated1, fntGobold13Rotated2, fntGobold13RotatedBase) {
			line = new Textures.Bitmap("6789AB");
        	lineFill = new Textures.Bitmap("6789AB");
        	dot = new Textures.Icon('g');

        	lineFill.setColor(Graphics.Graphics.COLOR_TRANSPARENT);
        	lineFill.setBackgroundColor(Graphics.COLOR_BLACK);
        	
        	line.setColor(Graphics.COLOR_DK_GRAY);
			
			line.setPosition(130, 206);
        	lineFill.setPosition(130, 206);
        	
        	caloriesGoal = Application.getApp().getProperty("ActiveCaloriesGoal");
        	
        	self.fntGobold13Rotated1 = fntGobold13Rotated1;
        	self.fntGobold13Rotated2 = fntGobold13Rotated2;
        	self.fntGobold13RotatedBase = fntGobold13RotatedBase;
		}

		function draw() {
			var leftValue = Utils.getActiveCalories(MainController.environmentInfo.calories);
			var rightValue = caloriesGoal;
			
			var percentage = leftValue >= rightValue ? 1.0 : leftValue / rightValue.toFloat();
			var targetAngle = (endAngle - startAngle) * percentage;

			var pointOnCircle = Utils.getPointOnCircle(MainController.dc.getWidth() / 2, MainController.dc.getHeight() / 2, radius, startAngle + targetAngle);
			
			line.draw();
			
			Utils.drawRectangleStartingFromLeft(rectangleLocX, rectangleLocY, pointOnCircle[0] - rectangleLocX, rectangleHeight, Graphics.COLOR_RED);
			
			lineFill.draw();

			if(pointOnCircle[0] >= 89 && pointOnCircle[0] <= 170) {
				pointOnCircle[1] = 229;
			}
			dot.setPosition(pointOnCircle[0], pointOnCircle[1]);
			dot.draw();
			
			Utils.drawTextOnCircle(-146, 129, fntGobold13Rotated1, fntGobold13RotatedBase, Utils.kFormatter(leftValue, 1), false, Graphics.COLOR_WHITE);
			Utils.drawTextOnCircle(-223, 122, fntGobold13Rotated2, fntGobold13RotatedBase, Utils.kFormatter(rightValue, 1), false, Graphics.COLOR_WHITE);
		}
		
		function onSettingUpdate() {
	    	caloriesGoal = Application.getApp().getProperty("ActiveCaloriesGoal");
	    }
	}
}

module Textures {
	var iconsFont;
	var bitmapsFont;
	
/*
	Icons (new):
		"Battery"        => 'B'
		"Notification"   => 'C'
		"Alarm"          => 'D'
		"Move-1"         => 'E'
		"Move-5"         => 'F'
		"Dnd"            => 'G'
		"Bluetooth"      => 'H'
		"Arrow-Up"       => 'I'
		"MoveBar-1"      => 'J'
		"MoveBar-2"      => 'K'
		"Move-0"         => 'L'
		"Sleep"          => 'M'
		"Heart-1"        => 'N'
		"Heart-2"        => '0'
		"Steps-Side"     => '1'
		"Distance"       => '2'
		"Calories"       => '3'
		"Stopwatch"      => '4'
		"Stairs-Up"      => '5'
		"Trophy"         => '6'
		"Arrow-Left"     => '7'
		"Arrow-Right"    => '8'
		"Battery-L"      => 'A'
		"Elevation"      => '9'
		"Calendar"       => 'X'
		"Moon-0"         => 'O' // New Moon
		"Moon-1"         => 'P' // Waxing Crescent
		"Moon-2"         => 'Q' // First Quarter
		"Moon-3"         => 'R' // Waxing Gibbous
		"Moon-4"         => 'S' // Full Moon
		"Moon-5"         => 'T' // Waning Gibbous
		"Moon-6"         => 'U' // Third Quarter
		"Moon-7"         => 'V' // Waning Crescent
		"Alarm-L"        => 'Y'
		"Notification-L" => 'Z'
		"Dnd-L"          => 'a'
		"Bluetooth-L"    => 'b'
		"Move-1-L"       => 'd'
		"Move-5-L"       => 'c'
		"Move-0-L"       => 'e'
		"Sleep-L"        => 'f'
		"Dot"            => 'g'
		"Dot-L"          => 'h'
		
	Icons:
		"Battery-100"    => 'B'
		"Battery-90"     => 'A'
		"Battery-80"     => '9'
		"Battery-70"     => '8'
		"Battery-60"     => '7'
		"Battery-50"     => '6'
		"Battery-40"     => '5'
		"Battery-30"     => '4'
		"Battery-20"     => '3'
		"Battery-10"     => '2'
		"Battery-5"      => '1'
		"Battery-0"      => '0'
		"Notification"   => 'C'
		"Alarm"          => 'D'
		"Move-1"         => 'E'
		"Move-5"         => 'F'
		"Dnd"            => 'G'
		"Bluetooth"      => 'H'
		"Arrow-Up"       => 'I'
		"MoveBar-1"      => 'J'
		"MoveBar-2"      => 'K'
		"Move-0"         => 'L'
		"Sleep"          => 'M'
		"Heart-1"        => 'N'
		"Heart-2"        => 'O'
		"Steps-Side"     => 'P'
		"Distance"       => 'Q'
		"Calories"       => 'R'
		"Stopwatch"      => 'S'
		"Stairs-Up"      => 'T'
		"Trophy"         => 'U'
		"Arrow-Left"     => 'V'
		"Arrow-Right"    => 'X'
		"Battery-100-L"  => 'j'
		"Battery-90-L"   => 'i'
		"Battery-80-L"   => 'h'
		"Battery-70-L"   => 'g'
		"Battery-60-L"   => 'f'
		"Battery-50-L"   => 'e'
		"Battery-40-L"   => 'd'
		"Battery-30-L"   => 'c'
		"Battery-20-L"   => 'b'
		"Battery-10-L"   => 'a'
		"Battery-5-L"    => 'Z'
		"Battery-0-L"    => 'Y'
		"Elevation"      => 'k'
		"Calendar"       => 'l'
		"Moon-0"         => 'm' // New Moon
		"Moon-1"         => 'n' // Waxing Crescent
		"Moon-2"         => 'o' // First Quarter
		"Moon-3"         => 'p' // Waxing Gibbous
		"Moon-4"         => 'q' // Full Moon
		"Moon-5"         => 'r' // Waning Gibbous
		"Moon-6"         => 's' // Third Quarter
		"Moon-7"         => 't' // Waning Crescent
		"Alarm-L"        => 'u'
		"Notification-L" => '#'
		"Dnd-L"          => '$'
		"Bluetooth-L"    => '%'
		"Move-1-L"       => '('
		"Move-5-L"       => '&'
		"Move-0-L"       => ')'
		"Sleep-L"        => '*'
		"Dot"            => '+'
		"Dot-L"          => ','

	Bitmaps:
		"Line-Top"    => "012345"
		"Line-Bottom" => "6789AB"
		"Line-Right"  => 'C'
		"Line-Left"   => 'G'
*/
	
	function init() {
		iconsFont = WatchUi.loadResource(Rez.Fonts.Icons);
		bitmapsFont = WatchUi.loadResource(Rez.Fonts.Bitmaps);
	}
	
	// TODO: If you need dimensions of the icons than the .fnt file needs to be updated with the correct values
	class Texture {
		var text;

		protected var char;
		private var color;
		private var backgroundColor;

		function initialize() {
        	text.setJustification(Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
        	
        	setColor(Graphics.COLOR_WHITE);
        	setBackgroundColor(Graphics.COLOR_TRANSPARENT);

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
			if(color != self.backgroundColor) {
				text.setBackgroundColor(color);
				
				backgroundColor = color;
			}
			return text;
		}

		function setPosition(x, y) {
			text.locX = x;
			text.locY = y;
			
			return text;
		}
		
		function getChar() {
			return char;
		}
		
		function draw() {
			text.draw(MainController.dc);
		}
	}

	class Icon extends Texture {
		private var dimensions;
		
		function initialize(char) {
			text = new WatchUi.Text({
	            :font => iconsFont,
	            :locX => 0,
	            :locY => 0
        	});
        	Textures.Texture.initialize();

        	setIcon(char);

        	return self;
		}
		
		function setIcon(char) {
			if(char != self.char) {
				self.char = char;
				
				text.setText(char.toString());
				
				dimensions = MainController.dc.getTextDimensions(char.toString(), iconsFont);
			}
			return text;
		}

		function getDimensions() {
			return dimensions;
		}
	}
	
	class Bitmap extends Texture {
		function initialize(char) {
			text = new WatchUi.Text({
	            :font => bitmapsFont,
	            :locX => 0,
	            :locY => 0
        	});
        	Textures.Texture.initialize();

        	setBitmap(char);
        	
        	return self;
		}

		function setBitmap(char) {
			if(char != self.char) {
				self.char = char;

				text.setText(char.toString());
			}
			return text;
		}
	}
}

module Extensions {
	class Text extends WatchUi.Text {
		private var text;
		private var color;
		private var backgroundColor;
		private var typeface;
		
		function initialize(settings, centerJustification) {
			WatchUi.Text.initialize(settings);
			
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
				setJustification(Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
			}
			return self;
		}
		
		function draw() {
			WatchUi.Text.draw(MainController.dc);
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
		
		function setBackgroundColor(color) {
			if(color != self.backgroundColor) {
				WatchUi.Text.setBackgroundColor(color);
				
				backgroundColor = color;
			}
			return text;
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
			if(text != null) {
				return text.length();
			}
			return 0;
		}
		
		function getDimensions() {
			if(text != null) {
				return MainController.dc.getTextDimensions(text, typeface);
			}
			return [ 0, 0 ];
		}
	}
}

module Environment {
	class Info {
		var 
			doNotDisturb,
			is24Hour,
			notificationCount,
			alarmCount,
			phoneConnected,
			battery,
			charging,
			sleepTime,
			wakeTime,
			restingHeartRate,
			birthYear,
			gender,
			weight,
			height,
			moveBarLevel,
			distance,
			calories,
			activeMinutesWeek,
			floorsClimbed,
			stepGoal,
			steps;
			
		function initialize() {
			return self;
		}
		
		function setValues(deviceSettings, systemStats, userProfile, activityMonitorInfo) {
			doNotDisturb = deviceSettings.doNotDisturb;
			is24Hour = deviceSettings.is24Hour;
			notificationCount = deviceSettings.notificationCount;
			alarmCount = deviceSettings.alarmCount;
			phoneConnected = deviceSettings.phoneConnected;
			battery = systemStats.battery;
			charging = systemStats.charging;
			sleepTime = userProfile.sleepTime.value();
			wakeTime = userProfile.wakeTime.value();
			restingHeartRate = userProfile.restingHeartRate;
			birthYear = userProfile.birthYear;
			gender = userProfile.gender;
			weight = userProfile.weight;
			height = userProfile.height;
			moveBarLevel = activityMonitorInfo.moveBarLevel;
			distance = activityMonitorInfo.distance;
			calories = activityMonitorInfo.calories;
			activeMinutesWeek = activityMonitorInfo.activeMinutesWeek.total;
			floorsClimbed = activityMonitorInfo.floorsClimbed;
			stepGoal = activityMonitorInfo.stepGoal;
			steps = activityMonitorInfo.steps;
		}
	}
}

// TODO: All heart rate related functions need to be checked if they have heart rate monitor
module Utils {
	var moonPhases = { 
		0  => { 'n' => "New Moon",             'a' => 0,   'i' => 'O' },
		1  => { 'n' => "Waxing Crescent Moon", 'a' => 45,  'i' => 'P' },
		2  => { 'n' => "First Quarter Moon",   'a' => 90,  'i' => 'Q' },
		3  => { 'n' => "Waxing Gibbous Moon",  'a' => 135, 'i' => 'R' },
		4  => { 'n' => "Full Moon",            'a' => 180, 'i' => 'S' },
		5  => { 'n' => "Waning Gibbous Moon",  'a' => 225, 'i' => 'T' },
		6  => { 'n' => "Third Quarter Moon",   'a' => 270, 'i' => 'U' },
		7  => { 'n' => "Waning Crescent Moon", 'a' => 315, 'i' => 'V' }
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
	
	function getTimeByOffset() {
		var offset = Application.getApp().getProperty("AlternativeTimezone");
		var time = new Time.Moment(Time.now().value() + offset * 3600);
		
		var info = Gregorian.utcInfo(time, Time.FORMAT_SHORT);

		return Lang.format("$1$:$2$ (GMT$3$$4$)", [ info.hour.format(Application.getApp().getProperty("AddLeadingZero") ? "%02d" : "%d"), info.min.format("%02d"), offset >= 0 ? "+" : "-", offset.abs() ]);
	}

	function getActiveCalories(calories) {
		var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);		
		var age = today.year - MainController.environmentInfo.birthYear;
		var weight = MainController.environmentInfo.weight / 1000.0;
		var restCalories = (MainController.environmentInfo.gender == UserProfile.GENDER_MALE ? 5.2 : -197.6) - 6.116 * age + 7.628 * MainController.environmentInfo.height + 12.2 * weight;

		restCalories = Math.round((today.hour * 60 + today.min) / 1440.0 * restCalories).toNumber();
		
		return calories > restCalories ? calories - restCalories : 0;
	}
	
	function drawSplitText(x, y, font, text, justification, color) {
		if(text.length() > 0) {
			x += MainController.dc.getTextWidthInPixels(text.substring(0, 1), font) / 2;
			
			if(justification != Graphics.TEXT_JUSTIFY_LEFT) {
				var textWidth = MainController.dc.getTextWidthInPixels(text, font) / 2;
				
				if(justification == Graphics.TEXT_JUSTIFY_CENTER) {
					x -= textWidth;
				}
				else if(justification == Graphics.TEXT_JUSTIFY_RIGHT) {
					x -= textWidth * 2;
				}
			}
			for (var i = 0; i < text.length(); ++i) {
				var char = text.substring(i, i + 1);
				
				MainController.dc.setColor(color, Graphics.COLOR_TRANSPARENT);
				MainController.dc.drawText(x, y, font, char, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
				
				x += MainController.dc.getTextWidthInPixels(char, font);
			}
		}
	}
	
	function drawTextOnCircle(startAngle, radius, font, baseFont, text, clockwise, color) {
    	var circumference = Utils.getCircleCircumference(radius);
    	var charBaseDimensions = Utils.getDimensionsOfEachChar(baseFont, text);
    	var offset = 0;
 
    	for(var i = 0; i < charBaseDimensions.size(); ++i) {
    		var angle = Utils.getAngleForChar(charBaseDimensions[i]["x"], circumference, offset, clockwise) + startAngle;
    		var pointOnCircle = Utils.getPointOnCircle(MainController.dc.getWidth() / 2, MainController.dc.getHeight() / 2, radius, angle);

    		MainController.dc.setColor(color, Graphics.COLOR_TRANSPARENT);
    		MainController.dc.drawText(pointOnCircle[0], pointOnCircle[1] - charBaseDimensions[i]["y"], font, text.substring(i, i + 1), Graphics.TEXT_JUSTIFY_LEFT);

    		offset += charBaseDimensions[i]["x"];
    	}
	}
	
	function drawLine(x, y, width, height, color) {
		MainController.dc.setColor(color, Graphics.COLOR_TRANSPARENT);

		MainController.dc.fillRectangle((x - width / 2).abs(), (y - height / 2).abs(), width, height);
	}
	
	function drawRectangleStartingFromLeft(x, y, width, height, color) {
		MainController.dc.setColor(color, Graphics.COLOR_TRANSPARENT);

		MainController.dc.fillRectangle(x, (y - height / 2).abs(), width, height);
	}
	
	function drawRectangleStartingFromMiddle(x, y, width, height, color) {
		MainController.dc.setColor(color, Graphics.COLOR_TRANSPARENT);

		MainController.dc.fillRectangle((x - width / 2).abs(), (y - height / 2).abs(), width, height);
	}
	
	function drawArc(cx, cy, radius, startAngle, endAngle, thickness, color, clockwise) {
		MainController.dc.setColor(color, Graphics.COLOR_TRANSPARENT);
		MainController.dc.setPenWidth(thickness);
		
		if(clockwise) {
			MainController.dc.drawArc(cx, cy, radius, Graphics.ARC_CLOCKWISE, 360 - startAngle + 90, 360 - endAngle + 90);
		} else {
			MainController.dc.drawArc(cx, cy, radius, Graphics.ARC_COUNTER_CLOCKWISE, startAngle + 90, endAngle + 90);
		}
	}
	
	// 0 = 12 o'clock, 90 = 3 o'clock, 180 = 6 o'clock, 270 = 9 o'clock
	function getPointOnCircle(cx, cy, radius, angle) {
		var x = cx + radius * Math.cos(((angle - 90) * 2 * Math.PI) / 360); // -90 so that it starts at 12 o'clock
		var y = cy + radius * Math.sin(((angle - 90) * 2 * Math.PI) / 360);
   	 	
   	 	return [ x, y ];
	}

	function getPixelPointsOnCircle(cx, cy, radius, numPoints) {
		var points = { };
		
		for(var i = 0; i < numPoints; ++i) {
			points[i] = { "x" => cx + radius * Math.cos((i * 2 * Math.PI) / numPoints), "y" => cy + radius * Math.sin((i * 2 * Math.PI) / numPoints) };
		}
		return points;
	}
	
	function getCircleCircumference(radius) {
		return 2 * Math.PI * radius;
	}
	
	function getDimensionsOfEachChar(font, text) {
		if(text.length() > 0) {
			var result = { };

			for(var i = 0; i < text.length(); ++i) {
				var dimensions = MainController.dc.getTextDimensions(text.substring(i, i + 1), font);
				
				result[i] = { "x" => dimensions[0], "y" => dimensions[1] };
			}
			return result;
		}
		return null;
	}
	
	function getAngleForChar(charWidth, circumference, offset, clockwise) {
		return Math.toDegrees((charWidth / 2 + offset) / circumference * 2 * Math.PI) * (clockwise ? 1 : -1);
	}
}