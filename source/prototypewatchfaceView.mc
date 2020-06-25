using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang;
using Toybox.Application as App;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Math;
using Toybox.ActivityMonitor;
using Toybox.Activity;
using Toybox.UserProfile;

class prototypewatchfaceView extends Ui.WatchFace {
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
	var envInfo,
		width,
		height;
	
	// Device Context
	var dc;
	
	var mockBackground;
	
	// UiElements
	var clockArea,
		topIcons,
		bottomIcons,
		top,
		bottom,
		right,
		left,
		topIconsPowerSaving,
		bottomIconsPowerSaving,
		bottomLine,
		topLine;
	
	// Settings
	var powerSavingMode,
		displayIconsOnPowerSavingMode,
		oldDndState,
		isSleep = false;
	
	function onLayout(dc) {
		self.dc = dc;
		width = dc.getWidth();
		height = dc.getHeight();
		
		envInfo = new Environment.Info();
		
		updateEnvironmentInfo();
		
		oldDndState = envInfo.doNotDisturb;
		
        Textures.init();
        
        mockBackground = new Ui.Bitmap({
        	:rezId => Rez.Drawables.MockBackground,
        	:locX  => 0,
        	:locY  => 0
    	});
    	powerSavingMode = App.getApp().getProperty("PowerSavingMode");
    	displayIconsOnPowerSavingMode = App.getApp().getProperty("DisplayIconsOnPowerSavingMode");

    	clockArea = new UiElements.ClockArea(Ui.loadResource(Rez.Fonts.Gobold14));

    	initElements();
    }

    function onUpdate() {
    	updateEnvironmentInfo();
    	
    	if(envInfo.doNotDisturb != oldDndState) {
			onDndChanged(envInfo.doNotDisturb);
			
			oldDndState = envInfo.doNotDisturb;
    	}
    	drawBackground();

   	 	var isPowerSavingModeActive = isPowerSavingModeActive();
   	 	
   	 	checkForInit();
   	 	
   	 	if(!isPowerSavingModeActive) {
   	 		bottomLine.draw();
   	 		topLine.draw();
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
    	var fntGobold13Shrinked = Ui.loadResource(Rez.Fonts.Gobold13Shrinked),
    		fntRobotoBold12 = Ui.loadResource(Rez.Fonts.RobotoBold12),
    		fntGobold13 = Ui.loadResource(Rez.Fonts.Gobold13),
    		fntGobold13Rotated1 = Ui.loadResource(Rez.Fonts.Gobold13Rotated1),
    		fntGobold13Rotated2 = Ui.loadResource(Rez.Fonts.Gobold13Rotated2),
    		fntGobold13Rotated3 = Ui.loadResource(Rez.Fonts.Gobold13Rotated3),
    		fntGobold13Rotated4 = Ui.loadResource(Rez.Fonts.Gobold13Rotated4),
    		fntGobold13RotatedBase = Ui.loadResource(Rez.Fonts.Gobold13RotatedBase);
    	
        topIcons = new UiElements.TopIcons(fntGobold13Shrinked);
        bottomIcons = new UiElements.BottomIcons();
        top = new UiElements.Top(fntRobotoBold12, fntGobold13);
        bottom = new UiElements.Bottom(fntGobold13);
        right = new UiElements.Right(fntGobold13Shrinked);
        left = new UiElements.Left(fntGobold13Shrinked, Ui.loadResource(Rez.Fonts.RobotoCondensedBold12));
        bottomLine = new UiElements.BottomLine(fntGobold13Rotated1, fntGobold13Rotated2, fntGobold13RotatedBase);
        topLine = new UiElements.TopLine(fntGobold13Rotated3, fntGobold13Rotated4, fntGobold13RotatedBase);
        
        topIconsPowerSaving = null;
        bottomIconsPowerSaving = null;
    }
    
    function powerSavingModeElementsInit() {
     	topIconsPowerSaving = new UiElements.TopIconsLarge(Ui.loadResource(Rez.Fonts.Gobold13));
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
    	powerSavingMode = App.getApp().getProperty("PowerSavingMode");
    	displayIconsOnPowerSavingMode = App.getApp().getProperty("DisplayIconsOnPowerSavingMode");
    	
    	initElements();
    
    	clockArea.onSettingUpdate();
    	
    	if(!isPowerSavingModeActive()) {
    		top.onSettingUpdate();
    		bottomLine.onSettingUpdate();
    	}
    }
    
    function updateEnvironmentInfo() {
   	 	envInfo.setValues(Sys.getDeviceSettings(), Sys.getSystemStats(), UserProfile.getProfile(), ActivityMonitor.getInfo());
    }
    
    function isPowerSavingModeActive() {
    	return powerSavingMode == 1 || (powerSavingMode == 2 && envInfo.doNotDisturb);
    }
    
    function drawBackground() {
    	dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.clear();
    }
}

module UiElements {
	class ClockArea {
		private var hoursTxt,
					hoursFormat,
					minutesTxt,
					minutesColon,
					secondsTxt,
					dateTxt,
					partOfDayTxt,
					clockElements,
					displaySeconds,
					wereSecondsDisplayed;

