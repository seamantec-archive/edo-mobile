/**
 * Created by seamantec on 03/12/14.
 */
package com.dynamicInstruments {

import com.utils.QuadBatcher;

import starling.display.Image;
import starling.textures.RenderTexture;

public dynamic class InstrumentQuadBatcher extends QuadBatcher {


    private var _width:Number;
    private var _height:Number;

    public function InstrumentQuadBatcher(width:Number = -1, height:Number = -1, name:String = "") {
        super(width, height, name);
        _width = width;
        _height = height;
        trace("Instrument quad batch", name)
    }


    public override function render():void {
        clearTexture();
        _quadBatch.reset();
        //HACK, ha eltunt belole a sprite mert mashoz hozzaadtuk akkor
        if (_sprite.numChildren != _container.length) {
            _sprite.removeChildren(0, _sprite.numChildren - 1)
            for (var i:int = 0; i < _container.length; i++) {
                _sprite.addChild(_container[i]);
            }
        }

        if (_renderTexture == null || _width == -1 || _width == -1) {
            if (_renderTexture != null) {
                _renderTexture.dispose();
            }
            _renderTexture = new RenderTexture((_width <= 0) ? _sprite.width : _width, (_height <= 0) ? _sprite.height : _height, false);
            _width = _sprite.width;
            _height = _sprite.height;
        }
        _renderTexture.draw(_sprite);
        if (_img == null) {
            _img = new Image(_renderTexture);
        } else {
            _img.texture = _renderTexture;
        }
        _quadBatch.addImage(_img);
    }

    public function get width():Number {
        return _width;
    }

    public function get height():Number {
        return _height;
    }
}
}
