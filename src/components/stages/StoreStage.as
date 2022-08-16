/**
 * Created by pepusz on 14. 11. 26..
 */
package components.stages {
import com.common.AppProperties;
import com.inAppPurchase.AndroidStore;
import com.inAppPurchase.CommonStore;
import com.inAppPurchase.IOSStore;
import com.inAppPurchase.ProductInfo;
import com.ui.StageBtn;
import com.utils.FontFactory;

import components.EdoStage;
import components.TopBar;

import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.text.TextField;

public class StoreStage extends EdoStage {
    public static const ID:String = "store_stage";
    private var content:Sprite = new Sprite();
//    private var loadingText:TextField = new TextField()
    private var loading:TextField;

    private var alarmBtn:StageBtn;
    private var instrumentsBtn:StageBtn;
    private var restoreBtn:StageBtn;

    public function StoreStage() {
        super(ID, "In App Store");

        this.y = TopBar.HEIGHT;

        CommonStore.instance.addEventListener("alarm-enabled", alarm_enabledHandler);
        CommonStore.instance.addEventListener("instruments-enabled", instruments_enabledHandler);
        if (AppProperties.isIOS) {
            IOSStore.instance.addEventListener("product-infos-ready", iosstore_product_infos_readyHandler);
            IOSStore.instance.addEventListener("product-infos-failed", store_product_infos_failedHandler);
        } else {
            AndroidStore.instance.addEventListener("product-infos-ready", androidstore_product_infos_readyHandler);
            AndroidStore.instance.addEventListener("product-infos-failed", store_product_infos_failedHandler);
        }

        content.visible = false;
        loading = FontFactory.getWhiteCenterFont(AppProperties.screenWidth, 30);
        loading.text = "LOADING...";
        this.addChild(content);
        this.addChild(loading);
        createButtons();
    }

    private function createButtons():void {
        alarmBtn = new StageBtn("alarm");
        instrumentsBtn = new StageBtn("instr");
        restoreBtn = new StageBtn("restore");
        alarmBtn.x = 160;
        instrumentsBtn.x = 160;
        restoreBtn.x = 160;
        alarmBtn.y = 30;

        instrumentsBtn.y = alarmBtn.y + alarmBtn.height + 10;
        restoreBtn.y = instrumentsBtn.y + instrumentsBtn.height + 10;

        content.addChild(alarmBtn);
        content.addChild(instrumentsBtn);
        content.addChild(restoreBtn);
        var alarmLabel:TextField = FontFactory.getWhiteCenterFont(100, 30);
        alarmLabel.text = "Alarm";
        alarmLabel.y = alarmBtn.y;
        alarmLabel.x = 10;
        content.addChild(alarmLabel);
        var instrumentsLabel:TextField = FontFactory.getWhiteCenterFont(100, 30);
        instrumentsLabel.text = "Instruments";
        instrumentsLabel.y = instrumentsBtn.y;
        instrumentsLabel.x = 10;
        content.addChild(instrumentsLabel);
        var restoreLabel:TextField = FontFactory.getWhiteCenterFont(100, 30);
        restoreLabel.text = "Restore";
        restoreLabel.y = restoreBtn.y;
        restoreLabel.x = 10;
        content.addChild(restoreLabel);

        alarmBtn.addEventListener(TouchEvent.TOUCH, alarmBtn_touchHandler);
        instrumentsBtn.addEventListener(TouchEvent.TOUCH, instrumentsBtn_touchHandler);
        restoreBtn.addEventListener(TouchEvent.TOUCH, restoreBtn_touchHandler);
    }


    override public function activate():void {
        super.activate();
        content.visible = false;
        loading.visible = true;
        DS::device{
            if (AppProperties.isIOS) {
                if (!IOSStore.instance.productsReady) {
                    IOSStore.instance.loadProducts();
                } else {
                    loadPricesForButtonsFromIOSStore();
                }
            } else {
                if (!AndroidStore.instance.productsReady) {
                    AndroidStore.instance.loadProducts();
                } else {
                    loadPricesForButtonsFromAndroidStore();
                }
            }
        }

    }

    private function iosstore_product_infos_readyHandler(event:Event):void {
        loadPricesForButtonsFromIOSStore();
    }

    private function loadPricesForButtonsFromIOSStore():void {
        loading.visible = false;
        for (var i:int = 0; i < IOSStore.instance.products.length; i++) {
            var info:ProductInfo = IOSStore.instance.products[i];
            if (info.identifier === CommonStore.alarmProductId) {
                alarmBtn.text = info.fullPriceTag;
            } else if (info.identifier === CommonStore.instrumentsProductId) {
                instrumentsBtn.text = info.fullPriceTag;
            }
        }
        content.visible = true;
        setButtonPurchaseState();
    }

    private function androidstore_product_infos_readyHandler(event:Event):void {
        loadPricesForButtonsFromAndroidStore();
    }

    private function loadPricesForButtonsFromAndroidStore():void {
        loading.visible = false;
        for (var i:int = 0; i < AndroidStore.instance.products.length; i++) {
            var info:ProductInfo = AndroidStore.instance.products[i];
            if (info.identifier === CommonStore.alarmProductId) {
                alarmBtn.text = info.price;
            } else if (info.identifier === CommonStore.instrumentsProductId) {
                instrumentsBtn.text = info.price;
            }
        }
        content.visible = true;
    }

    private function alarmBtn_touchHandler(event:TouchEvent):void {
        var touch:Touch = event.getTouch(stage);
        if (touch) {
            if (touch.phase == TouchPhase.ENDED) {
                (AppProperties.isIOS) ? IOSStore.instance.buyAlarms() : AndroidStore.instance.buyAlarms();
            }
        }
    }

    private function instrumentsBtn_touchHandler(event:TouchEvent):void {
        var touch:Touch = event.getTouch(stage);
        if (touch) {
            if (touch.phase == TouchPhase.ENDED) {
                (AppProperties.isIOS) ? IOSStore.instance.buyInstruments() : AndroidStore.instance.buyInstruments();
            }
        }
    }

    private function restoreBtn_touchHandler(event:TouchEvent):void {
        var touch:Touch = event.getTouch(stage);
        if (touch) {
            if (touch.phase == TouchPhase.ENDED) {
                (AppProperties.isIOS) ? IOSStore.instance.restore() : AndroidStore.instance.restore();
            }
        }
    }

    private function store_product_infos_failedHandler(event:Event):void {
        throw new Error("PRODUCT INFO FAILED");
    }


    private function purchase_failedHandler(event:Event):void {
        trace("PURCHASE FAILED")
    }

    private function alarm_enabledHandler(event:Event):void {
        setButtonPurchaseState();
    }

    private function setButtonPurchaseState():void {
        if (CommonStore.instance.isAlarmEnabled) {
            alarmBtn.text = "---"
            alarmBtn.removeEventListener(TouchEvent.TOUCH, alarmBtn_touchHandler);
        }
        if (CommonStore.instance.isInstrumentsEnabled) {
            instrumentsBtn.text = "---"
            instrumentsBtn.removeEventListener(TouchEvent.TOUCH, instrumentsBtn_touchHandler);
        }
//        if (CommonStore.instance.isAlarmEnabled && CommonStore.instance.isInstrumentsEnabled) {
//            restoreBtn.text = "---"
//            restoreBtn.removeEventListener(TouchEvent.TOUCH, restoreBtn_touchHandler);
//        }
    }

    private function instruments_enabledHandler(event:Event):void {
        setButtonPurchaseState();
    }
}
}
