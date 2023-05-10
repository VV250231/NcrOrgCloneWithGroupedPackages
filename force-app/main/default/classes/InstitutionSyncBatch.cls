public class InstitutionSyncBatch implements Database.Batchable<FDICInstitutionsWrapper.cls_data>, Database.AllowsCallouts {
    
    public  List<FDICInstitutionsWrapper.cls_data> dataList = new List<FDICInstitutionsWrapper.cls_data>();
    public String recLimit ,  recOffset;
    public InstitutionSyncBatch(List<FDICInstitutionsWrapper.cls_data> dataList,String recLimit , String recOffset){
  
        this.dataList = dataList;
        this.recLimit = recLimit;
        this.recOffset = recOffset;
    }
    
    public  Iterable<FDICInstitutionsWrapper.cls_data> start(Database.BatchableContext bc) {
        //this.dataList = fdicService.fetchInsitutions();
        system.debug('>>>'+dataList);
        return dataList;
    }
    
    public  void execute(Database.BatchableContext bc, List<FDICInstitutionsWrapper.cls_data> scope) {
        List<Institutions__c> institutionList = new List<Institutions__c>();
        for(FDICInstitutionsWrapper.cls_data cdata: scope) {
            system.debug(cdata+'^^^^^');
            Institutions__c institutionRec = new Institutions__c();
            institutionRec.State_Name__c = cdata.data.STNAME;
            institutionRec.FDIC_Certificate__c = String.valueof(cdata.data.CERT);
            institutionRec.InActive__c = cdata.data.INACTIVE == 1?TRUE:FALSE;
            //institutionRec.Active__c = cdata.data.ACTIVE == 1?TRUE:FALSE;
            institutionRec.Address__c = cdata.data.ADDRESS;
            institutionRec.Total_Assets__c = cdata.data.ASSET;
            institutionRec.Country__c = cdata.data.COUNTY;
         
            institutionRec.Total_Deposits__c = cdata.data.DEP;
            institutionRec.Name = cdata.data.NAME;
            institutionRec.New_certificate_number__c = cdata.data.NEWCERT;
            institutionRec.Zip_Code__c = cdata.data.ZIP;
            if(cdata.data.ULTCERT != null){
            	institutionRec.Ultimate_Cert__c = long.valueof(cdata.data.ULTCERT);
            }
            institutionRec.Primary_Internet_Web_Address__c = cdata.data.WEBADDR;
            institutionRec.Directly_Owned_By_Another_Bank_CERT__c = cdata.data.CERTCONS;
            institutionRec.Directly_Owned_By_Another_Bank_CERT_2__c	 = cdata.data.PARCERT;
		    institutionRec.City_of_High_Holder__c= cdata.data.CITYHCR;
            //institutionRec.Last_Structure_Change_Effective_Date__c = formatDate(cdata.data.EFFDATE);
            //institutionRec.End_Date__c =  formatDate(cdata.data.ENDEFYMD);  
            //institutionRec.Established_Date__c = formatDate(cdata.data.ESTYMD);  
            // institutionRec.Last_Update__c = formatDate(Date.parse(String.valueOf(inst_dataMap1.get('DATEUPDT'))));
            
			institutionRec.Denovo_Institution__c = cdata.data.DENOVO == '1'?TRUE:FALSE;
            institutionRec.Bank_Holding_Company_Regulatory_Top_Hol__c= cdata.data.NAMEHCR;
			institutionRec.Net_Income__c= cdata.data.NETINC;
            institutionRec.Net_Income_Quarterly__c= cdata.data.NETINCQ;
            institutionRec.Number_of_Domestic_Offices__c= cdata.data.OFFDOM;
            institutionRec.Number_of_Foreign_Offices__c	= cdata.data.OFFFOR;
			institutionRec.OFFOA__c	= cdata.data.OFFOA;
            institutionRec.RecordTypeId = SObjectType.Institutions__c.getRecordTypeInfosByDeveloperName().get('FDIC').getRecordTypeId();
            institutionList.add(institutionRec);
            
        }
         //insert institutionList;
         upsert institutionList FDIC_Certificate__c; 
    }
    public  void  finish(Database.BatchableContext bc) {
        system.debug('before recLimit ='+recLimit+' recOffset ='+recOffset);
        recOffset = recOffset=='0'?recLimit:String.valueof( Integer.valueOf(recOffset) + Integer.valueOf(recLimit)) ;
        recLimit = recLimit;        
        system.debug('inbatch recLimit ='+recLimit+' recOffset ='+recOffset);
        /* To proccess next offset records */
        If(!test.isRunningTest()){
        InstitutionSyncScheduler.makeCallOut(recLimit, recOffset);
    }
    }

}