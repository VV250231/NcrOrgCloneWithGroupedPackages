trigger LeadInsertTempTrigger on Lead (before insert) {
  if(FeatureManagement.checkPermission('ETL_PreventOverwrite')){
    for(Lead l:trigger.new){
      if((String.isBlank(l.email)|| l.email.contains('@email.com')|| l.email.contains('@nomail.com') || l.email.contains('@noemail.com')|| l.email.contains('@nomail.de') || l.email.contains('@no.com') || l.email.contains('@no.de') || l.email.startsWith('no@') || l.email.startsWith('unknown@') || l.email.startsWith('nomail@') || l.email.startsWith('noemail@') ) && l.CardtronicsId__c!=null){
        l.email=l.CardtronicsId__c.toLowerCase()+'@noemail.com';
      }
      l.LeadSource=l.LeadSource__c;
      l.Industry=l.Industry__c;
    }
  }
}