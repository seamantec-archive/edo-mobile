/**
 * Created by seamantec on 11/02/15.
 */
package components {
import com.common.AppProperties;
import com.harbor.PolarFile;
import com.polar.PolarContainer;
import com.utils.FontFactory;
import com.utils.QuadBatcher;

import starling.display.Quad;
import starling.events.EnterFrameEvent;

import starling.text.TextField;

public class PolarLoadingScreen extends QuadBatcher {

    private var _readyToLoad:Boolean;
    private var _polarFile:PolarFile;

    public function PolarLoadingScreen() {
        super(AppProperties.screenWidth,AppProperties.screenHeight, "polarLoadingScreen");

        var bg:Quad = new Quad(AppProperties.screenWidth,AppProperties.screenHeight, 0x0);
        bg.alpha = 0.5;
        this.addDisplayObject(bg);

        var text:TextField = FontFactory.getWhiteCenterFont(AppProperties.screenWidth,AppProperties.screenHeight);
        text.text = "Doing some maths...";
        this.addDisplayObject(text);

        _quadBatch.visible = false;

        _readyToLoad = false;
    }

    public function get visible():Boolean {
        return _quadBatch.visible;
    }

    public function set visible(value:Boolean):void {
        _quadBatch.visible = value;
    }

    public function set polarFile(value:PolarFile):void {
        visible = true;
        _polarFile = value;

        _quadBatch.addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrame);
    }

    private function onEnterFrame(event:EnterFrameEvent):void {
        if(_readyToLoad) {
            _readyToLoad = false;

            _quadBatch.removeEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrame);

            var p:Array = _polarFile.filePath.split(".");
            PolarContainer.instance.openPolarFromFile(_polarFile.getFile(), false, _polarFile.name + "." + p[p.length-1]);
        } else {
            _readyToLoad = true;
        }
    }
}
}
