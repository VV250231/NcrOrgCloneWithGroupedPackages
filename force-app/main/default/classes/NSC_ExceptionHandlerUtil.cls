/*
*********************************************************
Apex Class Name    : NSC_ExceptionHandlerUtil
@description       : This class is used for exception handling by publishing the platform events.
@author            : Shiv Mahla
@Test Class :      : NSC_ExceptionHandlerUtilTest
Modification Log:
Ver   Date         Author                               Modification
1.0   CreatedDate  Shiv Mahla                      Initial Version
*********************************************************
*/
public with sharing class NSC_ExceptionHandlerUtil {
    
    public static void publishErrorMessageEvent(Exception ex, String sourceComponent) {
        Error_Message__e event = new Error_Message__e();
        event.Source__c = sourceComponent;
        event.Message__c = ex.getMessage();
        event.Line_Number__c = ex.getLineNumber();
        event.Stack_Trace__c = ex.getStackTraceString();
        event.Cause__c = String.valueOf(ex.getCause());
        EventBus.publish(event);
    }

}