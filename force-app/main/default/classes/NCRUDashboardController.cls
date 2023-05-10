public class NCRUDashboardController 
{
    @AuraEnabled
    public List<NCRUDetails> lstNCRUDetails;
    
    @AuraEnabled
    public static List<NCRUDetails> getNCRUDetails (String recId) 
    {
        List<NCRUDetails> lstDtls = new List<NCRUDetails>();
        
        Boolean isCertAcss = Schema.getGlobalDescribe().get('Certification__c').getDescribe().isUpdateable();
                              
        if(!isCertAcss)
            return lstDtls;
        Map<String, List<Certification__c>> mapKeyCmbTolstCert = new Map<String, List<Certification__c>>();
        Set<String> setCertSltn = new Set<String>();
       
        
        for(Certification__c objCert : [Select Id, Profile__c, Solution__c, Curriculum_Number__c, Required__c, Certification_Key_Combination__c from Certification__c  where Account__c =: recId])
        {
            if(String.isNotBlank(objCert.Certification_Key_Combination__c))
            {
                if(!mapKeyCmbTolstCert.containsKey(objCert.Certification_Key_Combination__c))
                {
                    mapKeyCmbTolstCert.put(objCert.Certification_Key_Combination__c, new List<Certification__c>{objCert});
                }
                else
                {
                    mapKeyCmbTolstCert.get(objCert.Certification_Key_Combination__c).add(objCert);
                }
            }
        }
        
        if(!mapKeyCmbTolstCert.isEmpty())
        {
            for(String strKeyCmb : mapKeyCmbTolstCert.keySet())
            {
                List<Certification__c> lstCert = mapKeyCmbTolstCert.get(strKeyCmb);
                if(!lstCert.isEmpty())
                    lstDtls.add(new NCRUDetails(lstCert[0].Curriculum_Number__c, 
                                                   lstCert[0].Solution__c, lstCert[0].Profile__c , lstCert[0].Certification_Key_Combination__c,
                                                   lstCert[0].Required__c, lstCert.size()));
                if(String.isNotBlank(lstCert[0].Solution__c))
                             setCertSltn.add(lstCert[0].Solution__c);
            }
            //System.debug('---------lstDetails.size()---------'+lstDtls.size());
        } 
        Account objAcc = [Select Id, Name, RecordType.Name,CreatedDate, Owner.Name,authorized_solutions__c,PSP_Level_s__c,Distributor__c,Financial_Products_Authorized_to_Resell__c, Retail_Products_Authorized_to_Resell__c, Other_Products_Authorized_to_Resell__c, Software_Products_Authorized_to_Resell__c,Financial_Hardware_Auth_to_Maintain__c,Retail_Hardware_Authorized_to_Maintain__c,    Other_Hardware_Authorized_to_Maintain__c from Account where Id=: recId];                                                                                                                 
        Set<String> setResell = new Set<String>();
        
        if(String.isNotBlank(objAcc.Financial_Products_Authorized_to_Resell__c))
        {
            setResell = new Set<String>();
            setResell.addAll(objAcc.Financial_Products_Authorized_to_Resell__c.split(';'));
            for(String strResell : setResell)
            {
                if(String.isNotBlank(strResell) && !setCertSltn.contains(strResell) && strResell != 'Not Applicable')
                {
                    lstDtls.add(new NCRUDetails('', strResell, 'Financial' , '', 2, 0));
                }
            }
        }
        if(String.isNotBlank(objAcc.Retail_Products_Authorized_to_Resell__c))
        {
            setResell = new Set<String>();
            setResell.addAll(objAcc.Retail_Products_Authorized_to_Resell__c.split(';'));
            for(String strResell : setResell)
            {
                if(String.isNotBlank(strResell) && !setCertSltn.contains(strResell)  && strResell != 'Not Applicable')
                {
                    lstDtls.add(new NCRUDetails('', strResell, 'Retail' , '', 2, 0));
                }
            }
        }
        if(String.isNotBlank(objAcc.Other_Products_Authorized_to_Resell__c))
        {
            setResell = new Set<String>();
            setResell.addAll(objAcc.Other_Products_Authorized_to_Resell__c.split(';'));
            for(String strResell : setResell)
            {
                if(String.isNotBlank(strResell) && !setCertSltn.contains(strResell)  && strResell != 'Not Applicable')
                {
                    lstDtls.add(new NCRUDetails('', strResell, 'Hospitality' , '', 2, 0));
                }
            }
        }
        
        return lstDtls;
    }

    
    @AuraEnabled
    public static List<Certification__c> getCertificationDetails (String keyVal, String accId) 
    {  
        List<Certification__c> lstCert = [Select Id, Name, Contact__r.Name, Curriculum_Number__c, Contact__r.Title, Profile__c, Solution__c 
                                                    from Certification__c where Certification_Key_Combination__c =: keyVal and Account__c =: accId and Certification_Key_Combination__c != null] ;
        return lstCert;
    }
    
    public class NCRUDetails
    {
       
        
        @AuraEnabled
        public String curriculum ;
        
        @AuraEnabled
        public String solution;
        
        @AuraEnabled
        public String profile;
        
        @AuraEnabled
        public String keyCombination;
        
        @AuraEnabled
        public Integer required;
        
        @AuraEnabled
        public Integer totalCompleted;
        
        @AuraEnabled
        public Integer completedPercentage;
        
        @AuraEnabled
        public Boolean isAccess;
        
       
        public NCRUDetails(String curriculum, String solution,  String profile, String keyCombination, Decimal required, Integer totalCompleted)
        {
            this.curriculum = curriculum;
            this.solution = solution;
            this.profile = profile;
            this.keyCombination = keyCombination;
            this.required = (Integer) required;
            this.totalCompleted = totalCompleted;
            if(required != null && required > 0 )
            {
                this.completedPercentage = (Integer) ((totalCompleted /required) * 100) ;
            }
            //String usrId = UserInfo.getUserId();
            //usrId = usrId.substring(0,15);
            //NCRU_Dashboard_Access__c objNDA = NCRU_Dashboard_Access__c.getInstance(usrId);
            //System.debug('---------userId-----------'+userId);
            //System.debug('----------UserInfo.getUserId()-----------'+UserInfo.getUserId());
            //System.debug('----------objNDA-----------'+objNDA);
            
           // this.isAccess = objNDA != null;
            this.isAccess = FeatureManagement.checkPermission('NCRU_Access');

            //System.debug('----------isAccess-----------'+isAccess);
        }
    }
}