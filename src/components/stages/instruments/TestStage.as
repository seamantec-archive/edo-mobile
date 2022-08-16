/**
 * Created by pepusz on 2014.09.03..
 */
package components.stages.instruments {
import components.*;

public class TestStage extends EdoStage {

    public static const ID:String = "test_stage";

    public function TestStage() {
        super(ID, "Test stage");

        buildFromFile();
    }
}
}
