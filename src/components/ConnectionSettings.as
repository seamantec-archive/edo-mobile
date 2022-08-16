/**
 * Created by pepusz on 2014.09.04..
 */
package components {
import com.events.SocketEvent;
import com.sailing.socket.SocketDispatcher;
import com.store.SettingsConfigs;
import com.ui.RadioButtonBar;
import com.ui.StageBtn;
import com.utils.Assets;
import com.utils.FontFactory;

import feathers.controls.TextInput;
import feathers.controls.text.StageTextTextEditor;
import feathers.core.ITextEditor;

import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.TouchEvent;
import starling.text.TextField;
import starling.utils.HAlign;
import starling.utils.VAlign;

public class ConnectionSettings extends Sprite {

    private static var _hostLabel:TextField;
    private static var _hostInput:TextInput;
    private static var _portLabel:TextField;
    private static var _portInput:TextInput;
    private static var _ownPortLabel:TextField;
    private static var _ownPortInput:TextInput;
    private static var _connectBtn:StageBtn;
    private static var _simulationBtn:StageBtn;
    private static var _connectionType:RadioButtonBar;

    public function ConnectionSettings() {
        super();
        this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        SocketDispatcher.instance.addEventListener(SocketEvent.CONNECTED, connectedHandler);
        SocketDispatcher.instance.addEventListener(SocketEvent.DISCONNECTED, disconnectedHandler);
    }

    private function addHostAndPort():void {
        if (_connectionType == null) {
            _connectionType = new RadioButtonBar(0, 0, ["TCP", "UDP"]);
            _connectionType.selected = SocketDispatcher.instance.connectionType
            _connectionType.addEventListener(Event.CHANGE, connectionType_changeHandler);
            _connectionType.x = UnitSettings.PADDING;
            _connectionType.y = 0;
            this.addChild(_connectionType);
        }

        if (_hostLabel == null) {
            _hostLabel = FontFactory.getWhiteLeftFont(Menu.WIDTH, 20, 14);
            _hostLabel.hAlign = HAlign.CENTER;
            _hostLabel.vAlign = VAlign.CENTER;
            _hostLabel.text = "Host (Transmitter's IP address)";
            _hostLabel.x = 0;
            _hostLabel.y = _connectionType.y + _connectionType.height + 5;
            this.addChild(_hostLabel);
        }
        if (_hostInput == null) {
            _hostInput = new TextInput();
            _hostInput.paddingLeft = 10;
            _hostInput.paddingTop = 5;
            _hostInput.backgroundDisabledSkin = new Image(Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("input_field"));
            _hostInput.backgroundFocusedSkin = _hostInput.backgroundDisabledSkin;
            _hostInput.backgroundSkin = _hostInput.backgroundDisabledSkin;
            _hostInput.width = _hostInput.backgroundDisabledSkin.width * 0.9;
            _hostInput.height = _hostInput.backgroundDisabledSkin.height;
            _hostInput.x = (Menu.WIDTH - _hostInput.width) / 2;
            _hostInput.y = _hostLabel.y + _hostLabel.height + 10;
            _hostInput.textEditorFactory = function ():ITextEditor {
                var editor:StageTextTextEditor = new StageTextTextEditor();
                editor.fontFamily = "Amble";
                editor.fontSize = 15;
                editor.multiline = false;
                editor.y = 0;
                editor.color = 0x000;
                return editor;
            };
            _hostInput.text = SettingsConfigs.instance.host;
            _hostInput.addEventListener(Event.CHANGE, hostInput_changeHandler);
            addChild(_hostInput);
        }
        if (_portLabel == null) {
            _portLabel = FontFactory.getWhiteLeftFont(Menu.WIDTH, 20, 14);
            _portLabel.hAlign = HAlign.CENTER;
            _portLabel.vAlign = VAlign.CENTER;
            _portLabel.text = "Host Port";
            _portLabel.x = 0;
            _portLabel.y = _hostInput.y + _hostInput.height + 5;
            this.addChild(_portLabel);

        }
        if (_portInput == null) {
            _portInput = new TextInput();
            _portInput.paddingLeft = 10;
            _portInput.paddingTop = 5;
            _portInput.backgroundDisabledSkin = new Image(Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("input_field"));
            _portInput.backgroundFocusedSkin = _portInput.backgroundDisabledSkin;
            _portInput.backgroundSkin = _portInput.backgroundDisabledSkin;
            _portInput.width = _portInput.backgroundDisabledSkin.width * 0.9;
            _portInput.height = _portInput.backgroundDisabledSkin.height;
            _portInput.textEditorFactory = function ():ITextEditor {
                var editor:StageTextTextEditor = new StageTextTextEditor();
                editor.fontFamily = "Amble";
                editor.fontSize = 15;
                editor.color = 0x000;
                return editor;
            };
            _portInput.x = (Menu.WIDTH - _portInput.width) / 2;
            _portInput.y = _portLabel.y + _portLabel.height + 5;
            _portInput.restrict = "0-9";
            _portInput.text = SettingsConfigs.instance.port + "";
            _portInput.addEventListener(Event.CHANGE, portInput_changeHandler);
            addChild(_portInput);
        }

        if (_ownPortLabel == null) {
            _ownPortLabel = FontFactory.getWhiteLeftFont(Menu.WIDTH, 20, 14);
            _ownPortLabel.hAlign = HAlign.CENTER;
            _ownPortLabel.vAlign = VAlign.CENTER;
            _ownPortLabel.text = "Device Local Port";
            _ownPortLabel.x = 0;
            _ownPortLabel.y = _portInput.y + _portInput.height + 5;
            _ownPortLabel.visible = (_connectionType.selected == 1)
            this.addChild(_ownPortLabel);

        }
        if (_ownPortInput == null) {
            _ownPortInput = new TextInput();
            _ownPortInput.paddingLeft = 10;
            _ownPortInput.paddingTop = 5;
            _ownPortInput.backgroundDisabledSkin = new Image(Assets.uiAssets.getTextureAtlas("ui_elements").getTexture("input_field"));
            _ownPortInput.backgroundFocusedSkin = _ownPortInput.backgroundDisabledSkin;
            _ownPortInput.backgroundSkin = _ownPortInput.backgroundDisabledSkin;
            _ownPortInput.width = _ownPortInput.backgroundDisabledSkin.width * 0.9;
            _ownPortInput.height = _ownPortInput.backgroundDisabledSkin.height;
            _ownPortInput.textEditorFactory = function ():ITextEditor {
                var editor:StageTextTextEditor = new StageTextTextEditor();
                editor.fontFamily = "Amble";
                editor.fontSize = 15;
                editor.color = 0x000;
                return editor;
            };
            _ownPortInput.x = (Menu.WIDTH - _portInput.width) / 2;
            _ownPortInput.y = _ownPortLabel.y + _ownPortLabel.height + 5;
            _ownPortInput.restrict = "0-9";
            _ownPortInput.text = SettingsConfigs.instance.ownUDPPort + "";
            _ownPortInput.addEventListener(Event.CHANGE, ownPortInput_changeHandler);
            _ownPortInput.visible = (_connectionType.selected == 1)
            addChild(_ownPortInput);
        }


    }

    private function addedToStageHandler(event:Event):void {
        addHostAndPort();
        if (_connectBtn == null) {
            _connectBtn = new StageBtn("Connect");
            _connectBtn.x = (Menu.WIDTH / 4) - (_connectBtn.width / 2) + 5;
            _connectBtn.y = _portInput.y + _portInput.height + 5;
            _connectBtn.addEventListener(TouchEvent.TOUCH, connectBtn_touchHandler);
            this.addChild(_connectBtn);
        }
        if (_simulationBtn == null) {
            _simulationBtn = new StageBtn("Start simulation");
            _simulationBtn.x = ((Menu.WIDTH / 4) * 3) - (_simulationBtn.width / 2) - 5;
            _simulationBtn.y = _portInput.y + _portInput.height + 5;
            _simulationBtn.addEventListener(TouchEvent.TOUCH, simulationBtn_touchHandler);
            this.addChild(_simulationBtn);
        }
        setPortsVisibleAndButtonsPositions();

    }

    private function hostInput_changeHandler(event:Event):void {
        SettingsConfigs.instance.host = _hostInput.text;
    }

    private function portInput_changeHandler(event:Event):void {
        SettingsConfigs.instance.port = Number(_portInput.text)
    }

    private function connectBtn_touchHandler(event:TouchEvent):void {
        if (_connectBtn.touchIsEnd(event)) {
            SocketDispatcher.instance.connectDisconnect();
        }
    }

    private function connectedHandler(event:SocketEvent):void {
        _connectBtn.text = "Disconnect";
        EdoMobile.topBar.menuBtn.turnConnected()
    }

    private function disconnectedHandler(event:SocketEvent):void {
        _connectBtn.text = "Connect";
        EdoMobile.topBar.menuBtn.turnDisconnected()
    }

    public static function set enableSimulation(value:Boolean):void {
        _simulationBtn.enabled = value;
        _simulationBtn.text = "Start simulation";
    }

    private function simulationBtn_touchHandler(event:TouchEvent):void {
        if (_simulationBtn.touchIsEnd(event) && _simulationBtn.enabled) {
            if (SocketDispatcher.instance.isDemoConnected) {
                SocketDispatcher.instance.stopDemoConnect();
                _simulationBtn.text = "Start simulation";
            } else {
                SocketDispatcher.instance.connectDemo();
                _simulationBtn.text = "Stop simulation";
            }
        }
    }

    private function connectionType_changeHandler(event:Event):void {
        SocketDispatcher.instance.connectionType = _connectionType.selected;
        setPortsVisibleAndButtonsPositions();
    }

    private function setPortsVisibleAndButtonsPositions():void {
        _ownPortInput.visible = (_connectionType.selected == 1)
        _ownPortLabel.visible = (_connectionType.selected == 1)
        if (_connectionType.selected == 0) {
            _connectBtn.y = _portInput.y + _portInput.height + 5;
            _simulationBtn.y = _portInput.y + _portInput.height + 5;
        } else {
            _connectBtn.y = _ownPortInput.y + _ownPortInput.height + 5;
            _simulationBtn.y = _ownPortInput.y + _ownPortInput.height + 5;
        }
    }

    private function ownPortInput_changeHandler(event:Event):void {
        SettingsConfigs.instance.ownUDPPort = Number(_ownPortInput.text)
    }
}
}
