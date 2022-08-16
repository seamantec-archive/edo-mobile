/**
 * Created by seamantec on 22/01/15.
 */
package components.stages.instruments {
import com.common.AppProperties;
import com.inAppPurchase.CommonStore;

import components.EdoStage;

public class Stage6 extends EdoStage {

    public static const ID:String = "stage6";

    public function Stage6() {
        super(ID, "Page 6");

        buildFromFile();

        if(!CommonStore.instance.isInstrumentsEnabled) {
            addPurchaseButton(EdoStage.PURCHASE_TYPE_INSTRUMENTS);
        }
    }
}
}
