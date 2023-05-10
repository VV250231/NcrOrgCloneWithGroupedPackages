/*
#####################################################################################################################
# Project Name..........: NSC PMDM                                                                         #
# File..................: TestLookup.cls                                                             #
# Version...............: 1                                                                                         #
# Created by............: Ravikant Maurya                                                                                #
# Created Date..........: 01-09-2018                                                                               #
# Last Modified by......: Ravikant Maurya                                                                               #
# Last Modified Date....: 01-09-2018                                                                                #
# Description...........: This  functionality is targeted to test Lookup Apex class.                                                                    #
#####################################################################################################################
*/
@isTest
public class TestLookup {
    public static testMethod void runUnitTest() {
        TestRecordsFactory.createAccount();
        String objectName = 'Account';
        String fld_API_Text = 'Id';
        String fld_API_Val  = 'Name';
        Integer lim = 10;
        String fld_API_Search = 'Name';
        String searchText = 'Test';
       string s1= Lookup.searchDB(objectName, fld_API_Text, fld_API_Val, lim, fld_API_Search, searchText);
        System.assert(s1!=null);
    }
}