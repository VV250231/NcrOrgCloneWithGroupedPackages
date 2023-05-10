/****************************************************************************************************************
*   ClassName :   PSFRResource_R
*   Description :   PSFRResource_R_Test
*   Author      :   
*   Version     :   Initial
* Test Class : 
# Modification History.: 
Story No#         Date            DevName                Description
EBA_SF-1669       8th Dec 2021    Varsha Pal             Remove the testcoverage function
EBA_SF_1733		  4th Jan 2022	  Kavya Sree			 Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 2
BA_SF-2491        19-12-2022      Monika                 JDK Locale impact - Upgrade API Part 5
****************************************************************************************************************/
public class PSFRResource_R{
    /*
#####################################################################################################################
*/   
    /*public PSFRResource_R( PSFRApexController controller ) { }*/
    Resource__c res = new    Resource__c();// variable name changed resource to res - EBA_SF-1669
    public String recordlink{ get; set; } 
    public String id{ get; set; }
    public Decimal Total{ get; set; }
    public Decimal result  { get; set; }
    public String CompletedbyName { get; set; }
    public String CompletedbyEmail { get; set; }
    public Decimal TotalHours  { get; set; }
    public Integer TotalHoursRate  { get; set; }
    public Integer TotalTravelCost  { get; set; }
    public List<Integer> ListSave{ get; set;}
    public Resource__c rm { get; set; } 
    public String MasterRecordId {get; set;}
    public List<wrapperPSFR>WrapperList{get;set;}
    public integer COUNT_FRM_PAGE{get;set;}
    public List<Resource__c> ChildRecords{get;set;}
    String BPMComUrl=System.Label.BPM_Employee_Community_URL;// variable name changed BPMEmployeeCommunity to BPMComUrl - EBA_SF-1669
    /*
#####################################################################################################################
*/    
    
    public PSFRResource_R(){ 
        //EBA_SF_1733 Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 2
        Blob blobPlid;
        String KeysForSecuredUrls = KeysForSecuredUrls__c.getValues('PSFREncryptionKey').CryptoKey__c;
        Blob cryptoKey = Blob.valueOf(KeysForSecuredUrls);
        String encryptedPlid = ApexPages.currentPage().getParameters().get('Plid');// new variable created to store plid - EBA_SF-1669
        system.debug('@@@@: '+encryptedPlid);
        if (Test.isRunningTest()){
            blobPlid = EncodingUtil.base64Decode(encryptedPlid); //EncodingUtil.base64Decode(encodingUtil.URLDecode(encryptedPlid,'UTF-8')) 
        }
        else{
            blobPlid = EncodingUtil.base64Decode(encryptedPlid);
        }
        Blob decryptedMasterRecordId = Crypto.decryptWithManagedIV('AES256', cryptoKey, blobPlid);
        Id plid= decryptedMasterRecordId.toString(); 
        system.debug('@@@@11: '+plid);
        WrapperList = new List<wrapperPSFR>{ new wrapperPSFR( 0 ) };
            // recordlink=BPMComUrl+'/PSFR_Site_Page?id='+plid;
            recordlink= BPMComUrl+'/PSFR_Site_Page?Plid='+encryptedPlid;
        
        
        
 /*
#####################################################################################################################
*/
        
        ChildRecords =
            [
                SELECT 
                Name,
                PFR_Num_of_days_not_to_exceed__c,
                PFR_BU__c,
                PFR_Daily_Rate_USD__c,
                PSFundingRequest__c,
                PFR_Resource_Name__c,
                Submit_for_Approval_to_PS_Leader__c,
                PFR_Task__c,
                PFR_Total__c,
                PFR_Travel_Cost__c
                
                FROM
                Resource__c
                WHERE 
                PSFundingRequest__r.id = :plid
            ];
        
        /*
#####################################################################################################################
*/      
        /*

ListResource = new  List<Resource__c>();
system.debug('recordlink when page reloads ::' +recordlink);
Resource.PSFundingRequest__c=ApexPages.currentPage().getParameters().get('Plid');
MasterRecordId =ApexPages.currentPage().getParameters().get('Plid');
// ListResource.add(Resource);  


*/
        
    }
    
    /*
#####################################################################################################################
*/
    
    public void addResource(){
        WrapperList.add( new wrapperPSFR( WrapperList.size() ) );
        
    }
    
    /*
#####################################################################################################################
*/
    
