/**
 * Created with IntelliJ IDEA.
 * User: pepusz
 * Date: 2013.09.18.
 * Time: 20:47
 * To change this template use File | Settings | File Templates.
 */
package com.polar {
import starling.events.Event;

public class PolarEvent extends Event {
    public var polarData:PolarData;
    public static const POLAR_EVENT:String = "PolarEvent"
    public static const POLAR_RESET_EVENT:String = "PolarResetEvent"
    public static const POLAR_READY:String = "PolarReadyEvent"  //NOT USED FOR SERIOUS THING JUST FOR SETTINGS
    public static const SHOW_FORCE_DOTS:String = "polarShowForceDots" //NOT USED FOR SERIOUS THING JUST FOR SETTINGS
    public static const POLAR_CLOUD_READY:String = "PolarCloudReadyEvent"
    public static const POLAR_FILE_LOADED:String = "PolarFileLoadedEvent"

    public function PolarEvent(polarData:PolarData, type:String = POLAR_EVENT) {
        super(type);
        this.polarData = polarData;
    }
}
}
