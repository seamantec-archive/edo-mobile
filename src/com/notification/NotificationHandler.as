/**
 * Created by seamantec on 03/07/14.
 */
package com.notification {
import com.common.AppProperties;

public class NotificationHandler {

    private static var _container:Vector.<NotificationWindow>;

    public function NotificationHandler() {
    }

    public static function createWarning(type:int, msg:String, priority:int = 0, options:Object = null):void {
        createWindow(new WarningWindow(type, msg, priority, options));
    }

    public static function createAlert(type:int, msg:String, priority:int, yesCallback:Function, noCallback:Function = null, options:Object = null):void {
        createWindow(new AlertWindow(type, msg, priority, yesCallback, noCallback, options));
    }

    private static function createWindow(window:NotificationWindow):void {
        if (window == null) {
            return;
        }
        if (_container == null) {
            _container = new Vector.<NotificationWindow>();
        }
        window.x = 16;
        if (_container.length > 0) {
            window.y = _container[_container.length - 1].y + 25;
            if ((window.y + window.height) > AppProperties.screenHeight) {
                window.y = AppProperties.screenHeight - window.height;
            }
        } else {
            EdoMobile.notificationBackgroundChange();
            window.y = AppProperties.screenHeight*0.33;
        }
        addWindow(window);
    }

    public static function close(window:NotificationWindow):void {
        var length:int = _container.length;
        for (var i:int = 0; i < length; i++) {
            if (_container[i] == window) {
                _container.splice(i, 1);
            }
        }

        if(_container.length==0) {
            EdoMobile.notificationBackgroundChange();
        }
    }

    private static function addWindow(window:NotificationWindow):void {
        var hasSame:Boolean = false;
        var item:NotificationWindow;
        var length:int = _container.length;
        for (var i:int = 0; i < length; i++) {
            item = _container[i];
            if (window.getType() == item.getType()) {
                if (window.getPriority() <= item.getPriority()) {
                    window.x = item.x;
                    window.y = item.y;
                    item.close();
                    item = null;
                    _container[i] = window;
                    hasSame = true;
                } else {
                    window.close();
                    window = null;
                    return;
                }
            }
        }
        if (!hasSame) {
            _container.push(window);
        }
        EdoMobile.notifications.addChild(window);
    }
}
}
