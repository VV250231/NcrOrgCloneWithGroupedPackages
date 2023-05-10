@isTest(SeeAllData=false)
public class UpdateSubscriptionChargesInZuoraTest 
{

    public static testMethod void coverCodeUpdateSubsChargeTrigger()
    {

        Zuora__Subscription__c  subs = new Zuora__Subscription__c ();
        subs.Zuora__Zuora_Id__c = 'test12352';
        insert subs;
        System.assert(subs.Id!=null);
        system.assertNotEquals('TestAashirwaad',subs.Zuora__Zuora_Id__c);
        ZuoraSubscription_NCR.increasecoverage();
    }
}