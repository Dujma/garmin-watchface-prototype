using Toybox.Background;
using Toybox.System as Sys;

(:background)
class prototypewatchfaceServiceDelegate extends Sys.ServiceDelegate {
	function initialize() {
		Sys.ServiceDelegate.initialize();
	}
	
    function onTemporalEvent() {
    	var now = Sys.getClockTime();
    	var ts = now.hour + ":" + now.min.format("%02d") + ":" + now.sec.format("%02d");
    	
        Background.exit(ts);
    }
}