	    function initialize(fntGobold14) {
			clockElements = new [0];

			var fntGoboldBold78 = Ui.loadResource(Rez.Fonts.GoboldBold78),
	        	fntGoboldBold55 = Ui.loadResource(Rez.Fonts.GoboldBold55);

			hoursTxt = clockElements.add(new Extensions.Text({
			    :text => "00",
	            :color         => Gfx.COLOR_WHITE,
	            :typeface      => fntGoboldBold78,
	            :locX          => 88 + (MainController.dc.getTextWidthInPixels("00", fntGoboldBold78) / 2),
	            :locY          => 129,
	            :justification => Gfx.TEXT_JUSTIFY_VCENTER | Gfx.TEXT_JUSTIFY_RIGHT
	        }, false))[clockElements.size() - 1];
	        minutesTxt = clockElements.add(new Extensions.Text({
	            :color    => Gfx.COLOR_LT_GRAY,
	            :typeface => fntGoboldBold55,
	            :locX     => 177,
	            :locY     => 121
	        }, true))[clockElements.size() - 1];
	        minutesColon = clockElements.add(new Extensions.Text({
	            :color    => Gfx.COLOR_LT_GRAY,
	            :typeface => fntGoboldBold55,
	            :locX     => 137,
	            :locY     => 121
	        }, true))[clockElements.size() - 1];
	        dateTxt = clockElements.add(new Extensions.Text({
	            :color    => Gfx.COLOR_WHITE,
	            :typeface => Ui.loadResource(Rez.Fonts.Gobold18),
	            :locX     => 177,
	            :locY     => 151
	        }, true))[clockElements.size() - 1];
	        partOfDayTxt = clockElements.add(new Extensions.Text({
	            :color    => Gfx.COLOR_WHITE,
	            :typeface => fntGobold14,
	            :locX     => 44,
	            :locY     => 152
	        }, true))[clockElements.size() - 1];
	        secondsTxt = new Extensions.Text({
	        	:text     => "00",
	        	:typeface => fntGobold14,
	            :color    => Gfx.COLOR_LT_GRAY,
	            :locX     => 213,
	            :locY     => 106
	        }, true);

	        hoursFormat = App.getApp().getProperty("AddLeadingZero") ? "%02d" : "%d";
	        displaySeconds = App.getApp().getProperty("DisplaySeconds");
	        
	        var shouldDisplaySeconds = shouldDisplaySeconds();

	        if(!shouldDisplaySeconds) {
	        	setClockPosition();
	        } else {
	        	wereSecondsDisplayed = shouldDisplaySeconds;
	        }
	    }
	
	    function draw() {
	    	var now = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM),
	    		hours = now.hour;

		    partOfDayTxt.setText(hours > 12 ? "P" : "A");
		    
		    if(!MainController.envInfo.is24Hour) {
				hours -= hours > 12 ? 12 : 0;
			}
			hoursTxt.setText(hours.format(hoursFormat));
			minutesTxt.setText(now.min.format("%02d"));
			minutesColon.setText(":");
			dateTxt.setText(now.day.format("%02d") + " " + now.month.toUpper());
			
			hoursTxt.draw();
			minutesTxt.draw();
			minutesColon.draw();
			dateTxt.draw();
			partOfDayTxt.draw();

			if(shouldDisplaySeconds()) {
				secondsTxt.setText(now.sec.format("%02d"));
				secondsTxt.draw();
			}
			Utils.drawLine(130, 96, 185, 3, Gfx.COLOR_RED);
			Utils.drawLine(130, 162, 185, 3, Gfx.COLOR_RED);
	    }

	    function onSettingUpdate() {
	    	hoursFormat = App.getApp().getProperty("AddLeadingZero") ? "%02d" : "%d";
	    	displaySeconds = App.getApp().getProperty("DisplaySeconds");
	    	
	    	setClockPosition();
	    }
	    
	    function onEnterSleep() {
	    	secondsTxt.setColor(Gfx.COLOR_TRANSPARENT);
	    }
	    
	    function onExitSleep() {
	    	secondsTxt.setColor(Gfx.COLOR_LT_GRAY);
	    	
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
			    		clockElements[i].locX -= secondsTxt.getDimensions()[0] / 2;
			    	}
	    		} else {
	    			for(var i = 0; i < clockElements.size(); ++i) {
			    		clockElements[i].locX += secondsTxt.getDimensions()[0] / 2;
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
		protected var battTxt,
				      battIcon,
					  notificationIcon,
					  alarmIcon,
					  battRectX,
					  battRectY,
					  battRectWidth,
					  battRectHeight;
		
		function draw() {
			var battLvl = Math.round(MainController.envInfo.battery);

			battTxt.setText(Lang.format("$1$%", [ (battLvl + 0.5).format( "%d" ) ]));
			battTxt.draw();

			var color = Gfx.COLOR_WHITE;
			
			if(!MainController.envInfo.charging) { // 3.0.0
				if(battLvl <= 20) {
					color = Gfx.COLOR_RED;
				}
			} else {
				if(battLvl < 99.5) {
					color = Gfx.COLOR_BLUE;
				} else {
					color = Gfx.COLOR_GREEN;
				}
			}
			battIcon.setColor(color);
			setBatteryLevel(battLvl, color);
			
			notificationIcon.setColor(MainController.envInfo.notificationCount > 0 ? Gfx.COLOR_RED : Gfx.COLOR_WHITE);
			alarmIcon.setColor(MainController.envInfo.alarmCount > 0 ? Gfx.COLOR_RED : Gfx.COLOR_WHITE);

			battIcon.draw();
			notificationIcon.draw();
			alarmIcon.draw();
		}
		
		function setBatteryLevel(lvl, color) {
			Utils.drawRectangleStartingFromLeft(battRectX, battRectY, Math.ceil(lvl / 100.0 * battRectWidth), battRectHeight, color);
		}
	}
	
	class TopIcons extends TopIconsBase {
		function initialize(fntGobold13Shrinked) {
			TopIconsBase.initialize();
		
			battIcon = new Textures.Icon('B');
			battIcon.setPosition(130, 19);
			
			battTxt = new Extensions.Text({
	            :color    => Gfx.COLOR_WHITE,
	            :typeface => fntGobold13Shrinked,
	            :locX     => 130,
	            :locY     => 7
	        }, true);
	        
			notificationIcon = new Textures.Icon('C');
			notificationIcon.setPosition(154, 16);
			
			alarmIcon = new Textures.Icon('D');
			alarmIcon.setPosition(104, 15);

			battRectWidth = 14;
			battRectHeight = 4;
			battRectX = 129 - battRectWidth / 2;
			battRectY = 20;
		}
		
		function draw() {
			TopIconsBase.draw();
		}
	}
	
	class TopIconsLarge extends TopIconsBase {
		function initialize(fntGobold13) {
			TopIconsBase.initialize();
			
			battIcon = new Textures.Icon('A');
			battIcon.setPosition(130, 50);
			
			battTxt = new Extensions.Text({
	            :color    => Gfx.COLOR_WHITE,
	            :typeface => fntGobold13,
	            :locX     => 130,
	            :locY     => 33
	        }, true);

			notificationIcon = new Textures.Icon('Z');
			notificationIcon.setPosition(180, 55);
			
			alarmIcon = new Textures.Icon('Y');
			alarmIcon.setPosition(80, 55);

			battRectWidth = 19;
			battRectHeight = 6;
			battRectX = 129 - battRectWidth / 2;
			battRectY = 51;
		}
		
		function draw() {
			TopIconsBase.draw();
		}
	}
	
	class BottomIconsBase {
		protected var moveIcon,
				      dndIcon,
					  btIcon;

		function draw(isLarge) {
			var moveBarLevel = MainController.envInfo.moveBarLevel;

			dndIcon.setColor(MainController.envInfo.doNotDisturb ? Gfx.COLOR_RED : Gfx.COLOR_WHITE); // 2.1.0
			btIcon.setColor(MainController.envInfo.phoneConnected ? Gfx.COLOR_RED : Gfx.COLOR_WHITE);
			setMoveIcon(moveBarLevel, isLarge);
			
			moveIcon.draw();
			dndIcon.draw();
			btIcon.draw();
		}
		
		function setMoveIcon(lvl, isLarge) {
			var targetIcon = null,
				isInSleeptTime = isInSleepTime();
			
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
					moveIcon.setColor(Gfx.COLOR_RED);
				} else {
					moveIcon.setColor(Gfx.COLOR_WHITE);
				}
			} else {
				moveIcon.setColor(Gfx.COLOR_RED);
			}
		}
		
