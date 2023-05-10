trigger LeadUpdateTempTrigger on Lead (before update){ 
  if (FeatureManagement.checkPermission('ETL_PreventOverwrite')){
    for(Lead l:trigger.new){
      Lead ol=trigger.oldMap.get(l.Id);
      if (!(ol.status=='Disqualified' && (l.status=='Open'||l.status=='Researching'||l.status=='Contacted'))){
        l.status=ol.status;
        l.OwnerId=ol.OwnerId;
      }
      if(ol.AnnualRevenue!=null){
        l.AnnualRevenue=ol.AnnualRevenue;
      }
      if(ol.Branches__c!=null){
        l.Branches__c=ol.Branches__c;
      }
      if(ol.company!=null){
        l.company=ol.company;
      }
      if(ol.currencyisocode!=null){
        l.currencyisocode=ol.currencyisocode;
      }
      if(ol.Email!=null){
        l.Email=ol.Email;
      }
      if(ol.Disqualified_Reason__c!=null){
        l.Disqualified_Reason__c=ol.Disqualified_Reason__c;
      }
      if(ol.Disqualified_Reason_Comments__c!=null){
        l.Disqualified_Reason_Comments__c=ol.Disqualified_Reason_Comments__c;
      }
      if(ol.emailbounceddate!=null){
        l.emailbounceddate=ol.emailbounceddate;
      }
      if(ol.emailbouncedreason!=null){
        l.emailbouncedreason=ol.emailbouncedreason;
      }
      if(ol.firstname!=null){
        l.firstname=ol.firstname;
      }
      if(ol.hasoptedoutofemail!=null){
        l.hasoptedoutofemail=ol.hasoptedoutofemail;
      }
      if(ol.hasoptedoutoffax!=null){
        l.hasoptedoutoffax=ol.hasoptedoutoffax;
      }
      if(ol.Industry__c!=null){
        l.Industry__c=ol.Industry__c ;
      }
      if(ol.Industry!=null){
        l.Industry=ol.Industry;
      }else{
        l.Industry=l.Industry__c;
      }
      if(ol.jigsaw!=null){
        l.jigsaw=ol.jigsaw;
      }
      if(ol.isunreadbyowner!=null){
        l.isunreadbyowner=ol.isunreadbyowner;
      }
      if(ol.lastname!=null){
        l.lastname=ol.lastname;
      }
      // L1-Leadtype, L2-LeadSource__c, L3-SubLeadSource
      if(ol.Leadtype__c!=null || ol.Leadsource__c!=null || ol.Sub_Lead_Source__c!=null){
        l.Leadtype__c=ol.Leadtype__c;
        l.Leadsource__c=ol.Leadsource__c;
        l.Sub_Lead_Source__c=ol.Sub_Lead_Source__c;
      }
      if(ol.Leadsource!=null){
        l.Leadsource=ol.Leadsource;
      }else{
        l.LeadSource=l.LeadSource__c;
      }
      System.debug('Oldnote:'  + ol.Lead_Marketing_Notes__c);
      System.debug('Newnote:'  + l.Lead_Marketing_Notes__c);
      if(ol.Lead_Marketing_Notes__c!=null && l.Lead_Marketing_Notes__c!=null){
        if(ol.Lead_Marketing_Notes__c.endsWith(l.Lead_Marketing_Notes__c)){
          System.debug('Recover orig note');
            l.Lead_Marketing_Notes__c=ol.Lead_Marketing_Notes__c;
        }else{
          System.debug('Append note');
          l.Lead_Marketing_Notes__c=(ol.Lead_Marketing_Notes__c+'\n'+l.Lead_Marketing_Notes__c).abbreviate(32000);
        }
      }else if(ol.Lead_Marketing_Notes__c!=null){ //new note is null
        l.Lead_Marketing_Notes__c=ol.Lead_Marketing_Notes__c;
      }
      if(ol.mobilephone!=null){
        l.mobilephone=ol.mobilephone;
      }
      if(ol.numberofemployees!=null){
        l.numberofemployees=ol.numberofemployees;
      }
      if(ol.phone!=null && l.phone!=ol.phone){
        l.Secondary_Phone__c=l.phone;
        l.phone=ol.phone;
      }
      if(ol.Product_interest__c!=null){
        l.Product_interest__c=ol.Product_interest__c;
      }
      if(ol.rating!=null){
        l.rating=ol.rating;
      }
      if(ol.salutation!=null){
        l.salutation=ol.salutation;
      }
      if(ol.Street!=null && ol.Street!=l.Street){
                l.Street=ol.Street;
                l.City=ol.City;
                l.State=ol.State;
                l.PostalCode=ol.PostalCode;
                l.Country=ol.Country;
                l.Latitude=ol.Latitude;
                l.Longitude=ol.Longitude;
        l.geocodeaccuracy=ol.geocodeaccuracy;
            }
      if(ol.SubIndustry__c!=null){
        l.SubIndustry__c=ol.SubIndustry__c ;
      }
      if(ol.title!=null){
        l.title=ol.title;
      }
      if(ol.website!=null){
        l.website=ol.website;
      }
        }
    } 
}