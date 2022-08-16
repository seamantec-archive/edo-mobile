/**
 * Created by pepusz on 2014.09.03..
 */
package components.stages.instruments {
import com.inAppPurchase.CommonStore;

import components.*;

public class Stage4 extends EdoStage {

    public static const ID:String = "stage4";

    public function Stage4() {
        super(ID, "Page 4");

        buildFromFile();

        if(!CommonStore.instance.isInstrumentsEnabled) {
            addPurchaseButton(EdoStage.PURCHASE_TYPE_INSTRUMENTS);
        }
    }
}
}