		function isInSleepTime() {
	        var today = Time.today().value(),
        		sleepTime = new Time.Moment(today + MainController.envInfo.sleepTime),
	        	now = new Time.Moment(Time.now().value());
	        
	        if(now.value() >= sleepTime.value()) {
	       		return true;
	        } else {
	         	var wakeTime = new Time.Moment(today + MainController.envInfo.wakeTime);
	         	
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
		private var daysTxt,
					arrowIcon,
					daysInitialY = 88,
					daysYOffset = 3,
					dayNames = [ "SU", "MO", "TU", "WE", "TH", "FR", "SA" ],
					infoTxt,
					iconLeft,
					iconMiddle,
					iconRight,
					iconTxtLeft,
					iconTxtMiddle,
					iconTxtRight;

		function initialize(fntRobotoBold12, fntGobold13) {
			arrowIcon = new Textures.Icon('I');
			arrowIcon.setColor(Gfx.COLOR_RED);
			arrowIcon.setPosition(56, 93);
			
			iconLeft = new Textures.Icon('X');
			iconLeft.setColor(Gfx.COLOR_WHITE);
			iconLeft.setPosition(94, 66);
			
			iconMiddle = new Textures.Icon('O');
			iconMiddle.setColor(Gfx.COLOR_WHITE);
			iconMiddle.setPosition(143, 66);
			
			iconRight = new Textures.Icon('9');
			iconRight.setColor(Gfx.COLOR_WHITE);
			iconRight.setPosition(193, 66);
			
			iconTxtLeft = new Extensions.Text({
	            :color         => Gfx.COLOR_WHITE,
	            :typeface      => fntGobold13,
	            :locX          => 83,
	            :locY          => 60,
	            :justification => Gfx.TEXT_JUSTIFY_VCENTER | Gfx.TEXT_JUSTIFY_RIGHT
        	}, false);
        	
        	iconTxtMiddle = new Extensions.Text({
	            :color         => Gfx.COLOR_WHITE,
	            :typeface      => fntGobold13,
	            :locX          => 136,
	            :locY          => 60,
	            :justification => Gfx.TEXT_JUSTIFY_VCENTER | Gfx.TEXT_JUSTIFY_RIGHT
        	}, false);
        	
        	iconTxtRight = new Extensions.Text({
	            :color         => Gfx.COLOR_WHITE,
	            :typeface      => fntGobold13,
	            :locX          => 182,
	            :locY          => 60,
	            :justification => Gfx.TEXT_JUSTIFY_VCENTER | Gfx.TEXT_JUSTIFY_RIGHT
        	}, false);

			daysTxt = new [7];

			for(var i = 0; i < daysTxt.size(); ++i) {
				daysTxt[i] = new Extensions.Text({
					:text     => dayNames[i],
		            :color    => Gfx.COLOR_WHITE,
		            :typeface => fntRobotoBold12,
		            :locY     => daysInitialY
	        	}, true);
			}
			orderDaysOfWeek(App.getApp().getProperty("FirstDayOfWeek"));
			
			infoTxt = new Extensions.Text({
	            :color    => Gfx.COLOR_WHITE,
	            :typeface => fntRobotoBold12,
	            :locX     => 130,
	            :locY     => 41
        	}, true);
		}
		
		function draw() {
			var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT),
				dayOfWeek = now.day_of_week;

			for(var i = 0; i < daysTxt.size(); ++i) {
				if(i == dayOfWeek - 1) {
					daysTxt[i].setColor(Gfx.COLOR_RED);
					
					daysTxt[i].locY = daysInitialY - daysYOffset;
					
					arrowIcon.setPosition(daysTxt[i].locX, arrowIcon.text.locY);
				} else {
					if(dayNames[i].equals("SA") || dayNames[i].equals("SU")) {
						daysTxt[i].setColor(Gfx.COLOR_LT_GRAY);
					} else {
						daysTxt[i].setColor(Gfx.COLOR_WHITE);
					}
					daysTxt[i].locY = daysInitialY;
				}
				daysTxt[i].draw();
				arrowIcon.draw();
			}
			// infoTxt.setText("Week " + Utils.getCurrentWeekNumber());
			
			infoTxt.setText(Utils.getTimeByOffset());

			infoTxt.draw();
			
			//! TODO: Store this and update it only once a day
			var currentMoonPhase = Utils.getCurrentMoonPhase();
			
			iconTxtLeft.setText(Utils.getCurrentWeekNumber().toString());
			iconTxtMiddle.setText(currentMoonPhase['a'] + "°");
			iconTxtRight.setText(Utils.kFormatter(Utils.getCurrentElevation(), 1));
			
			iconMiddle.setIcon(currentMoonPhase['i']);
			
			iconLeft.draw();
			iconMiddle.draw();
			iconRight.draw();
			
			iconTxtLeft.draw();
			iconTxtMiddle.draw();
			iconTxtRight.draw();
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
			
			for(var i = 0; i < daysTxt.size(); ++i) {
				daysTxt[i].locX = xLocations[i];
			}
		}
		
		function onSettingUpdate() {
	    	orderDaysOfWeek(App.getApp().getProperty("FirstDayOfWeek"));
	    }
	}
	
