using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Timer as Timer;
using Toybox.Attention as Attention;
using Toybox.Graphics as Gfx;

class TimerView extends BaseView {

	var up = false;
	var inOffset = false;
	var started = false;
	var seconds = 300;

	hidden var timer;
	hidden var timeTimer;
	hidden var center = new [3];
	hidden var signalVibrate = [ new Attention.VibeProfile(50, 500) ];
    hidden var countdownVibrate = [ new Attention.VibeProfile(50, 300) ];
    hidden var startVibrate = [ new Attention.VibeProfile(50, 1000) ];

    function onLayout(dc) {
    	center[0] = dc.getWidth() / 2;
    	center[1] = dc.getHeight() / 2;
    	center[2] = center[1] - (dc.getFontHeight(Gfx.FONT_NUMBER_THAI_HOT) / 2);
    	if(mode == MODE_PURSUIT) {
    		setLayout(Rez.Layouts.OffsetTimerLayout(dc));
    		View.findDrawableById("TimerLabel").setColor(Gfx.COLOR_BLUE);
    	} else {
        	setLayout(Rez.Layouts.TimerLayout(dc));
        }
    }

    //! Called when this View is brought to the foreground. Restore
    //! the state of this View and prepare it to be shown. This includes
    //! loading resources into memory.
    function onShow() {
    	up = false;
    	inOffset = false;
    	started = false;
    	timerDisplay();
    	timer = new Timer.Timer();
    	timerStart();
    }

    //! Update the view
    function onUpdate(dc) {
        // show the timer time
    	timerDisplay();
    	// draw the arc
		var theta = ((seconds % 60) / 60f) * 2 * Math.PI;
		Sys.println(theta);

		// vibrate
		if(seconds == 0 || (mode == MODE_PURSUIT && pursuitSeconds() == 0)) { // pulse at start
			Attention.vibrate(startVibrate);
			Attention.playTone(Attention.TONE_ALARM);
		} else if(!up) {
			var isMainMinute = !inOffset && (seconds % 60) == 0;
			if(isMainMinute || (mode == MODE_PURSUIT && (pursuitSeconds() % 60) == 0)) { // pulse on minute
				if(isMainMinute) {
					var min = seconds / 60;
					if(min == 5 || min == 4 || min == 1) {
						Attention.playTone(Attention.TONE_ALARM);
					}
				}
				Attention.vibrate(signalVibrate);
			} else if((mode == MODE_PURSUIT && pursuitSeconds() <= 10) ||
    				(mode != MODE_PURSUIT && seconds <= 10)) { // pulse before start
	        	Attention.playTone(Attention.TONE_LOUD_BEEP);
				Attention.vibrate(countdownVibrate);
			}
        } else if(seconds < 5 && !inOffset) {
        	Attention.playTone(Attention.TONE_ALARM);
        }
        drawArc(dc, center[0], center[1], center[0] - 10, theta, Gfx.COLOR_GREEN);
		// call the parent to update the time and display
        BaseView.onUpdate(dc);
    }

    //! Called when this View is removed from the screen. Save the
    //! state of this View here. This includes freeing resources from
    //! memory.
    function onHide() {
    	timer.stop();
    }

    function timerStart() {
    	timer.start(method(:onTimerUpdate), 1000, true);
    	started = true;
    }

    function onTimerUpdate() {
		if(seconds == 0) {
			if(mode == MODE_PURSUIT) {
				inOffset = true;
				View.findDrawableById("OffsetTimerLabel").setLocation(center[0], center[2]);
    			View.findDrawableById("TimerLabel").setText("");
    		} else {
				up = true;
			}
    	} else if(mode == MODE_PURSUIT && pursuitSeconds() == 0) {
    		inOffset = false;
			up = true;
			seconds = 0;
		}
    	if(up) {
    		seconds++;
    	} else {
	    	seconds--;
	    }
    	Ui.requestUpdate();
    }

    function timerDisplay() {
 		if(mode == MODE_PURSUIT) {
 			if(!up && seconds >= 0) {
 				View.findDrawableById("TimerLabel").setText(timerString());
 			}
 			View.findDrawableById("OffsetTimerLabel").setText(timerString(!up));
 		} else {
 			View.findDrawableById("TimerLabel").setText(timerString());
 		}
    }

    function timerString(withOffset) {
    	var min;
    	var sec;
    	if(withOffset) {
	    	min = pursuitSeconds() / 60;
    		sec = pursuitSeconds() % 60;
    	} else {
	    	min = seconds / 60;
    		sec = seconds % 60;
    	}
    	var timerString;
    	if(up) {
    		var hour = min / 60;
    		var realMin = min % 60;
 		   	timerString = Lang.format("$1$:$2$:$3$", [hour, realMin.format("%.2d"), sec.format("%.2d")]);
    	} else {
 		   	timerString = Lang.format("$1$:$2$", [min, sec.format("%.2d")]);
 		}

 		return timerString;
 	}

    function sync(inc) {
    	if(started) {
			if(!up && !inOffset) {
		    	timer.stop();
		    	started = false;
		    	var minutes = (seconds / 60).toNumber();
		    	if(inc) {
		    		minutes++;
		    	}
		    	seconds = minutes * 60;
		    	timerStart();
		    	Ui.requestUpdate();
		    }
		    return true;
	    } else {
	    	return false;
	    }
	}

	function stopStart() {
		if(started) {
			timer.stop();
			started = false;
		} else {
			timerStart();
		}
	}

	function pursuitSeconds() {
		return seconds + pursuitOffset;
	}

}

class STBehaviorDelegate extends Ui.BehaviorDelegate {

	function onKey(evt) {
		if (evt.getKey() == Ui.KEY_ENTER) {
			return onEnter();
		}

		return false;
	}

}

class TimerDelegate extends STBehaviorDelegate {

	function onEnter() {
		timerView.stopStart();
		return true;
	}

	function onBack() {
		if(!timerView.sync()) {
			Ui.popView(Ui.SLIDE_DOWN);
		}
		return true;
	}

	function onNextPage() {
		return timerView.sync();
	}

	function onPreviousPage() {
		return timerView.sync(true);
	}

}
