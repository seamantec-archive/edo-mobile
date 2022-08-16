/**
 * Created by seamantec on 22/01/15.
 */
package com.utils {
import flash.geom.Point;

import starling.display.Image;
import starling.textures.Texture;
import starling.utils.deg2rad;

public class ImageMask extends Image {

    public static const STATUS_ALL:uint = 0;
    public static const STATUS_MASKED:uint = 1;

    private const CENTER:Point = new Point(0.5,0.5);

    private var _coords:Vector.<Point>;
    private var _iCoords:Vector.<Point>;
    private var _h0:int;
    private var _h1:int;
    private var _v0:int;
    private var _v1:int;

    private var _status:uint;

    public function ImageMask(texture:Texture, coords:Array, h0:int,h1:int, v0:int,v1:int) {
        super(texture);

        _coords = new Vector.<Point>();
        for(var i:int=0; i<8; i+=2) {
            _coords.push(new Point(coords[i], coords[i+1]));
        }
        _h0 = h0;
        _h1 = h1;
        _v0 = v0;
        _v1 = v1;

        _iCoords = new Vector.<Point>(_coords.length);

        _status = STATUS_MASKED;
    }

    public function all():void {
        if(_status==STATUS_MASKED) {
            setCoords(_coords);

            _status = STATUS_ALL;
        }
    }

    public function mask(angle:Number):void {
        var px:Number = 0.5 + 0.5*Math.cos(deg2rad(angle));
        var py:Number = 0.5 + 0.5*Math.sin(deg2rad(angle));

        var hIntersection:Point = getIntersection(0.5,0.5, px,py, _coords[_h1].x,_coords[_h1].y, _coords[_h0].x,_coords[_h0].y);
        var vIntersection:Point = getIntersection(0.5,0.5, px,py, _coords[_v1].x,_coords[_v1].y, _coords[_v0].x,_coords[_v0].y);

        initICoords();
        if(hIntersection!=null && between(hIntersection.x, _coords[_h0].x,_coords[_h1].x)) {
            _iCoords[_h1].x = hIntersection.x;

            if(angle>90 && angle<=135) {
                _iCoords[_v1].x = _iCoords[_h1].x;
                _iCoords[_v1].y = _iCoords[_h1].y;
            } else if(angle>270 && angle<=315) {
                _iCoords[_v1] = CENTER;
            }
        } else if(vIntersection!=null && between(vIntersection.y, _coords[_v0].y,_coords[_v1].y)) {
            _iCoords[_v1].y = vIntersection.y;

            if(angle>0 && angle<=45) {
                _iCoords[_h1].x = _iCoords[_v1].x;
                _iCoords[_h1].y = _iCoords[_v1].y;
            } else if(angle>180 && angle<=225) {
                _iCoords[_h1] = CENTER;
            }
        }

        setCoords(_iCoords);

        _status = STATUS_MASKED;
    }

    private function initICoords():void {
        _iCoords[0] = _coords[0].clone();
        _iCoords[1] = _coords[1].clone();
        _iCoords[2] = _coords[2].clone();
        _iCoords[3] = _coords[3].clone();
    }

    private function setCoords(coords:Vector.<Point>):void {
        this.visible = true;

        mVertexData.setPosition(0, coords[0].x*texture.width,coords[0].y*texture.height);
        mVertexData.setPosition(1, coords[1].x*texture.width,coords[1].y*texture.height);
        mVertexData.setPosition(2, coords[2].x*texture.width,coords[2].y*texture.height);
        mVertexData.setPosition(3, coords[3].x*texture.width,coords[3].y*texture.height);

        mVertexData.setTexCoords(0, coords[0].x,coords[0].y);
        mVertexData.setTexCoords(1, coords[1].x,coords[1].y);
        mVertexData.setTexCoords(2, coords[2].x,coords[2].y);
        mVertexData.setTexCoords(3, coords[3].x,coords[3].y);

        onVertexDataChanged();
    }

    private static function between(x:Number, x0:Number, x1:Number):Boolean {
        return (x0<x1) ? (x>=x0 && x<=x1) : (x>=x1 && x<=x0);
    }

    private static function getIntersection(x1:Number, y1:Number, x2:Number, y2:Number, x3:Number, y3:Number, x4:Number, y4:Number):Point {
        if((((x1-x2)*(y3-y4))-((y1-y2)*(x3-x4)))==0) {
            return null;
        }

        return new Point(
            ((x1*y2 - y1*x2)*(x3 - x4) - (x1 - x2)*(x3*y4 - y3*x4))/((x1 - x2)*(y3 - y4) - (y1 - y2)*(x3 - x4)),
            ((x1*y2 - y1*x2)*(y3 - y4) - (y1 - y2)*(x3*y4 - y3*x4))/((x1 - x2)*(y3 - y4) - (y1 - y2)*(x3 - x4))
        );

    }
}
}