	class Bottom {
		private var moveBarLvl1,
					moveBarOtherLvls,
					icon1,
					icon2,
					icon3,
					icon4,
					txtIcon1,
					txtIcon2, 
					txtIcon3,
					txtIcon4;

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
    		
    		icon1.setColor(Gfx.COLOR_RED);
    		icon2.setColor(Gfx.COLOR_RED);
    		icon3.setColor(Gfx.COLOR_RED);
    		icon4.setColor(Gfx.COLOR_RED);
    		
    		icon1.setPosition(72, 174);
    		icon2.setPosition(110, 183);
    		icon3.setPosition(150, 183);
    		icon4.setPosition(188, 175);
    		
    		txtIcon1 = new Extensions.Text({
	            :color    => Gfx.COLOR_WHITE,
	            :typeface => fntGobold13,
	            :locX     => 71,
	            :locY     => 190
        	}, true);
        	txtIcon2 = new Extensions.Text({
	            :color    => Gfx.COLOR_WHITE,
	            :typeface => fntGobold13,
	            :locX     => 109,
	            :locY     => 199
        	}, true);
        	txtIcon3 = new Extensions.Text({
	            :color    => Gfx.COLOR_WHITE,
	            :typeface => fntGobold13,
	            :locX     => 149,
	            :locY     => 199
        	}, true);
        	txtIcon4 = new Extensions.Text({
	            :color    => Gfx.COLOR_WHITE,
	            :typeface => fntGobold13,
	            :locX     => 187,
	            :locY     => 190
        	}, true);
		}
		
