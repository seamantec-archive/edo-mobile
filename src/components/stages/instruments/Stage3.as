/**
 * Created by pepusz on 2014.09.03..
 */
package components.stages.instruments {
import com.inAppPurchase.CommonStore;

import components.*;

public class Stage3 extends EdoStage {

    public static const ID:String = "stage3";

    public function Stage3() {
        super(ID, "Page 3");

        buildFromFile();

        if(!CommonStore.instance.isInstrumentsEnabled) {
            addPurchaseButton(EdoStage.PURCHASE_TYPE_INSTRUMENTS);
        }
    }
}
}
