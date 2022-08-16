/**
 * Created by pepusz on 15. 01. 12..
 */
package com.store {
import flash.utils.Dictionary;

import starling.textures.RenderTexture;

public class RenderTextureContainer {

    private static var container:Object = new Object();
    private static var _counter:uint = 0;

    public static function getRenderTexture(name:String, w:int, h:int):RenderTexture {
        if(container[name] == null){
            trace("naew render texture")
            container[name] = new RenderTexture(w, h, false);
        }
        return container[name] as RenderTexture;
    }

    public static function get counter():uint {
        return _counter++;
    }
}
}
