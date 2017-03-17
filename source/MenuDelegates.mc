using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Time as Time;

class TimerOptionsDelegate extends Ui.MenuInputDelegate {
    function onMenuItem(item) {
        if(item == :timer_option_standard) {
			mode = MODE_STANDARD;
			Ui.popView(Ui.SLIDE_LEFT);
			Ui.pushView(new Rez.Menus.StandardOptions(), new StandartOptionsDelegate(), Ui.SLIDE_LEFT);
		} else if(item == :timer_option_pursuit) {
			mode = MODE_PURSUIT;
			Ui.popView(Ui.SLIDE_LEFT);
			Ui.pushView(new Rez.Menus.PursuitOptions(), new PursuitOptionsDelegate(), Ui.SLIDE_LEFT);
        }
    }
}

class PursuitOptionsDelegate extends Ui.MenuInputDelegate {

	hidden var offsets = {
		:pursuit_option_30 => 30,
		:pursuit_option_60 => 60,
		:pursuit_option_90 => 90,
		:pursuit_option_120 => 120,
		:pursuit_option_150 => 150,
		:pursuit_option_180 => 180,
		:pursuit_option_210 => 210,
		:pursuit_option_240 => 240
	};

	function onMenuItem(item) {
		if(item == :pursuit_option_custom) {
			Ui.popView(Ui.SLIDE_LEFT);
			Ui.pushView(new Ui.NumberPicker(Ui.NUMBER_PICKER_TIME_MIN_SEC, new Time.Duration(0)), new PursuitTimeDelegate(), Ui.SLIDE_LEFT);
		} else {
			pursuitOffset = offsets[item];
		}
	}
}

class PursuitTimeDelegate extends Ui.NumberPickerDelegate {
    function onNumberPicked(value) {
        pursuitOffset = value.value();
    }
}

class StandartOptionsDelegate extends Ui.MenuInputDelegate {

	hidden var initvalues = {
		:standard_option_60 => 60,
		:standard_option_120 => 120,
		:standard_option_180 => 180,
		:standard_option_240 => 240,
		:standard_option_300 => 300,
		:standard_option_360 => 360
	};

	function onMenuItem(item) {
		timerInitValue = initvalues[item];
	}
}
