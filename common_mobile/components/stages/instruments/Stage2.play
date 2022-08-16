/**
 * Created by pepusz on 2014.09.03..
 */
package components.stages.instruments {
import com.inAppPurchase.CommonStore;

import components.*;

public class Stage2 extends EdoStage {

    public static const ID:String = "stage2";

    public function Stage2() {
        super(ID, "Page 2");

        buildFromFile();

        if(!CommonStore.instance.isInstrumentsEnabled) {
            addPurchaseButton(EdoStage.PURCHASE_TYPE_INSTRUMENTS);
        }
    }
}
}
