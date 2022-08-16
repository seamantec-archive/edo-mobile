/**
 * Created by seamantec on 16/07/14.
 */
package com.notification {
public class NotificationTypes {

    public static const USER_CONNECTION_CLOSE_ALERT:int = 0;
    public static const SYSTEM_CONNECTION_CLOSE_WARNING:int = 1;
    public static const WIND_CORRECTION_ALERT:int = 2;
    public static const LARGE_FILE_WARNING:int = 3;
    public static const WRONG_LOG_WARNING:int = 4;
    public static const POLAR_EXTENSION_WARNING:int = 5;
    public static const POLAR_CLOUD_EMPTY:int = 6;
    public static const POLAR_FILE_IS_NOT_POLAR:int = 7;
    public static const POLAR_CLOUD_IS_NOT_CLOUD:int = 8;
    public static const LOGBOOK_CLEAR:int = 9;
    public static const RESET_EVERYTHING:int = 10;


    public static const USER_CONNECTION_CLOSE_ALERT_TEXT:String = "This will end the active connection!\nDo you want to continue?";
    public static const SYSTEM_CONNECTION_CLOSE_WARNING_TEXT:String = "The connection has been lost.";
    public static const WIND_CORRECTION_ALERT_TEXT:String = "The log file will be reloaded using the new settings.\nDo you want to continue?";
    public static const LARGE_FILE_WARNING_TEXT:String = "The file is too large.\nThe maximum file size is 30 MB.";
    public static const WRONG_LOG_WARNING_TEXT:String = "The file is not a NMEA log.";
    public static const POLAR_EXTENSION_WARNING_TEXT:String = "The file extension is not .csv or .d.";
    public static const POLAR_CLOUD_EMPTY_TEXT:String = "The polar cloud is empty.";
    public static const POLAR_FILE_IS_NOT_POLAR_TEXT:String = "The file is not a valid polar table!\nPlease try again!";
    public static const POLAR_CLOUD_IS_NOT_CLOUD_TEXT:String = "The file is not a valid polar cloud!\nPlease try again!";
    public static const CLEAR_LOGBOOK:String = "This will delete all of your entries!\nDo you want to continue?";
    public static const RESET_EVERYTHING_TEXT:String = "This will delete all of your data (Settings, Layouts, etc)!\nApp will shutdown.\nDo you want to continue?";

    public function NotificationTypes() {
    }
}
}
