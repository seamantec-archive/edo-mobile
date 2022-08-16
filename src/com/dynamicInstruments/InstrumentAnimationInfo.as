/**
 * Created by seamantec on 09/10/14.
 */
package com.dynamicInstruments {

import flash.utils.Dictionary;

public class InstrumentAnimationInfo {

    public var prefix:String;
    public var children:Dictionary;

    public function InstrumentAnimationInfo(prefix:String, children:Dictionary) {
        this.prefix = prefix;
        this.children = children;
    }
}
}
