/**
 * Created by seamantec on 03/09/14.
 */
package components.lists {

import com.common.AppProperties;
import com.events.VerticalTouchEvent;
import com.store.RenderTextureContainer;
import com.utils.Assets;

import flash.geom.Rectangle;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.textures.RenderTexture;
import starling.textures.TextureSmoothing;

public class List extends Sprite {

    public static const DYNAMIC_DURATION:Number = 1; // second
    public static const PUSH_DURATION:Number = 0.5; // second

    private var _scrollable:Boolean;
    private var _active:Boolean;

    private var _scrollEndImage:Image;
    private var _scrollStartImage:Image;
    private var _scrollInImage:Image;

    private var _fling:Sprite;
    private var _flingTo:Number;
    private var _flingDistance:Number;
    private var _onFling:Boolean = false;

    private var _list:Sprite;
    private var _quad:Quad;

    private var _scrollBar:Image;
    private var _scrollBarSprite:Sprite;
    private var _scrollBarTexture:RenderTexture;
    private var _header:Sprite;

    private var _height:Number;
    private var _listHeight:Number;
    private var _startY:Number;

    private var _container:Vector.<ListItem>;

    private var _order:Function;
    private var _filters:Vector.<Function>;

    public function List(x:Number, y:Number, width:Number, height:Number, color:uint = uint.MAX_VALUE, alpha:Number = 0) {
        this.x = x;
        this.y = y;
        this.clipRect = new Rectangle(0, 0, width, height);
        _height = height;

        createList(color, alpha);

//        this.addEventListener(TouchEvent.TOUCH, onTouch);
        Starling.current.root.addEventListener(VerticalTouchEvent.BEGIN, onTouchBegin);
        Starling.current.root.addEventListener(VerticalTouchEvent.PUSH, onTouchPush);
        Starling.current.root.addEventListener(VerticalTouchEvent.MOVE, onTouchMove);
        Starling.current.root.addEventListener(VerticalTouchEvent.END, onTouchEnd);

        _scrollable = true;
        _active = true;

        _scrollBar = null;
        _header = null;

        _order = null;
        _filters = null;
    }

    private function createList(color:uint, alpha:Number):void {
        if (color != uint.MAX_VALUE) {
            _quad = new Quad(this.clipRect.width, _height, color);
            _quad.alpha = alpha;
            _quad.x = 0;
            _quad.y = 0;
            this.addChild(_quad);
        }

        _list = new Sprite();
        this.addChild(_list);

        _listHeight = 0;
        _startY = 0;
        _container = new Vector.<ListItem>();
    }

    public function addScrollBar(name:String = ""):void {
        //_scrollQuad = new Quad(6,_height, Color.argb(0.2, 14,14,14));
        if (name == "") {
            name = "sbar" + RenderTextureContainer.counter.toString()
        }
        _scrollBarTexture = RenderTextureContainer.getRenderTexture(name, 8, _height);
        _scrollBar = new Image(_scrollBarTexture)
        _scrollBar.x = this.clipRect.width - 8;
        _scrollBar.y = _startY;
        this.addChildAt(_scrollBar, this.numChildren);
        generateScrollImages();
        drawScrollBar();
    }

    private function generateScrollImages():void {
        _scrollBarSprite = new Sprite();
        _scrollStartImage = new Image(Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("scrolltop"));
        _scrollEndImage = new Image(Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("scrollbottom"));
        _scrollBarSprite.addChild(_scrollStartImage);
        _scrollBarSprite.addChild(_scrollEndImage);
        _scrollInImage = new Image(Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("scrollbody"));
        _scrollInImage.smoothing = TextureSmoothing.NONE;
        _scrollBarSprite.addChild(_scrollInImage);
    }

    public function addHeader(header:ListHeader):void {
        _header = header;
        _header.x = 0;
        _header.y = 0;
        this.addChildAt(_header, this.getChildIndex(_list) + 1);

        _startY = _header.height;
        _list.y = _startY;
        _height -= _startY;

//        if(_quad!=null) {
//            _quad.height = _height;
//        }
        if (_scrollBar != null) {
            _scrollBar.y = _startY;
            //_scrollQuad.height = _height;
        }
    }

    public function addItem(item:ListItem):void {
        item.x = 0;
        item.y = _listHeight;
        _container.push(item);
        _list.addChild(item);
        _listHeight += item.height;

        setOrder();
        redraw();
    }

    public function getItemIndex(item:ListItem):int {
        return _container.indexOf(item);
    }

    public function getItem(index:int):ListItem {
        if (index < 0 || index >= _container.length) {
            return null;
        }
        return _container[index];
    }

    public function removeItem(item:ListItem):void {
        _container.splice(_container.indexOf(item), 1);
        _list.removeChild(item);
        _listHeight -= item.height;
        item.destroy();

        redraw();
    }

    public function removeIndex(index:int):void {
        removeItem(getItem(index));
    }

    public function removeAllItem():void {
        while (_container.length > 0) {
            removeIndex(0);
        }

        redraw();
    }

    private function drawScrollBar():void {
        if (_scrollBarSprite != null) {
            if (_listHeight > _height) {
//                _scrollBar.clipRect = new Rectangle(0,Math.abs((_list.y - _startY)/_listHeight)*_height, 6,_height*(_height/_listHeight));
                var h:Number;
                if (_list.y > _startY) {
                    h = _height * (_height / (_listHeight + (_list.y - _startY)));
                } else if (_list.y < (_startY + (_height - _listHeight))) {
                    h = _height * (_height / (_listHeight + ((_startY + (_height - _listHeight)) - _list.y)));
                } else {
                    h = _height * (_height / _listHeight);
                }

//                trace(h, y);

                if (h <= (_scrollStartImage.height + _scrollEndImage.height)) {
//                    y *= (_height - (_scrollStartImage.height + _scrollEndImage.height)) / (_height - h);
                    _scrollStartImage.y = 0;
                    _scrollInImage.y = 0;
                    _scrollInImage.height = 0;
                    _scrollEndImage.y = _scrollStartImage.height;
                } else {
                    _scrollStartImage.y = 0;
                    _scrollInImage.y = _scrollStartImage.height;
                    _scrollInImage.height = h - _scrollStartImage.height - _scrollEndImage.height;
                    _scrollEndImage.y = h - _scrollEndImage.height;
                }
                _scrollBarTexture.clear();
                _scrollBarTexture.draw(_scrollBarSprite);
            } else {
//                _scrollBar.clipRect = new Rectangle(0,0, 0,0);
                _scrollBarTexture.clear();
            }
        }
    }

    private function positionScrollBar():void {
        var y:Number = 0

        if (_scrollBar != null) {
            if (_list.y >= _startY) {
                y = _startY;
            } else {
                y = (Math.abs((_list.y - _startY) / (_listHeight - _height)) * (_height ) * (1 - _scrollBarSprite.height / _height) + _startY);
            }

            _scrollBar.y = y
        }
    }

    public function scrollToStart():void {
        scrollTo(_startY);
    }

    public function scrollBox(dy:Number):void {
        var to:Number = _list.y + dy;
        if (to > _startY) {
            scrollTo(_startY);
        } else if (to < (_startY + (_height - _listHeight))) {
            scrollTo(_startY + (_height - _listHeight));
        } else {
            scrollTo(to);
        }
    }

    public function scrollToPosition(y:Number):void {
        scrollTo(_startY - y);
    }

    private function scrollTo(y:Number):void {
        if (_listHeight <= _height) {
            _list.y = _startY;
        } else if (y > _startY) {
            if (y > (_startY + (AppProperties.screenHeight / 3))) {
                y = _startY + (AppProperties.screenHeight / 3);
            }
            var dif:Number = y - _list.y;
            var exp:Number = (1 / (y - _startY)) * 15;
            _list.y = (dif < exp) ? y : (_list.y + dif * exp);
//            _list.y += (y - _list.y)*(1/(y - _startY))*15;
        } else if (y < (_startY + (_height - _listHeight))) {
            if (y < (_startY + (_height - _listHeight - (AppProperties.screenHeight / 3)))) {
                y = _startY + (_height - _listHeight - (AppProperties.screenHeight / 3));
            }
            var dif:Number = y - _list.y;
            var exp:Number = (1 / ((_startY + (_height - _listHeight)) - y)) * 15;
            _list.y = (Math.abs(dif) < exp) ? y : (_list.y + dif * exp);
//            _list.y += (y - _list.y)*(1/((_startY + (_height-_listHeight))-y))*15;
        } else {
            _list.y = y;
        }
        redraw(false);
        positionScrollBar()
    }

    public function get scrollable():Boolean {
        return _scrollable;
    }

    public function set scrollable(value:Boolean):void {
        _scrollable = value;
        if (!_scrollable && _container.length > 0) {
            pushDown();
        }
    }


    private function onTouchBegin(e:Event):void {
        if (e.data.target == this && !(_list.y > _startY || _list.y < (_startY + (_height - _listHeight)))) {
            Starling.juggler.removeTweens(_list);
            Starling.juggler.removeTweens(_fling);
        }
    }

    private function onTouchPush(e:Event):void {
        if (e.data.target == this && _scrollable && _listHeight > _height) {
            pushDown();
        }
    }

    private function onTouchMove(e:Event):void {
        if (e.data.target == this && _scrollable && _listHeight > _height) {
            Starling.juggler.removeTweens(_list);
            Starling.juggler.removeTweens(_fling);
            scrollTo(_list.y - e.data.dy);
        }
    }

    private function onTouchEnd(e:Event):void {
        if (e.data.target == this && _scrollable && _listHeight > _height) {
            if (Math.abs(e.data.speed) >= 0.3) {
                if (_fling == null) {
                    _fling = new Sprite();
                }
                _fling.y = _list.y;
                _flingDistance = e.data.speed * DYNAMIC_DURATION * 300;
                _flingTo = _list.y - _flingDistance;
                if (_flingTo > (_startY + (AppProperties.screenHeight / 3))) {
                    _flingTo = _startY + (AppProperties.screenHeight / 3);
                } else if (_flingTo < (_startY + (_height - _listHeight - (AppProperties.screenHeight / 3)))) {
                    _flingTo = _startY + (_height - _listHeight - (AppProperties.screenHeight / 3));
                }
                _onFling = true;
                Starling.juggler.tween(_fling, DYNAMIC_DURATION, {
                    transition: Transitions.EASE_OUT,
                    onUpdate: onFlingUpdate,
                    onComplete: function ():void {
                        _onFling = false;
                    },
                    y: _flingTo
                });
            } else {
                pushDown();
            }
        }
    }

    private function onFlingUpdate():void {
        if (_list.y > _startY || _list.y < (_startY + (_height - _listHeight))) {
            Starling.juggler.removeTweens(_fling);
            pushDown();
        } else {
            _list.y = _fling.y;
        }
        redraw(false);
    }

//    private function pushUp():void {
//        if(_list.y>_startY) {
//            Starling.juggler.tween(_list, (Math.abs(_flingTo-_startY)/Math.abs(_flingDistance))*DYNAMIC_DURATION, {
//                transition: Transitions.EASE_OUT,
//                onComplete: pushDown,
//                y: (_flingTo>(_startY+(_height*0.3))) ? (_startY + (_height*0.3)) : _flingTo
//            });
//        } else if(_list.y<(_startY + (_height-_listHeight))) {
//            Starling.juggler.tween(_list, (Math.abs((_startY+(_height-_listHeight)-_flingTo)/Math.abs(_flingDistance)))*DYNAMIC_DURATION, {
//                transition: Transitions.EASE_OUT,
//                onComplete: pushDown,
//                y: (_flingTo<((_startY+(_height-_listHeight))-(_height*0.3))) ? ((_startY + (_height - _listHeight)) - (_height*0.3)) : _flingTo
//            });
//        }
//    }

    private function pushDown():void {
        if (_list.y > _startY) {
            Starling.juggler.tween(_list, PUSH_DURATION, {
                transition: Transitions.EASE_OUT,
                onComplete: function ():void {
//                    drawScrollBar();
                    positionScrollBar()
                    _onFling = false;
                },
                y: _startY
            });
        } else if (_list.y < (_startY + (_height - _listHeight))) {
            Starling.juggler.tween(_list, PUSH_DURATION, {
                transition: Transitions.EASE_OUT,
                onComplete: function ():void {
//                    drawScrollBar();
                    positionScrollBar()
                    _onFling = false;
                },
                y: _startY + (_height - _listHeight)
            });
        }

        positionScrollBar()
//        drawScrollBar();
    }

    public function get length():int {
        return _container.length;
    }

    public function set order(order:Function):void {
        _order = order;
        setOrder();
    }

    public function get order():Function {
        return _order;
    }

    public function setOrder():void {
        if (_order != null && _order.length == 2) {
            _container.sort(_order);
        }
    }

    public function set filters(filters:Vector.<Function>):void {
        _filters = filters;
        redraw();
    }

    public function get filters():Vector.<Function> {
        return _filters;
    }

    public function get onFLing():Boolean {
        return _onFling;
    }

    public function set onFLing(value:Boolean):void {
        _onFling = value;
    }

    public function get active():Boolean {
        return _active;
    }

    public function set active(value:Boolean):void {
        _active = value;
    }

    public function redraw(scrollBar:Boolean = true):void {
        var height:Number = 0;
        var position:Number = (_list.y > _startY) ? 0 : ((_list.y < (_startY + (_height - _listHeight))) ? (_listHeight - _height) : Math.abs(_list.y - _startY));
        var cLength:int = _container.length;
        var i:int;
        var item:ListItem;
        if (_filters != null) {
            for (i = 0; i < cLength; i++) {
                var filter:Boolean = true;
                item = _container[i];
                var fLength:int = _filters.length;
                for (var j:int = 0; j < fLength; j++) {
                    var f:Function = _filters[j];
                    if (f.length == 1) {
                        filter = filter && (f(item) as Boolean);
                    } else if (f.length == 0) {
                        filter = filter && f();
                    } else {
                        filter = false;
                        break;
                    }
                }
                if (filter) {
                    item.visible = true;
                    item.y = height;
                    item.alpha = ((item.y > (position - item.height)) && (item.y < (position + _height))) ? 1 : 0;
                    height += item.height;
                } else {
                    item.visible = false;
                }
            }
        } else {
            for (i = 0; i < cLength; i++) {
                item = _container[i];
                item.visible = true;
                item.y = height;
                item.alpha = ((item.y > (position - item.height)) && (item.y < (position + _height))) ? 1 : 0;
                height += item.height;
            }
        }
        _listHeight = height;
        if (scrollBar) {
            drawScrollBar();
        } else {
            positionScrollBar()
        }
    }

    public override function get height():Number {
        return _height;
    }

    public override function set height(value:Number):void {
        this.clipRect = new Rectangle(0, 0, this.width, value);
        _height = value;

        scrollBox(0);

        redraw();
    }

    public function resize(w:Number, h:Number):void {
        //var heightDiff:Number = h - this.height;
//
//        this.graphics.clear();
//        this.graphics.beginFill(_color, _alpha);
//        this.graphics.drawRect(0, 0, w, h);
//        this.graphics.endFill();
//
//        if (hasHeader()) {
//            _header.setWidth(w);
//        }
//        if (hasScrollBar()) {
//            _scrollBar.x = w - 6;
//            drawScrollBar();
//        }
//
//        _list.graphics.clear();
//        _list.graphics.beginFill(0xFFFFFF, 0);
//        _list.graphics.drawRect(0, 0, w, h);
//        _list.graphics.endFill();
//
//        var rect:Rectangle = _list.scrollRect;
//        rect.width = w;
//        rect.height = (hasHeader()) ? h - _header.getHeight() : h;
//        _list.scrollRect = rect;
//        scrollBox(0);
//
//        filter(_filters);
        /*
         for(var i:int=0; i<_container.length; i++) {
         _container[i].setWidth(w);
         }
         */
    }
}
}