    public void removeResource(){
        
        if( WrapperList.size() > 0 && COUNT_FRM_PAGE != null &&  COUNT_FRM_PAGE != 0 )
            WrapperList.remove( COUNT_FRM_PAGE );
        
        
    }
    
    /*
#####################################################################################################################
*/
    
    public void Calcualte(){
        List<decimal> tLst = new List<decimal>();//variable name changed - totalList to tLst -EBA_SF-1669 
        rm = new Resource__c( PFR_Travel_Cost__c=0, PFR_Num_of_days_not_to_exceed__c=0,PFR_Daily_Rate_USD__c=0,Total_Value__c=0 );
        TotalHours=0;
        /*
#####################################################################################################################
*/
        
        for( wrapperPSFR WL : WrapperList ){ 
             //EBA_SF_1733 Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 2
           Blob blobPlid;
           String KeysForSecuredUrls = KeysForSecuredUrls__c.getValues('PSFREncryptionKey').CryptoKey__c;
            Blob cryptoKey = Blob.valueOf(KeysForSecuredUrls);
            String encryptedPlid = ApexPages.currentPage().getParameters().get('Plid');// new variable created to store plid - EBA_SF-1669
            if (Test.isRunningTest()){
                //blobPlid = EncodingUtil.base64Decode(encodingUtil.URLDecode(encryptedPlid,'UTF-8')); 
                blobPlid = EncodingUtil.base64Decode(encryptedPlid); //EncodingUtil.base64Decode(encodingUtil.URLDecode(encryptedPlid,'UTF-8')) 
            }
            else{
               blobPlid = EncodingUtil.base64Decode(encryptedPlid);  
            }
            Blob decryptedMasterRecordId = Crypto.decryptWithManagedIV('AES256', cryptoKey, blobPlid);
            Id plid= decryptedMasterRecordId.toString();
            //WL.Reso.PSFundingRequest__c = ApexPages.currentPage().getParameters().get('Plid');
             WL.Reso.PSFundingRequest__c=plid;
            WL.Reso.Submit_for_Approval_to_PS_Leader__c = true;
            if(WL.Reso.PFR_Travel_Cost__c !=null)
                rm.PFR_Travel_Cost__c += WL.Reso.PFR_Travel_Cost__c;
            if(WL.Reso.PFR_Daily_Rate_USD__c !=null)
                rm.PFR_Daily_Rate_USD__c +=WL.Reso.PFR_Daily_Rate_USD__c;
            if(WL.Reso.PFR_Num_of_days_not_to_exceed__c != null)
                rm.PFR_Num_of_days_not_to_exceed__c += WL.Reso.PFR_Num_of_days_not_to_exceed__c;
            decimal t = 0;
            if(WL.Reso.PFR_Daily_Rate_USD__c!=null&&WL.Reso.PFR_Travel_Cost__c!=null&&WL.Reso.PFR_Num_of_days_not_to_exceed__c!=null){
            	t = WL.Reso.PFR_Travel_Cost__c + (WL.Reso.PFR_Daily_Rate_USD__c * WL.Reso.PFR_Num_of_days_not_to_exceed__c);
            }
            tLst.add(t);
            
        }
        
        /*
#####################################################################################################################
*/
        
        for( Decimal t : tLst ){
            TotalHours += t;
        }
        
    }
    
    /*
#####################################################################################################################
*/
    
    public class wrapperPSFR{        
        
        public Resource__c Reso { get;set; }
        public integer Count{get;set;}
        //public Decimal Sum{get;set;}
       
        public wrapperPSFR( integer c ){
            this.Reso = new Resource__c();
             //EBA_SF_1733 Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 2
             Blob blobPlid;
            this.Reso.PFR_BU__c = 'PS';
            //this.Reso.PSFundingRequest__c=ApexPages.currentPage().getParameters().get('Plid');
            String KeysForSecuredUrls = KeysForSecuredUrls__c.getValues('PSFREncryptionKey').CryptoKey__c;
            Blob cryptoKey = Blob.valueOf(KeysForSecuredUrls);
            String encryptedPlid = ApexPages.currentPage().getParameters().get('Plid');// new variable created to store plid - EBA_SF-1669
            if (Test.isRunningTest()){
                blobPlid = EncodingUtil.base64Decode(encryptedPlid);
               // blobPlid = EncodingUtil.base64Decode(encodingUtil.URLDecode(encryptedPlid,'UTF-8')); 
            }
            else{
                blobPlid = EncodingUtil.base64Decode(encryptedPlid);  
            }
              
            Blob decryptedMasterRecordId = Crypto.decryptWithManagedIV('AES256', cryptoKey, blobPlid);
            Id plid= decryptedMasterRecordId.toString();
            this.Reso.PSFundingRequest__c=plid;
            
            this.Count = c;
        }
        
    }
    
    
    
