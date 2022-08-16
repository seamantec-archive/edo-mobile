/**
 * Created by seamantec on 27/11/14.
 */
package com.inAppPurchase {

import com.freshplanet.ane.AirInAppPurchase.InAppPurchase;
import com.freshplanet.ane.AirInAppPurchase.InAppPurchaseEvent;

import starling.events.Event;
import starling.events.EventDispatcher;

public class AndroidStore extends EventDispatcher {



    private const PRODUCT_IDS:Array = [CommonStore.alarmProductId, CommonStore.instrumentsProductId, CommonStore.polarProductId];

    private static var _instance:AndroidStore;

    private var _products:Vector.<ProductInfo>;
    private var _productsReady:Boolean;

    private var _inAppPurchase:InAppPurchase;

    public function AndroidStore() {
        _inAppPurchase = InAppPurchase.getInstance();
        _inAppPurchase.addEventListener(InAppPurchaseEvent.PURCHASE_SUCCESSFULL, onPurchaseSuccess);
        _inAppPurchase.addEventListener(InAppPurchaseEvent.PURCHASE_DISABLED, inAppPurchase_purchaseDisabledHandler);
        _inAppPurchase.addEventListener(InAppPurchaseEvent.PURCHASE_ENABLED, inAppPurchase_purchaseEnabledHandler);
        _inAppPurchase.addEventListener(InAppPurchaseEvent.PURCHASE_ERROR, onPurchaseError);
        _inAppPurchase.addEventListener(InAppPurchaseEvent.PRODUCT_INFO_RECEIVED, onProductInfoSuccess);
        _inAppPurchase.addEventListener(InAppPurchaseEvent.PRODUCT_INFO_ERROR, onProductInfoError);
        _inAppPurchase.addEventListener(InAppPurchaseEvent.RESTORE_INFO_RECEIVED, onRestoreSuccess);


        DS::device{
            _inAppPurchase.init("MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAifYmYJG+4bR2wc0z2m5Cc5vM5/1qxDUtQx4gDiRKyE6i3RAUn5SKKUVJhtpjF4ZY3hNDsjyBN9kdiF1p7I53M3HcmlrynpzTdpHw9GKATjaMeSAMgQLFnkkV+yzK0qmChACWH7zQZASJliNDB96v2uRJGaZkrolJBYCXcW9b6pnN7SSuXWuIe7NRsuPl2TP+RsS90YwKKHL+b7PSUwCU6B8I7L/BJ7WatRp7oV8pEC0n1hDeqKYtSivmajczAMldBN2s7oL2rMQL1t0NWUS37lvLCFnVTJTVCtEppzfmZ5JFQCAlGVtQ/pGUaAtyPrCXRrebDE4VnJC6/t20oqKjWQIDAQAB", true);
        }

        _products = new Vector.<ProductInfo>();
        _productsReady = false;
    }

    public static function get instance():AndroidStore {
        if (_instance == null) {
            _instance = new AndroidStore();
        }

        return _instance;
    }

//    private function onInitSuccess(event:InAppPurchaseEvent):void {
//        //you can restore previously purchased items here
//    }
//
//    private function onInitError(event:InAppPurchaseEvent):void {
//        trace("[InAppPurchase] INIT ERROR:", event.data);
//        dispatchEvent(new Event("product-infos-failed"));
//
//    }

    public function loadProducts():void {
        _inAppPurchase.getProductsInfo(PRODUCT_IDS, [])
        _inAppPurchase.restoreTransactions();
    }

    public function buyAlarms():void {
        buyThing(CommonStore.alarmProductId);
    }

    public function buyInstruments():void {
        buyThing(CommonStore.instrumentsProductId);
    }

    public function buyPolar():void {
        buyThing(CommonStore.polarProductId);
    }

    public function restore():void {
        _inAppPurchase.restoreTransactions();
    }

    private function buyThing(identifier:String):void {
        _inAppPurchase.makePurchase(identifier);
    }



    private function onPurchaseSuccess(event:InAppPurchaseEvent):void {
        var response:Object = JSON.parse(event.data);
        var identifier:String = response.productId;
        if (identifier == CommonStore.alarmProductId) {
            CommonStore.instance.activateAlarm();
        } else if (identifier == CommonStore.instrumentsProductId) {
            CommonStore.instance.activateInstruments();
        } else if (identifier == CommonStore.polarProductId) {
            CommonStore.instance.activatePolar();
        }
        dispatchEvent(new Event("purchase-success"));
    }

    private function onPurchaseError(event:InAppPurchaseEvent):void {
        trace("[InAppPurchase] PURCHASE ERROR:", event.data);
    }

    private function onProductInfoSuccess(event:InAppPurchaseEvent):void {
        _products.length = 0;
        var response:Object = JSON.parse(event.data);
        for each(var detail:Object in response.details) {
            var info:ProductInfo = new ProductInfo();
            info.name = detail.title;
            info.description = detail.descr;
            info.identifier = detail.productId;
            info.price = detail.price;
            _products.push(info)
        }
        activatePurchases(response);
        _productsReady = true;
        dispatchEvent(new Event("product-infos-ready"));
    }

    private function onProductInfoError(event:InAppPurchaseEvent):void {
        trace("[InAppPurchase] PRODUCT INFO ERROR:", event.data);
        dispatchEvent(new Event("product-infos-failed"));
    }

    private function onRestoreSuccess(event:InAppPurchaseEvent):void {
        var response:Object = JSON.parse(event.data);
        activatePurchases(response);
    }

    private function activatePurchases(response:Object):void {
        for (var i:int = 0; i < response.purchases.length; i++) {
            var object:Object = response.purchases[i];
            switch (object.productId) {
                case CommonStore.alarmProductId:
                    CommonStore.instance.activateAlarm();
                    break;
                case CommonStore.instrumentsProductId:
                    CommonStore.instance.activateInstruments();
                    break;
                case CommonStore.polarProductId:
                    CommonStore.instance.activatePolar();
                    break;
            }
        }
    }

    private function onRestoreError(event:InAppPurchaseEvent):void {
        trace("[InAppPurchase] RESTORE ERROR:", event.data);
    }

    public function get products():Vector.<ProductInfo> {
        return _products;
    }

    public function get productsReady():Boolean {
        return _productsReady;
    }

    private function inAppPurchase_purchaseDisabledHandler(event:InAppPurchaseEvent):void {
        trace("Purchase disabled");
    }

    private function inAppPurchase_purchaseEnabledHandler(event:InAppPurchaseEvent):void {
        trace("purcahse enabled");
    }
}
}
