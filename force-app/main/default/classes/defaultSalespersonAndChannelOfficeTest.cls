@isTest(seeAllData = true)
private class defaultSalespersonAndChannelOfficeTest {
static testMethod void validateHelloWorld() {
zqu__QuoteCharge__c qc = new zqu__QuoteCharge__c ();
try{
qc = [select id from zqu__QuoteCharge__c limit 1];
}
catch(System.QueryException e){
if(qc<>null)
{
update qc;
}
}
system.assert(qc.id!=null); 
}
}