    /***************************************/
    
    /*
#####################################################################################################################
*/    
    
    public pagereference saveResource() 
    {   
        System.debug('@@@: '+ApexPages.currentPage().getParameters());
         //EBA_SF_1733 Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 2
     		String KeysForSecuredUrls = KeysForSecuredUrls__c.getValues('PSFREncryptionKey').CryptoKey__c;
     		Blob cryptoKey = Blob.valueOf(KeysForSecuredUrls);
            String encryptedPlid = ApexPages.currentPage().getParameters().get('Plid');// new variable created to store plid - EBA_SF-1669
            Blob blobPlid = EncodingUtil.base64Decode(encryptedPlid);    
            Blob decryptedMasterRecordId = Crypto.decryptWithManagedIV('AES256', cryptoKey, blobPlid);
            Id plid= decryptedMasterRecordId.toString();
   	 //Id plid = ApexPages.currentPage().getParameters().get('Plid'); // new variable created to store plid - EBA_SF-1669
     Id psid = null; // new variable created to store psid - EBA_SF-1669
        // Id psid = ApexPages.currentPage().getParameters().get('psid'); // new variable created to store psid - EBA_SF-1669
     Presales_Funding_Request__c masrec = new Presales_Funding_Request__c(); //variable name changed - MasterRecord to masrec -EBA_SF-1669 
     masrec = [select id, Approval_Status__c,Raised_Objection_Status__c from Presales_Funding_Request__c where id=:plid ];
     //EBA_SF-1347
     List<Resource__c> tLst = new List<Resource__c>();//variable name changed - TempList to tLst -EBA_SF-1669 
         //EBA_SF_1733 Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 2
        string encodedCipherText = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', cryptoKey, Blob.valueOf(plid)));
        string encryptedMasterRecordId = encodingUtil.URLEncode(encodedCipherText,'UTF-8');
        
        
     If(masrec.Approval_Status__c == 'Sent to PS' || masrec.Approval_Status__c == 'On Hold')
     { 
         for( wrapperPSFR WL : WrapperList ){
         Resource__c RES = new Resource__c();
         
         RES.PFR_Travel_Cost__c=WL.Reso.PFR_Travel_Cost__c;
         RES.Completed_by_Email__c =CompletedbyEmail;
         RES.PFR_BU__c=WL.Reso.PFR_BU__c;
         RES.Completed_By_Name__c = CompletedbyName ;
         RES.PSFundingRequest__c=plid;
         RES.PFR_Num_of_days_not_to_exceed__c=WL.Reso.PFR_Num_of_days_not_to_exceed__c;
         RES.PFR_Daily_Rate_USD__c=WL.Reso.PFR_Daily_Rate_USD__c;
         RES.PFR_Resource_Name__c=WL.Reso.PFR_Resource_Name__c;
         RES.PFR_Task__c=WL.Reso.PFR_Task__c;
         RES.PFR_Travel_Cost__c=WL.Reso.PFR_Travel_Cost__c;
         //EBA_SF-1347
         // upsert RES;
         tLst.add(RES);
         }
          //EBA_SF_1733 Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 2
         id= BPMComUrl+'/PSFR_Site_Page?Plid='+encryptedMasterRecordId+'&psid='+Psid+'&Page='+'SaveR';
         //id= BPMComUrl+'/PSFR_Site_Page?id='+plid+'&psid='+psid;
         
     }
     else{
          //EBA_SF_1733 Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 2
          id= BPMComUrl+'/PSFR_Resource_Save_Success?Plid='+encryptedMasterRecordId+'&psid='+Psid+'&Page='+'SaveR';
         //id=BPMComUrl+'/PSFR_Resource_Save_Success?Plid='+plid+'&psid='+psid;
     }
     //EBA_SF-1347
     if(tLst.size()>0) {  upsert tLst;  }     
     
     PageReference  pr= new PageReference(id);//variable name changed from reRender to pr - EBA_SF-1669
     pr.setRedirect(True);
     return (pr); 
    }
    
    /*
#####################################################################################################################
*/
    
}