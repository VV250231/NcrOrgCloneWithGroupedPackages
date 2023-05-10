/* last modified for EBA_SF-1669 by Varsha & EBA_SF-1687 by Monika.
EBA_SF-1669 - to reduce the code and remove the code for covering this class and now used the PSFRResource_R_Test to cover this class to deploy it in production
and  EBA_SF-1687 - to remove hardcoded URL is under comment */
/****************************************************************************************************************
*   ClassName :   PSFRApexController
*   Description :   PSFRResource_R_Test
*   Author      :   
*   Version     :   Initial
* Test Class : 
# Modification History.: 
Story No#         Date            DevName                Description
EBA_SF-1669       8th Dec 2021    Varsha Pal             Remove the testcoverage function
EBA_SF-2491       19-12-2022      Monika                 JDK Locale impact - Upgrade API Part 5  
****************************************************************************************************************/
public without sharing class PSFRApexController 
{
  public String Page {get; set;}
  public String MasterRecordId {get; set;}
  public String PsidRecordId {get; set;}
  public String recordlink{ get; private set; }
  public String Link{get;private set;}
  public String PS_Token{ get; set; }
  public List<Resource__c> ChildRecords{get;set;}
  //public String PS_Email { get; set; }
  public Presales_Funding_Request__c MasterRecord  {get; set;}
  public List<Presales_Engineer__c> PSRecords {get; set;}
  String BPMComUrl=System.Label.BPM_Employee_Community_URL;// variable name changed BPMEmployeeCommunity to BPMComUrl - EBA_SF-1669
  /*
  #####################################################################################################################
   */
  public PSFRApexController()
  {
    Page = ApexPages.currentPage().getParameters().get('Page');
    MasterRecordId = ApexPages.currentPage().getParameters().get('id');
    PsidRecordId = ApexPages.currentPage().getParameters().get('psid');
       //EBA_SF_1733 Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 2
    String KeysForSecuredUrls = KeysForSecuredUrls__c.getValues('PSFREncryptionKey').CryptoKey__c;  
      if(Page !=null){ 
          Blob cryptoKey = Blob.valueOf(KeysForSecuredUrls);
          String encryptedPlid = ApexPages.currentPage().getParameters().get('Plid');
          Blob blobPlid = EncodingUtil.base64Decode(encryptedPlid);    
          Blob decryptedMasterRecordId = Crypto.decryptWithManagedIV('AES256', cryptoKey, blobPlid);
          MasterRecordId= decryptedMasterRecordId.toString();
      }
      if(!String.isBlank(MasterRecordId))
      {
      MasterRecord =
            [       SELECT  
                    Name,
                    PFR_Account_Name__c,
                    Account__c,
                    Region__c,
                    PFR_Approval_Number__c,
                    PFR1_Expected_Book_Date__c,
                    PS_Product__c,
                    Cloud_Products__c,
                    PFR_Expected_Date__c,
                    PFR_Forecast_Category__c,
                    Approval_Status__c,
                    Services_Products__c,
                    PFR_Opportunity__r.Name,
                    PFR_Hardware_Products__c,
                    PFR_Is_this_Recoverable__c,
                    PFR_Justification__c,
                    PFR_Opportunity__c,
                    PFR_Opportunity_Amount__c,
                    PFR_Opportunity_Number__c,
                    PFR_Opportunity_Owner__c,
                    PFR_Opportunity_Selling_Stage__c,
                    PFR_Presales_Category__c,
                    PSFR_Rec_Authentication_Token__c,
                    PS_Team_User1__c,
                    PS_Team_User2__c,
                    PS_Team_User3__c,
                    PS_Team_User4__c,
                    PS_Team_User5__c,
                    PS_Team_User6__c,
                    Account__r.name,
                    PSFR_Authentication_Token_Text__c,
                    PSFR_Authentication_Trigger__c,
                    Resource_S__c,
                    PS_Rec_Authentication_Email__c,
                    PFR_Sales_Engineer__c,
                    PFR_Software_Products__c,
                    PFR_Success_Criteria__c,
                    Raised_Objection_Status__c,
                    Total_Hours_not_to_exceed__c,
                    Total_Travel_Cost_of_Resources__c,
                    Total_Value_of_Resources__c,
                    Number_of_Resources__c,
                    Owner.name,
                    Total_Hourly_Rate__c
                FROM
                    Presales_Funding_Request__c
                WHERE
                    Id = :MasterRecordId
            ];
     
     If(MasterRecordId != null )
        {
             //EBA_SF_1733 Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 2
          //recordlink= BPMComUrl+'/PSFR_Resource?Plid='+MasterRecordId;
              //String KeysForSecuredUrls = KeysForSecuredUrls__c.getValues('PSFREncryptionKey').CryptoKey__c;
              Blob cryptoKey = Blob.valueOf(KeysForSecuredUrls);
             string encodedCipherText = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', cryptoKey, Blob.valueOf(MasterRecordId)));
             string encryptedMasterRecordId = encodingUtil.URLEncode(encodedCipherText,'UTF-8');
             recordlink= BPMComUrl+'/PSFR_Resource?Plid='+encryptedMasterRecordId;
         }
        
       
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
                    PSFundingRequest__r.id = :MasterRecordId
            ];
            
            PSRecords=
            [
                SELECT 
                    Email_ID__c,
                    Email_ID_1__c,
                    Email_ID_2__c,
                    Email_ID_3__c,
                    Email_ID_4__c,
                    Email_ID_5__c,
                    Body__c,
                    Name
                    
                FROM
                    Presales_Engineer__c
                WHERE 
                    Presales_Funding_Request__r.id = :MasterRecordId
            ];
            
       }
           
     }
     
        /*
        #####################################################################################################################
        */
       public PageReference AddResource() 
       {
         
         
         If(MasterRecord.Approval_Status__c =='Sent to PS' || MasterRecord.Approval_Status__c == 'On Hold')
         
         {
              //EBA_SF_1733 Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 2
             String KeysForSecuredUrls = KeysForSecuredUrls__c.getValues('PSFREncryptionKey').CryptoKey__c;
      		 Blob cryptoKey = Blob.valueOf(KeysForSecuredUrls);
             string encodedCipherText = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', cryptoKey, Blob.valueOf(MasterRecordId)));
             string encryptedMasterRecordId = encodingUtil.URLEncode(encodedCipherText,'UTF-8');
             Link= BPMComUrl+'/PSFR_Resource?Plid='+encryptedMasterRecordId+'&psid='+PsidRecordId+'&Page='+'AddResource';
             
             //Link= BPMComUrl+'/PSFR_Resource?Plid='+MasterRecordId+'&psid='+PsidRecordId ;
         }
           
            else
             
               {
                    //EBA_SF_1733 Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 2
               String KeysForSecuredUrls = KeysForSecuredUrls__c.getValues('PSFREncryptionKey').CryptoKey__c;
      	 	    Blob cryptoKey = Blob.valueOf(KeysForSecuredUrls);
             	string encodedCipherText = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', cryptoKey, Blob.valueOf(MasterRecordId)));
             	string encryptedMasterRecordId = encodingUtil.URLEncode(encodedCipherText,'UTF-8');
             	Link= BPMComUrl+'/PSFR_Resource_Save_Success?Plid='+encryptedMasterRecordId+'&psid='+PsidRecordId+'&Page='+'AddResource';
               // Link=BPMComUrl+'/PSFR_Resource_Save_Success?Plid='+MasterRecordId+'&psid='+PsidRecordId ;
              
               }
         
         PageReference pr = new PageReference(Link);//variable name changed from reRender to pr - EBA_SF-1669
         pr.setRedirect(True);
         return (pr); 
       }
       
       /*
        #####################################################################################################################
        */
        
       public PageReference Submit()
        
       { 
            If(MasterRecord.Approval_Status__c =='Sent to PS' || MasterRecord.Approval_Status__c == 'On Hold')
               {  
               MasterRecord.Approval_Status__c = 'Pending for Approval';
               update MasterRecord;
                    //EBA_SF_1733 Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 2
                String KeysForSecuredUrls = KeysForSecuredUrls__c.getValues('PSFREncryptionKey').CryptoKey__c;
      			Blob cryptoKey = Blob.valueOf(KeysForSecuredUrls);
             	string encodedCipherText = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', cryptoKey, Blob.valueOf(MasterRecordId)));
             	string encryptedMasterRecordId = encodingUtil.URLEncode(encodedCipherText,'UTF-8');
             	Link= BPMComUrl+'/PSFR_Site_Page?Plid='+encryptedMasterRecordId+'&psid='+PsidRecordId+'&page='+'Submit';
                  //Link =BPMComUrl+'/PSFR_Site_Page?id='+MasterRecordId+'&psid='+PsidRecordId; 
                
                   
               }
               
               else
                   {  
                        //EBA_SF_1733 Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 2
                       String KeysForSecuredUrls = KeysForSecuredUrls__c.getValues('PSFREncryptionKey').CryptoKey__c;
      					Blob cryptoKey = Blob.valueOf(KeysForSecuredUrls);
             		   string encodedCipherText = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', cryptoKey, Blob.valueOf(MasterRecordId)));
             		   string encryptedMasterRecordId = encodingUtil.URLEncode(encodedCipherText,'UTF-8');
             		   Link= BPMComUrl+'/PSFR_Resource_Save_Success?Plid='+encryptedMasterRecordId+'&psid='+PsidRecordId+'&Page='+'Submit';
                      //Link=BPMComUrl+'/PSFR_Resource_Save_Success?Plid='+MasterRecordId+'&psid='+PsidRecordId ;
                      
                     
                    }
         PageReference pr = new PageReference(Link);//variable name changed from reRender to pr - EBA_SF-1669
         pr.setRedirect(True);
         return (pr); 
        
        }   
        
        /*
        #####################################################################################################################
        */
        
        public void save()
       { 
          update ChildRecords;
        }  
        
        /*
        #####################################################################################################################
        */
        
        public PageReference Cancel()
        
        { 
           //EBA_SF_1733 Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 2
         String KeysForSecuredUrls = KeysForSecuredUrls__c.getValues('PSFREncryptionKey').CryptoKey__c;
         Blob cryptoKey = Blob.valueOf(KeysForSecuredUrls);
          string encodedCipherText = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', cryptoKey, Blob.valueOf(MasterRecordId)));
          string encryptedMasterRecordId = encodingUtil.URLEncode(encodedCipherText,'UTF-8');
          Link= BPMComUrl+'/PSFR_Site_Page?Plid='+encryptedMasterRecordId+'&psid='+PsidRecordId+'&Page='+'Cancel';  
         //Link =BPMComUrl+'/PSFR_Site_Page?id='+MasterRecordId+'&psid='+PsidRecordId ;  
         PageReference pr = new PageReference(Link);//variable name changed from reRender to pr - EBA_SF-1669
         pr.setRedirect(True);
         return (pr); 
        }  
        
        /*
        #####################################################################################################################
        */
        
        public PageReference EditR() 
       {
          If(MasterRecord.Approval_Status__c =='Sent to PS' || MasterRecord.Approval_Status__c == 'On Hold' )
             {
                  //EBA_SF_1733 Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 2
                String KeysForSecuredUrls = KeysForSecuredUrls__c.getValues('PSFREncryptionKey').CryptoKey__c;
                Blob cryptoKey = Blob.valueOf(KeysForSecuredUrls);
             	string encodedCipherText = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', cryptoKey, Blob.valueOf(MasterRecordId)));
             	string encryptedMasterRecordId = encodingUtil.URLEncode(encodedCipherText,'UTF-8');
                    Link= BPMComUrl+'/PSFR_Resource_Edit?Plid='+encryptedMasterRecordId+'&psid='+PsidRecordId+'&Page='+'EditR';
              // Link= BPMComUrl+'/PSFR_Resource_Edit?id='+MasterRecordId+'&psid='+PsidRecordId ;
              }
                else
               { 
                    //EBA_SF_1733 Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 2
               String KeysForSecuredUrls = KeysForSecuredUrls__c.getValues('PSFREncryptionKey').CryptoKey__c;
                Blob cryptoKey = Blob.valueOf(KeysForSecuredUrls);  
             	string encodedCipherText = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', cryptoKey, Blob.valueOf(MasterRecordId)));
             	string encryptedMasterRecordId = encodingUtil.URLEncode(encodedCipherText,'UTF-8');
             	Link= BPMComUrl+'/PSFR_Resource_Save_Success?Plid='+encryptedMasterRecordId+'&psid='+PsidRecordId+'&Page='+'EditR';
               //Link=BPMComUrl+'/PSFR_Resource_Save_Success?Plid='+MasterRecordId+'&psid='+PsidRecordId ;
              
                }
             
            PageReference pr = new PageReference(Link);//variable name changed from reRender to pr - EBA_SF-1669
            pr.setRedirect(True);
            return (pr); 
       }  
       
       /*
        #####################################################################################################################
        */
        
        public PageReference Auth_Check() 
       {    
             If(MasterRecord.PSFR_Authentication_Token_Text__c == PS_Token)
             
             {    MasterRecord.PSFR_Rec_Authentication_Token__c = PS_Token;
                  MasterRecord.PSFR_Authentication_Trigger__c = False;
                  update MasterRecord;
                  //EBA_SF_1733 Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 2
                String KeysForSecuredUrls = KeysForSecuredUrls__c.getValues('PSFREncryptionKey').CryptoKey__c;
                Blob cryptoKey = Blob.valueOf(KeysForSecuredUrls);
             	string encodedCipherText = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', cryptoKey, Blob.valueOf(MasterRecordId)));
             	string encryptedMasterRecordId = encodingUtil.URLEncode(encodedCipherText,'UTF-8');
             	Link= BPMComUrl+'/PSFR_Site_Page?Plid='+encryptedMasterRecordId+'&psid='+PsidRecordId+'&Page='+'AuthCheck';
                // Link =BPMComUrl+'/PSFR_Site_Page?id='+MasterRecordId+'&psid='+PsidRecordId ; 
                
             } 
             
             else
                   { //EBA_SF_1733 Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 2
                       String KeysForSecuredUrls = KeysForSecuredUrls__c.getValues('PSFREncryptionKey').CryptoKey__c;
      				   Blob cryptoKey = Blob.valueOf(KeysForSecuredUrls);
             		   string encodedCipherText = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', cryptoKey, Blob.valueOf(MasterRecordId)));
             		   string encryptedMasterRecordId = encodingUtil.URLEncode(encodedCipherText,'UTF-8');
             		   Link= BPMComUrl+'/PSFR_Authentication_Stage2?Plid='+encryptedMasterRecordId+'&psid='+PsidRecordId+'&Page='+'AuthCheck';
                     //Link= BPMComUrl+'/PSFR_Authentication_Stage2?id='+MasterRecordId+'&psid='+PsidRecordId ;
                    
                    }  

         PageReference pr = new PageReference(Link);//variable name changed from reRender to pr - EBA_SF-1669
         pr.setRedirect(True);
         return (pr); 
       
       } 
        
        /*
        #####################################################################################################################
        */
        
        public PageReference Generate_Auth_Token() 
       {
           If(MasterRecord.Approval_Status__c =='Sent to PS' || MasterRecord.Approval_Status__c == 'On Hold' )
             {
            MasterRecord.PSFR_Authentication_Trigger__c = True;
            MasterRecord.PS_Rec_Authentication_Email__c = PsidRecordId  ;
            update MasterRecord;
                  //EBA_SF_1733 Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 2
               String KeysForSecuredUrls = KeysForSecuredUrls__c.getValues('PSFREncryptionKey').CryptoKey__c;
      		    Blob cryptoKey = Blob.valueOf(KeysForSecuredUrls);
             	string encodedCipherText = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', cryptoKey, Blob.valueOf(MasterRecordId)));
             	string encryptedMasterRecordId = encodingUtil.URLEncode(encodedCipherText,'UTF-8');
             	Link= BPMComUrl+'/PSFR_Authentication_Stage2?Plid='+encryptedMasterRecordId+'&psid='+PsidRecordId+'&Page='+'GenToken';
            //Link= BPMComUrl+'/PSFR_Authentication_Stage2?id='+MasterRecordId+'&psid='+PsidRecordId ;
           
              }
                else
               { 
                    //EBA_SF_1733 Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 2
                String KeysForSecuredUrls = KeysForSecuredUrls__c.getValues('PSFREncryptionKey').CryptoKey__c;
      			Blob cryptoKey = Blob.valueOf(KeysForSecuredUrls);
             	string encodedCipherText = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', cryptoKey, Blob.valueOf(MasterRecordId)));
             	string encryptedMasterRecordId = encodingUtil.URLEncode(encodedCipherText,'UTF-8');
             	Link= BPMComUrl+'/PSFR_Resource_Save_Success?Plid='+encryptedMasterRecordId+'&psid='+PsidRecordId+'&Page='+'GenToken';
               //Link=BPMComUrl+'/PSFR_Resource_Save_Success?Plid='+MasterRecordId+'&psid='+PsidRecordId ;
             
               }
                
            
            PageReference pr = new PageReference(Link);//variable name changed from reRender to pr - EBA_SF-1669
            pr.setRedirect(True);
            return (pr); 
           
       }   
    
         /*	
        #####################################################################################################################	
        */
        
        
        Public void addPS() 
        {
            
            // ListResource.get(1).Submit_for_Approval_to_PS_Leader__c=True; 
             Presales_Engineer__c res = new Presales_Engineer__c(); 
             res.Presales_Funding_Request__c = MasterRecordId;
             PSRecords.add(res); 
        }
        
        /*
        #####################################################################################################################
        */
        
       public PageReference AddPSTeam() 
       {   
           if(PSRecords != null && !PSRecords.isEmpty())
         Upsert PSRecords;
           
           //for(Integer i=0; i<PSRecords.size(); i++) 
             //  {
                  // PSRecords.get(i).Presales_Funding_Request__c = MasterRecordId;
                  // Upsert PSRecords;
              // }
              //  //EBA_SF_1733 Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 2
                String KeysForSecuredUrls = KeysForSecuredUrls__c.getValues('PSFREncryptionKey').CryptoKey__c;
      			Blob cryptoKey = Blob.valueOf(KeysForSecuredUrls);
             	string encodedCipherText = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', cryptoKey, Blob.valueOf(MasterRecordId)));
             	string encryptedMasterRecordId = encodingUtil.URLEncode(encodedCipherText,'UTF-8');
             	Link= BPMComUrl+'/PSFR_Add_PSTeam?Plid='+encryptedMasterRecordId+'&psid='+PsidRecordId+'&Page='+'AddPSTeam';
                //Link= BPMComUrl+'/PSFR_Add_PSTeam?id='+MasterRecordId+'&psid='+PsidRecordId ;
              
                PageReference pr = new PageReference(Link);//variable name changed from reRender to pr - EBA_SF-1669
                pr.setRedirect(True);
                return (pr); 
       }  
 /*
        #####################################################################################################################
    */
}