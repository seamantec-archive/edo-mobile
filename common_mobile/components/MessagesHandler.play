/**
 * Created by seamantec on 04/09/14.
 */
package components {

import com.sailing.IParserListener;
import com.sailing.ParserNotifier;

import components.stages.messages.MessagesStage;

public class MessagesHandler implements IParserListener {

    private static var _instance:MessagesHandler = null;

    private var _stage:MessagesStage;

    function MessagesHandler() {
    }

    public static function get instance():MessagesHandler {
        if(_instance==null) {
            _instance = new MessagesHandler();
        }
        return _instance;
    }

    public function addStage(stage:MessagesStage):void {
        _stage = stage;
        ParserNotifier.instance.checkValidations();
    }

    public function removeStage():void {
        _stage = null;
    }

    public function sailDataChanged(key:String):void {
        if(_stage!=null) {
            _stage.dataChanged(key);
        }
    }

    public function sailDataInvalidated(key:String):void {
        if(_stage!=null) {
            _stage.dataInvalidated(key);
        }
    }

    public function sailDataPreInvalidated(key:String):void {
        if(_stage!=null) {
            _stage.dataPreInvalidated(key);
        }
    }
}
}