		function draw() {
			var moveBarLevel = MainController.envInfo.moveBarLevel;

			if(moveBarLevel > 0) {
				moveBarLvl1.setColor(Gfx.COLOR_RED);
				moveBarLvl1.draw();
				
				for(var i = 0; i < moveBarLevel - 1; ++i) {
					moveBarOtherLvls[i].setColor(Gfx.COLOR_RED);
					moveBarOtherLvls[i].draw();
				}
				for(var i = moveBarLevel - 1; i < moveBarOtherLvls.size(); ++i) {
					moveBarOtherLvls[i].setColor(Gfx.COLOR_DK_GRAY);
					moveBarOtherLvls[i].draw();
				}
			} else {
				moveBarLvl1.setColor(Gfx.COLOR_DK_GRAY);
				moveBarLvl1.draw();
				
				for(var i = 0; i < moveBarOtherLvls.size(); ++i) {
					moveBarOtherLvls[i].setColor(Gfx.COLOR_DK_GRAY);
					moveBarOtherLvls[i].draw();
				}
			}
			var distance = MainController.envInfo.distance != null ? MainController.envInfo.distance : 0,
				calories = MainController.envInfo.calories != null ? MainController.envInfo.calories : 0,
				activeMinutesWeek = MainController.envInfo.activeMinutesWeek != null ? MainController.envInfo.activeMinutesWeek : 0,
				floorsClimbed = MainController.envInfo.floorsClimbed != null ? MainController.envInfo.floorsClimbed : 0;
			
			icon1.draw();
			icon2.draw();
			icon3.draw();
			icon4.draw();
			
			txtIcon1.setText(Utils.kFormatter(distance * 0.01, 1));
			txtIcon2.setText(Utils.kFormatter(calories, 1));
			txtIcon3.setText(Utils.kFormatter(activeMinutesWeek, 1));
			txtIcon4.setText(Utils.kFormatter(floorsClimbed, 1));
			
			txtIcon1.draw();
			txtIcon2.draw();
			txtIcon3.draw();
			txtIcon4.draw();
		}
	}
	
	//! TODO: Think about having a base class for right and left
	class Right {
		private var topValueTxt,
					bottomValueTxt,
					icon,
					trophyIcon,
					initialX = 242,
					arrowIcon,
					startAngle = 108,
					endAngle = 71,
					radius = 104,
					lineBitmap;
		
		function initialize(fntGobold13Shrinked) {
			topValueTxt = new Extensions.Text({
	            :color    => Gfx.COLOR_WHITE,
	            :typeface => fntGobold13Shrinked,
	            :locX     => initialX,
	            :locY     => 87
        	}, true);
        	bottomValueTxt = new Extensions.Text({
	            :color    => Gfx.COLOR_WHITE,
	            :typeface => fntGobold13Shrinked,
	            :locX     => initialX,
	            :locY     => 171
        	}, true);

        	icon = new Textures.Icon('1');
        	icon.setColor(Gfx.COLOR_WHITE);
			icon.setPosition(251, 130);
			
			trophyIcon = new Textures.Icon('6');
			
			trophyIcon.setColor(Gfx.COLOR_YELLOW);
			trophyIcon.setPosition(251, 115);
			
			arrowIcon = new Textures.Icon('8');
			
			arrowIcon.setColor(Gfx.COLOR_RED);
			
			lineBitmap = new Textures.Bitmap('C');
			
			lineBitmap.setPosition(241, 130);
		}
		
		function draw() {
			var topValue = MainController.envInfo.stepGoal != null ? MainController.envInfo.stepGoal : 0,
				bottomValue = MainController.envInfo.steps != null ? MainController.envInfo.steps : 0;

			topValueTxt.setText(Utils.kFormatter(topValue, topValue > 99999 ? 0 : 1));
			bottomValueTxt.setText(Utils.kFormatter(bottomValue, bottomValue > 99999 ? 0 : 1));
			
			topValueTxt.locX = offSetXBasedOnWidth(topValueTxt.getDimensions()[0]);
			bottomValueTxt.locX = offSetXBasedOnWidth(bottomValueTxt.getDimensions()[0]);
			
			topValueTxt.draw();
			bottomValueTxt.draw();
			
			if(bottomValue >= topValue) {
				trophyIcon.draw();
			}
			icon.draw();
			
			lineBitmap.draw();
			drawArrow(topValue, bottomValue);
		}
		
		function drawArrow(topValue, bottomValue) {
			var percentage = bottomValue >= topValue ? 1.0 : bottomValue / topValue.toFloat(),
				targetAngle = (endAngle - startAngle) * percentage,
				pointOnCircle = Utils.getPointOnCircle(MainController.width / 2, MainController.height / 2, radius, startAngle + targetAngle);

	   	 	arrowIcon.setPosition(pointOnCircle[0], pointOnCircle[1]);
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
		private var topValueTxt,
					bottomValueTxt,
					icon,
					initialX = 18,
					arrowIcon,
					radius = 104,
					startAngle = 252, // Reference to "Right". 180 - 18 = 162
					endAngle = 289,
					lineBitmap;
		
		// Feature only when heart rate is shown
		private var heartRateTxt,
					heartFilled;
		
		function initialize(fntGobold13Shrinked, fntRobotoCondensedBold12) {
			heartFilled = true;
			
			topValueTxt = new Extensions.Text({
	            :color    => Gfx.COLOR_WHITE,
	            :typeface => fntGobold13Shrinked,
	            :locX     => initialX,
	            :locY     => 87
        	}, true);
        	bottomValueTxt = new Extensions.Text({
	            :color    => Gfx.COLOR_WHITE,
	            :typeface => fntGobold13Shrinked,
	            :locX     => initialX,
	            :locY     => 171
        	}, true);
        	heartRateTxt = new Extensions.Text({
        		:text     => "--",
	            :color    => Gfx.COLOR_WHITE,
	            :typeface => fntRobotoCondensedBold12,
	            :locX     => 9,
	            :locY     => 118
        	}, true);

        	icon = new Textures.Icon('N');
        	icon.setColor(Gfx.COLOR_RED);
			icon.setPosition(9, 130);
			
			arrowIcon = new Textures.Icon('7');
			
			arrowIcon.setColor(Gfx.COLOR_RED);
			
			lineBitmap = new Textures.Bitmap('G');
			
			lineBitmap.setPosition(19, 130);
		}
		
		function draw() {
			var topValue = Utils.getMaxHeartRate(),
				bottomValue = MainController.envInfo.restingHeartRate;

			topValueTxt.setText(Utils.kFormatter(topValue, topValue > 99999 ? 0 : 1));
			bottomValueTxt.setText(Utils.kFormatter(bottomValue, bottomValue > 99999 ? 0 : 1));

			topValueTxt.locX = offSetXBasedOnWidth(topValueTxt.getDimensions()[0]);
			bottomValueTxt.locX = offSetXBasedOnWidth(bottomValueTxt.getDimensions()[0]);

			topValueTxt.draw();
			bottomValueTxt.draw();

			icon.draw();
			
			drawHeartRate();
			
			lineBitmap.draw();
			drawArrow(topValue, bottomValue);
		}
		
		function drawHeartRate() {
			if(!MainController.isSleep) {
				var currentHeartRate = Utils.getCurrentHeartRate();
				
				heartRateTxt.setText(currentHeartRate.toString());

				icon.setIcon(heartFilled ? 'N' : '0');
				
				heartFilled = !heartFilled;
				
				heartRateTxt.setColor(Gfx.COLOR_WHITE);
			} else {
				icon.setIcon('N');
				heartRateTxt.setColor(Gfx.COLOR_TRANSPARENT);
			}
			heartRateTxt.draw();
		}
		
		function drawArrow(topValue, bottomValue) {
			var percentage = bottomValue >= topValue ? 1.0 : bottomValue / topValue.toFloat(),
				targetAngle = (endAngle - startAngle) * percentage,
				pointOnCircle = Utils.getPointOnCircle(MainController.width / 2, MainController.height / 2, radius, startAngle + targetAngle);

	   	 	arrowIcon.setPosition(pointOnCircle[0], pointOnCircle[1]);
			arrowIcon.draw();
		}
		
		function onEnterSleep() {
			heartFilled = true;
			
			icon.setIcon('N');
			heartRateTxt.setColor(Gfx.COLOR_TRANSPARENT);
	    }
	    
	    function onExitSleep() {
			heartFilled = false;
			
			icon.setIcon('0');
			heartRateTxt.setColor(Gfx.COLOR_WHITE);
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
		private var caloriesGoal,
					line,		
					lineFill,
					dot,
					startAngle = 242,
					endAngle = 118,
					radius = 107.5,
					fntGobold13Rotated1,
					fntGobold13Rotated2,
					fntGobold13RotatedBase;

		function initialize(fntGobold13Rotated1, fntGobold13Rotated2, fntGobold13RotatedBase) {
			line = new Textures.Bitmap("6789AB");
        	lineFill = new Textures.Bitmap("6789AB");
        	dot = new Textures.Icon('g');

        	lineFill.setColor(Gfx.COLOR_TRANSPARENT);
        	lineFill.setBackgroundColor(Gfx.COLOR_BLACK);
        	
        	line.setColor(Gfx.COLOR_DK_GRAY);
			
			line.setPosition(130, 206);
        	lineFill.setPosition(130, 206);
        	
        	caloriesGoal = App.getApp().getProperty("ActiveCaloriesGoal");
        	
        	self.fntGobold13Rotated1 = fntGobold13Rotated1;
        	self.fntGobold13Rotated2 = fntGobold13Rotated2;
        	self.fntGobold13RotatedBase = fntGobold13RotatedBase;
		}

		function draw() {
			var leftValue = Utils.getActiveCalories(MainController.envInfo.calories),
				rightValue = caloriesGoal,
				percentage = leftValue >= rightValue ? 1.0 : leftValue / rightValue.toFloat(),
				targetAngle = (endAngle - startAngle) * percentage,
				pointOnCircle = Utils.getPointOnCircle(MainController.width / 2, MainController.height / 2, radius, startAngle + targetAngle);
			
			line.draw();

			var arcStartAngle = 360 - startAngle - 2, // -2 offset because of the arc curvature (so that the line is at the beginning is filled)
				arcTargetAngle = arcStartAngle - targetAngle + 2; // +2 offset because of the arc curvature (so that the line is at the end is filled)

			if(arcTargetAngle > arcStartAngle) {
				Utils.drawArc(MainController.width / 2, MainController.height / 2, radius, arcStartAngle, arcTargetAngle, 20, Gfx.COLOR_RED, false);
			}
			lineFill.draw();

			if(pointOnCircle[0] >= 89 && pointOnCircle[0] <= 170) {
				pointOnCircle[1] = 229;
			}
			dot.setPosition(pointOnCircle[0], pointOnCircle[1]);
			dot.draw();
			
			Utils.drawTextOnCircle(143, 122, fntGobold13Rotated1, fntGobold13RotatedBase, Utils.kFormatter(leftValue, 1), false, Gfx.COLOR_WHITE, Gfx.TEXT_JUSTIFY_LEFT);
			Utils.drawTextOnCircle(229, 124, fntGobold13Rotated2, fntGobold13RotatedBase, Utils.kFormatter(rightValue, 1), false, Gfx.COLOR_WHITE, Gfx.TEXT_JUSTIFY_RIGHT);
		}
		
		function onSettingUpdate() {
	    	caloriesGoal = App.getApp().getProperty("ActiveCaloriesGoal");
	    }
	}
	
	class TopLine {
		private var line,		
					lineFill,
					dotNow,
					dotSunrise,
					dotSunset,
					dotSunriseBg,
					dotSunsetBg,
					startAngle = 299,
					endAngle = 61,
					radius = 109,
					fntGobold13Rotated3,
					fntGobold13Rotated4,
					fntGobold13RotatedBase;

		function initialize(fntGobold13Rotated3, fntGobold13Rotated4, fntGobold13RotatedBase) {
			line = new Textures.Bitmap("012345");
        	lineFill = new Textures.Bitmap("012345");
        	
        	dotNow = new Textures.Icon('g');
        	dotSunrise = new Textures.Icon('g');
        	dotSunset = new Textures.Icon('g');
        	
        	dotSunriseBg = new Textures.Icon('h');
        	dotSunsetBg = new Textures.Icon('h');
        	
        	dotSunrise.setColor(Gfx.COLOR_BLACK);
        	dotSunset.setColor(Gfx.COLOR_BLACK);
        	
        	lineFill.setColor(Gfx.COLOR_TRANSPARENT);
        	lineFill.setBackgroundColor(Gfx.COLOR_BLACK);
        	
        	line.setColor(Gfx.COLOR_DK_GRAY);
			
			line.setPosition(130, 53);
        	lineFill.setPosition(130, 53);
        	
        	self.fntGobold13Rotated3 = fntGobold13Rotated3;
        	self.fntGobold13Rotated4 = fntGobold13Rotated4;
        	self.fntGobold13RotatedBase = fntGobold13RotatedBase;
		}

		function draw() {
			var sunrise = App.getApp().getProperty("Sunrise"),
				sunset = App.getApp().getProperty("Sunset"),
			    sunriseAbsolute = sunrise != null ? sunrise / Gregorian.SECONDS_PER_DAY.toFloat() : 0,
				sunsetAbsolute =  sunset != null ? sunset / Gregorian.SECONDS_PER_DAY.toFloat() : 0,
				nowAbsolute = Utils.getTimeOfTheDayInAbsoluteValue(new Time.Moment(Time.now().value()).value()),
				targetAngleNow = (360 - (startAngle - endAngle)) * nowAbsolute,
				targetAngleSunrise = (360 - (startAngle - endAngle)) * sunriseAbsolute,
				targetAngleSunset = (360 - (startAngle - endAngle)) * sunsetAbsolute,
				pointOnCircleNow = Utils.getPointOnCircle(MainController.width / 2, MainController.height / 2, radius, startAngle + targetAngleNow),
				pointOnCircleSunrise = Utils.getPointOnCircle(MainController.width / 2, MainController.height / 2, radius, startAngle + targetAngleSunrise),
				pointOnCircleSunset = Utils.getPointOnCircle(MainController.width / 2, MainController.height / 2, radius, startAngle + targetAngleSunset);

			line.draw();
			
			//! TODO: Sunset could be after midnight. There it should be two instances of line draw...
			if(sunrise != null && sunrise != null) {
				Utils.drawArc(MainController.width / 2, MainController.height / 2, radius, startAngle + targetAngleSunrise, startAngle + targetAngleSunset, 20, Gfx.COLOR_RED, true);
	
				lineFill.draw();
				
				if(pointOnCircleNow[0] >= 89 && pointOnCircleNow[0] <= 170) {
					pointOnCircleNow[1] = 28;
				}
				if(pointOnCircleSunrise[0] >= 89 && pointOnCircleSunrise[0] <= 170) {
					pointOnCircleSunrise[1] = 28;
				}
				if(pointOnCircleSunset[0] >= 89 && pointOnCircleSunset[0] <= 170) {
					pointOnCircleSunset[1] = 28;
				}
				dotSunriseBg.setPosition(pointOnCircleSunrise[0], pointOnCircleSunrise[1]);
				dotSunriseBg.draw();
	
				dotSunsetBg.setPosition(pointOnCircleSunset[0], pointOnCircleSunset[1]);
				dotSunsetBg.draw();
	
				dotSunrise.setPosition(pointOnCircleSunrise[0], pointOnCircleSunrise[1]);
				dotSunrise.draw();
				
				dotSunset.setPosition(pointOnCircleSunset[0], pointOnCircleSunset[1]);
				dotSunset.draw();

				Utils.drawTextOnCircle(301, 116, fntGobold13Rotated3, fntGobold13RotatedBase, Utils.formatEpochToHumanReadable(sunrise, false, true), true, Gfx.COLOR_WHITE, Gfx.TEXT_JUSTIFY_RIGHT);
				Utils.drawTextOnCircle(44, 116, fntGobold13Rotated4, fntGobold13RotatedBase, Utils.formatEpochToHumanReadable(sunset, false, true), true, Gfx.COLOR_WHITE, Gfx.TEXT_JUSTIFY_LEFT);
			} else {
				Utils.drawTextOnCircle(301, 116, fntGobold13Rotated3, fntGobold13RotatedBase, "--:--", true, Gfx.COLOR_WHITE, Gfx.TEXT_JUSTIFY_RIGHT);
				Utils.drawTextOnCircle(44, 116, fntGobold13Rotated4, fntGobold13RotatedBase, "--:--", true, Gfx.COLOR_WHITE, Gfx.TEXT_JUSTIFY_LEFT);
			}
			dotNow.setPosition(pointOnCircleNow[0], pointOnCircleNow[1]);
			dotNow.draw();
		}
	}
}

module Textures {
	var iconsFont,
	    bitmapsFont;
	
/*
	Icons:
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

	Bitmaps:
		"Line-Top"    => "012345"
		"Line-Bottom" => "6789AB"
		"Line-Right"  => 'C'
		"Line-Left"   => 'G'
*/
	
	function init() {
		iconsFont = Ui.loadResource(Rez.Fonts.Icons);
		bitmapsFont = Ui.loadResource(Rez.Fonts.Bitmaps);
	}
	
	//! TODO: If you need dimensions of the icons than the .fnt file needs to be updated with the correct values
	class Texture {
		var text;

		protected var char;
		
		private var color,
			        backgroundColor;

		function initialize() {
        	text.setJustification(Gfx.TEXT_JUSTIFY_VCENTER | Gfx.TEXT_JUSTIFY_CENTER);
        	
        	setColor(Gfx.COLOR_WHITE);
        	setBackgroundColor(Gfx.COLOR_TRANSPARENT);

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
			text = new Ui.Text({
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
			text = new Ui.Text({
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
	class Text extends Ui.Text {
		private var text,
					color,
					backgroundColor,
					typeface;
		
		function initialize(settings, centerJustification) {
			Ui.Text.initialize(settings);
			
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
				setJustification(Gfx.TEXT_JUSTIFY_VCENTER | Gfx.TEXT_JUSTIFY_CENTER);
			}
			return self;
		}
		
		function draw() {
			Ui.Text.draw(MainController.dc);
		}
		
		function setText(text) {
			if(text != self.text) {
				Ui.Text.setText(text);
				
				self.text = text;
			}
			return self;
		}
		
		function setFont(font) {
			if(font != typeface) {
				Ui.Text.setFont(font);
				
				typeface = font;
			}
			return self;
		}
		
		function setColor(color) {
			if(color != self.color) {
				Ui.Text.setColor(color);
				
				self.color = color;
			}
			return self;
		}
		
		function setBackgroundColor(color) {
			if(color != self.backgroundColor) {
				Ui.Text.setBackgroundColor(color);
				
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
		var doNotDisturb,
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

//! TODO: All heart rate related functions need to be checked if they have heart rate monitor
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
		var today = new Time.Moment(Time.today().value() + Sys.getClockTime().timeZoneOffset);

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
	    	var formatted = (num / 1000.0).format("%." + precision + "f"),
	    		rounded = Math.round(num / 1000.0),
				isWholeNumber = formatted.toFloat() - rounded == 0;
	
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
		var heartRateHistory = ActivityMonitor.getHeartRateHistory(null, false),
			sum = 0,
			count = 0;

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
		var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT),
			year = now.year,
			month = now.month,
			day = now.day;
			
		return getMoonPhaseForDate(year, month, day);
	}
	
	function getMoonPhaseForDate(year, month, day) {
	    if(month < 3) {
	        year--;
	        month += 12;
	    }
	    ++month;
	
	    var julian = ((365.25 * year) + (30.6 * month) + day - 694039.09) / 29.5305882,
	    	result = julian.toNumber();
	
	    julian -= result;
	    result = Math.round(julian * 8).toNumber();
		result = result >= 8 ? 0 : result;

	    return moonPhases[result];
	}
	
	function getTimeByOffset() {
		var offset = App.getApp().getProperty("AlternativeTimezone"),
			time = new Time.Moment(Time.now().value() + offset * 3600),
			info = Gregorian.utcInfo(time, Time.FORMAT_SHORT);

		return Lang.format("$1$:$2$ (GMT$3$$4$)", [ info.hour.format(App.getApp().getProperty("AddLeadingZero") ? "%02d" : "%d"), info.min.format("%02d"), offset >= 0 ? "+" : "-", offset.abs() ]);
	}

	function getActiveCalories(calories) {
		var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT),	
			age = today.year - MainController.envInfo.birthYear,
			weight = MainController.envInfo.weight / 1000.0,
			restCalories = (MainController.envInfo.gender == UserProfile.GENDER_MALE ? 5.2 : -197.6) - 6.116 * age + 7.628 * MainController.envInfo.height + 12.2 * weight;

		restCalories = Math.round((today.hour * 60 + today.min) / 1440.0 * restCalories).toNumber();
		
		return calories > restCalories ? calories - restCalories : 0;
	}

	function drawTextOnCircle(startAngle, radius, font, baseFont, text, clockwise, color, justification) {
		if(!clockwise) {
			startAngle *= -1;
		}
    	var circumference = getCircleCircumference(radius),
    		charBaseWidths = getWidthsOfEachChar(baseFont, text),
    		offset = 0;
 
    	for(var i = 0; i < charBaseWidths.size(); ++i) {
    		var angle = getAngleForChar(charBaseWidths[i], circumference, offset, clockwise) + startAngle;
    		var pointOnCircle = getPointOnCircle(MainController.width / 2, MainController.height / 2, radius, angle);
    		
    		MainController.dc.setColor(color, Gfx.COLOR_TRANSPARENT);
    		MainController.dc.drawText(pointOnCircle[0], pointOnCircle[1], font, text.substring(i, i + 1), justification | Gfx.TEXT_JUSTIFY_VCENTER);

    		offset += charBaseWidths[i];
    	}
	}
	
	function drawLine(x, y, width, height, color) {
		MainController.dc.setColor(color, Gfx.COLOR_TRANSPARENT);

		MainController.dc.fillRectangle((x - width / 2).abs(), (y - height / 2).abs(), width, height);
	}
	
	function drawRectangleStartingFromLeft(x, y, width, height, color) {
		MainController.dc.setColor(color, Gfx.COLOR_TRANSPARENT);

		MainController.dc.fillRectangle(x, (y - height / 2).abs(), width, height);
	}
	
	function drawRectangleStartingFromMiddle(x, y, width, height, color) {
		MainController.dc.setColor(color, Gfx.COLOR_TRANSPARENT);

		MainController.dc.fillRectangle((x - width / 2).abs(), (y - height / 2).abs(), width, height);
	}
	
	function drawArc(cx, cy, radius, startAngle, endAngle, thickness, color, clockwise) {
		MainController.dc.setColor(color, Gfx.COLOR_TRANSPARENT);
		MainController.dc.setPenWidth(thickness);
		
		if(clockwise) {
			MainController.dc.drawArc(cx, cy, radius, Gfx.ARC_CLOCKWISE, 360 - startAngle + 90, 360 - endAngle + 90);
		} else {
			MainController.dc.drawArc(cx, cy, radius, Gfx.ARC_COUNTER_CLOCKWISE, startAngle + 90, endAngle + 90);
		}
	}
	
	// 0 = 12 o'clock, 90 = 3 o'clock, 180 = 6 o'clock, 270 = 9 o'clock
	function getPointOnCircle(cx, cy, radius, angle) {
		var x = cx + radius * Math.cos(Math.toRadians(angle - 90)); // -90 so that it starts at 12 o'clock
   	 	var y = cy + radius * Math.sin(Math.toRadians(angle - 90));
   	 	
   	 	return [ x, y ];
	}

	function getPointsOnCircle(cx, cy, radius, numPoints) {
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
	
	function getWidthsOfEachChar(font, text) {
		if(text.length() > 0) {
			var result = new [text.length()];

			for(var i = 0; i < text.length(); ++i) {
				result[i] = MainController.dc.getTextWidthInPixels(text.substring(i, i + 1), font);
			}
			return result;
		}
		return null;
	}
	
	function getAngleForChar(charWidth, circumference, offset, clockwise) {
		return Math.toDegrees((charWidth / 2.0 + offset) / circumference * 2 * Math.PI) * (clockwise ? 1 : -1);
	}

  	(:background)
  	function getCurrentLocation() {
		var currentLocation = Activity.getActivityInfo().currentLocation;
		
		if(currentLocation != null) {
			return currentLocation.toDegrees();
		}
		return currentLocation;
	}
	
	function formatEpochToHumanReadable(epoch, showSeconds, utc) {
		if(epoch != null) {
			var info = utc ? Gregorian.utcInfo(new Time.Moment(epoch), Time.FORMAT_SHORT) : Gregorian.info(new Time.Moment(epoch), Time.FORMAT_SHORT);
			
			if(showSeconds) {
				return Lang.format("$1$:$2$:$3$", [ info.hour.format("%02d"), info.min.format("%02d"), info.sec.format("%02d") ]);
			}
			return Lang.format("$1$:$2$", [ info.hour.format("%02d"), info.min.format("%02d") ]);
		}
		return null;
	}
	
	function getTimeOfTheDayInAbsoluteValue(value) {
		return (value - Time.today().value()) / Gregorian.SECONDS_PER_DAY.toFloat();
	}
}