@isTest(seeAllData = true)
private class defaultSalespersonTest {
static testMethod void validateHelloWorld() {

Account a = new Account();
a.name = 'test';
a.industry = 'HOSPITALITY:CHANNEL';
a.Account_Country_Code__c = 'US';
system.runas(TestRecordsFactory.getUser()){
insert a;
}

Opportunity o = new Opportunity();
o.accountid = a.id;
o.name = 'test';
o.closedate = system.today();
o.stagename = 'Analyzing';
o.Channel_Office__c = a.id;
insert o;

zqu__Quote__c q = new zqu__Quote__c();
q.name = 'test';
q.zqu__Account__c = a.id ;
q.zqu__Opportunity__c = o.id;
insert q;

zqu__QuoteAmendment__c qa = new zqu__QuoteAmendment__c();
qa.name = 'abc' ;
qa.zqu__Quote__c = q.id;
insert qa;

zqu__QuoteRatePlan__c qp = new zqu__QuoteRatePlan__c();
qp.name = 'abc';
qp.zqu__Quote__c = q.id ;
qp.zqu__QuoteAmendment__c = qa.id;
insert qp ;

zqu__QuoteRatePlanCharge__c qr = new zqu__QuoteRatePlanCharge__c();
qr.name = 'test' ;
qr.zqu__QuoteRatePlan__c = qp.id ;
insert qr ;

User usr = new User();
usr = [select id , name , email from user where name =: 'Dev Admin'];
OpportunityTeamMember otm = new OpportunityTeamMember();
otm.OpportunityId = o.id ; 
otm.UserId = usr.id ;
insert otm ;
system.assertEquals(otm.UserId ,usr.id);

q = [select id , Quote_Stage__c from zqu__Quote__c where id =: q.id ] ;
q.Quote_Stage__c = 'Rejected' ;
update q ;
system.assertEquals(q.Quote_Stage__c , 'Rejected');

}
}