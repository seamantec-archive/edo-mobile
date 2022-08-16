/**
 * Created by pepusz on 14. 12. 16..
 */
package components {
import com.common.AppProperties;
import com.utils.Assets;

import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;

public class StageBottom extends Sprite {
    private var actualIndex:uint = 0;
    private var scale:Number = (1 / AppProperties.screenScaleRatio) * 0.75;
    private var _activeIcon:Image;
    private var startXPosition:int;
    private var deactiveIcons:Vector.<Image> = new <Image>[];

    public function StageBottom() {
        this.y = AppProperties.screenHeight - StageContainer.BOTTOM_HEIGHT;
        this.addChild(new Quad(AppProperties.screenWidth, StageContainer.BOTTOM_HEIGHT, 0x7b7b7b));
        _activeIcon = new Image(Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("page_off"));
//        _activeIcon.width = StageContainer.BOTTOM_HEIGHT;
//        _activeIcon.height = StageContainer.BOTTOM_HEIGHT;
        _activeIcon.y = (StageContainer.BOTTOM_HEIGHT/2) - (_activeIcon.height/2);
        this.addChild(_activeIcon);
    }


    public function addStage():void {
        var deactiveIcon:Image = new Image(Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("page_on"));
//        deactiveIcon.width = StageContainer.BOTTOM_HEIGHT;
//        deactiveIcon.height = StageContainer.BOTTOM_HEIGHT;
        deactiveIcon.y = (StageContainer.BOTTOM_HEIGHT/2) - (deactiveIcon.height/2);
        deactiveIcons.push(deactiveIcon);
        reArrangeDisabledIcons();
        this.addChild(deactiveIcon);
    }

    public function setActualIndex(index:uint):void {
        deactiveIcons[actualIndex].visible = true;
        deactiveIcons[index].visible = false;
        _activeIcon.x = startXPosition + (index * _activeIcon.width * 2);
        actualIndex = index;

    }

    private function calculateStartPosition() {
        startXPosition = (AppProperties.screenWidth / 2) - ((_activeIcon.width * 2 * deactiveIcons.length) / 2);
    }

    private function reArrangeDisabledIcons():void {
        calculateStartPosition();
        for (var i:int = 0; i < deactiveIcons.length; i++) {
            deactiveIcons[i].x = startXPosition + (i * _activeIcon.width * 2);
        }
    }

}

}
