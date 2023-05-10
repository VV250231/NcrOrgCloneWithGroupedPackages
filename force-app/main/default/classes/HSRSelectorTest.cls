/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test class that covers Hospitality Selector class for quick deployment validation
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Basel Altamimi    <ba250204@ncr.com>
* @modifiedBy     Basel Altamimi    <ba250204@ncr.com>
* @version        1.0
* @created        2022-08-03
* @modified
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            ba250204@ncr.com
* 2022-08-03
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

@IsTest
private class HSRSelectorTest {
    @TestSetup
    static void setup() {
        Automation_Setting__c setting = new Automation_Setting__c(
                Skip_Trigger__c = true,
                Skip_Validation_Rule__c = true,
                Skip_Flow__c = true,
                Skip_Outbound_Integration__c = true
        );
        insert setting;
    }

    @IsTest
    static void codeCoverage() {
        HSRSelector.mockResults = false;
        HSRTestSelector.mockResults = false;
        HSRUtil.skipDatabaseOperations = false;

        HSRSelector.getAccountsByCustomersNumbers(new List<String>());
        HSRSelector.getAccountQueryLocator_ARCBatchJob(new List<Id>{
        });
        HSRSelector.getSiteAccountsByParentId_ACRToCreate(new List<Id>{
        }, 1);
        HSRSelector.getContactsByEmail('');
        HSRSelector.getContactsByACRStatus('');
        HSRSelector.hasPendingACRProcessingRequests();
        HSRSelector.getPendingACRToDelete(null, new List<Id>{
        }, 1);
        HSRSelector.getMCNAccountContactRelations(new List<Id>{
        });
        HSRSelector.getContactsByUserIds(new List<Id>{
        });
        HSRSelector.getWorkOrdersById(new List<String>{
        });
        HSRSelector.getProfileByName(System.Label.HSR_UsrPrv_Profile_Name);
        HSRSelector.getRunningBatchByClassName(HSRACRCreationBatch.class.getName(), new List<String>{
        });
    }

    @IsTest
    static void codeCoverage_mock() {
        HSRSelector.mockResults = true;
        HSRTestSelector.mockResults = true;
        HSRUtil.skipDatabaseOperations = true;

        HSRSelector.getAccountsByCustomersNumbers(new List<String>());
        HSRSelector.getAccountQueryLocator_ARCBatchJob(new List<Id>{
        });
        HSRSelector.getSiteAccountsByParentId_ACRToCreate(new List<Id>{
        }, 1);
        HSRSelector.getContactsByEmail('');
        HSRSelector.getContactsByACRStatus('');
        HSRSelector.hasPendingACRProcessingRequests();
        HSRSelector.getPendingACRToDelete(null, new List<Id>{
        }, 1);
        HSRSelector.getMCNAccountContactRelations(new List<Id>{
        });
        HSRSelector.getContactsByUserIds(new List<Id>{
        });
        HSRSelector.getWorkOrdersById(new List<String>{
        });
        HSRSelector.getProfileByName(System.Label.HSR_UsrPrv_Profile_Name);
        HSRSelector.getRunningBatchByClassName(HSRACRCreationBatch.class.getName(), new List<String>{
        });
    }
}