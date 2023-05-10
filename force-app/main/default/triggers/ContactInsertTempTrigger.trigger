trigger ContactInsertTempTrigger on Contact (before insert){
  if(FeatureManagement.checkPermission('ETL_PreventOverwrite')){
    for(Contact c:trigger.new){
      if((String.isBlank(c.email) || c.email.contains('@email.com') || c.email.contains('@nomail.com') || c.email.contains('@noemail.com') || c.email.contains('@nomail.de') || c.email.contains('@no.com') || c.email.contains('@no.de')|| c.email.startsWith('no@') || c.email.startsWith('unknown@') || c.email.startsWith('nomail@') || c.email.startsWith('noemail@') ) && c.CardtronicsId__c!=null) {
        c.email=c.CardtronicsId__c.toLowerCase()+'@noemail.com';
      }
    }
  }
}