/*
##################################################################################################
# Class Name..........: SSOErrorPageConTest                                                                         
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
# Description........:  EBA_SF-2491 JDK Locale impact - Upgrade API Part 5 
                               
################################################################################################
*/
@isTest
public class SSOErrorPageConTest {
  /*  public static testmethod void testSSOErrorPageCon() {
        //SSOErrorPageCon controller = new SSOErrorPageCon();
        controller.createCase();
    }*/
    static testmethod void TestCasecreate(){
        Case newCase = new Case();
        newCase.Type='Problemtest';
        newCase.Origin='IPT SSO';
        newCase.Status='New';
        newCase.Priority='Low';
        PageReference pageRef = Page.SSOErrorPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('ErrorCode','test'); 
        ApexPages.currentPage().getParameters().put('ErrorDetails','test1');
        ApexPages.currentPage().getParameters().put('ErrorDescription','test2');
        SSOErrorPageCon controller = new SSOErrorPageCon();
        controller.createCase();
        system.assertEquals(controller.isCaseCreated, true);
    }
}