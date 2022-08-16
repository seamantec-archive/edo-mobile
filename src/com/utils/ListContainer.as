/**
 * Created by seamantec on 19/02/15.
 */
package com.utils {
import components.lists.List;

public class ListContainer {

    private static var _instance:ListContainer;

    private var _container:Vector.<List>;
    private var _length:int;
    private var _active:List;

    public function ListContainer() {
        _container = new Vector.<List>();
        _length = 0;
    }

    public static function get instance():ListContainer {
        if(_instance==null) {
            _instance = new ListContainer();
        }

        return _instance;
    }

    public function add(list:List):void {
        _container.push(list);
        _length++;
    }

    public function remove(list:List):void {
        for(var i:int=0; i<_length; i++) {
            if(_container[i]==list) {
                _container.splice(i, 1);
                _length--;
                break;
            }
        }
    }

    public function close():void {
        _active = null;

        var item:List;
        for(var i:int=0; i<_length; i++) {
            item = _container[i];
            if(item.visible) {
                _active = item;
                item.visible = false;
            }
        }
    }

    public function get active():List {
        return _active;
    }
}
}
