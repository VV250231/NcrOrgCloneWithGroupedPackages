/*   Created by   : Saagar Kinja
*    Email ID    : saagar.kinja@ncr.com 
*    QLID        : SK250817
*    Details     : This Trigger will update fields, trigger emails. Please find below respective comment for more details :

*/
trigger PSFR_Update on Presales_Funding_Request__c (before insert,before update, after update) 
{
   if((Trigger.isInsert && Trigger.isBefore) || (Trigger.isUpdate && Trigger.isBefore)) {
        PSFR_UpdateHandler.PSFR_Updates(Trigger.new);
    }
    
    if((Trigger.isAfter && Trigger.isUpdate)) {
        PSFR_UpdateHandler.PSFR_SubmitforApproval(Trigger.new,Trigger.old);
    }
    
    /*List <ID> OPPIdList = new  List <ID>();
    List <ID> AccIdList = new  List <ID>();
    Map<Id ,Opportunity> OppMap  = new Map<Id ,Opportunity>();
    Map<Id ,Account> AccMap= new Map<Id ,Account>();
    For(Presales_Funding_Request__c pse:Trigger.New)
    { 
        OPPIdList.add(pse.PFR_Opportunity__c);
        AccIdList.add(pse.Account__c); 
    } 
    
    If(OPPIdList!=null)
    {
        OppMap = new Map<Id ,Opportunity>([Select id ,Account.id,
                                           Account.Owner.Email,Owner.Email,
                                           Account.Account_Country_Code__c, Account.Account_Region__c,Account.Area__c, 
                                           Owner.Manager.Email
                                           From Opportunity Where id =: OPPIdList]);
    }
    
    If(AccIdList!=null)
    { 
        AccMap = new Map<Id,Account>([Select id, Owner.Email, Area__c
                                      From   Account
                                      Where   id=:AccIdList]);
    }               
    
    if(Trigger.IsBefore)
    {
        
        /*
#####################################################################################################################
*-/
        If(trigger.isinsert)
        {
            for (Integer i = 0; i < Trigger.new.size(); i++)
            {   
                /*
#####################################################################################################################
*-/
                
                If(OppMap!= null && !OppMap.isEmpty() && OppMap.containsKey(Trigger.new[i].PFR_Opportunity__c) )
                {
                    Trigger.new[i].Opportunity_Owner_Manager__c = OppMap.get(Trigger.new[i].PFR_Opportunity__c).Owner.Manager.Email ;
                    Trigger.new[i].Account_Manager__c = OppMap.get(Trigger.new[i].PFR_Opportunity__c).Account.Owner.Email ;
                    Trigger.new[i].Opportunity_Owner__c=OppMap.get(Trigger.new[i].PFR_Opportunity__c).Owner.Email;
                    Trigger.new[i].Account__c= OppMap.get(Trigger.new[i].PFR_Opportunity__c).Account.id;
                    
                }
                /*
#####################################################################################################################
*-/
                
                If(Trigger.new[i].Account__c !=null && Trigger.new[i].PFR_Opportunity__c==null)           
                {       
                    Trigger.new[i].Account_Manager__c = AccMap.get(Trigger.new[i].Account__c).owner.email ;
                }
                /*
#####################################################################################################################
*-/
                
                If(Trigger.new[i].Fund_Request_Owner__c ==null) 
                {
                    Trigger.new[i].Fund_Request_Owner__c=Trigger.new[i].Record_Creator__c;
                }
               
/*
#####################################################################################################################
*-/
                
                If(Trigger.new[i].Division_of_User__c.contains('RET') && Trigger.new[i].R_Sales_Leader__c == null)
                {
                    If(Trigger.new[i].Division_of_User__c != null)
                    {
                        If(Trigger.new[i].Division_of_User__c == 'RET-CIS/RU' || Trigger.new[i].Division_of_User__c=='RET-CIS/RU-MGR')
                        {
                            Trigger.new[i].R_Sales_Leader__c = '00570000003gI9I';
                            Trigger.new[i].Sub_Region_Sales_Leader_Email__c = 'Andriy.Pinkevych@ncr.com';   
                        }
                        else If(Trigger.new[i].Division_of_User__c == 'RET-SE-FRANCE' || Trigger.new[i].Division_of_User__c == 'RET-SE-IBERIA' || Trigger.new[i].Division_of_User__c == 'RET-ISRAEL' || Trigger.new[i].Division_of_User__c == 'RET-ISRAEL-DIRECTOR' || Trigger.new[i].Division_of_User__c == 'RET-SE-ITALY' || Trigger.new[i].Division_of_User__c == 'RET-SE-ITALY-MGR' || Trigger.new[i].Division_of_User__c == 'RET-SE-ITALY-MGR' || Trigger.new[i].Division_of_User__c == 'RET-EMEA-EE-CHANNEL' )
                        {
                            Trigger.new[i].R_Sales_Leader__c = '00570000003j5hS';
                            Trigger.new[i].Sub_Region_Sales_Leader_Email__c = 'Guy.Perry@ncr.com';                                       
                        }
                        else If(Trigger.new[i].Division_of_User__c == 'RET-EMEA-UKI' || Trigger.new[i].Division_of_User__c == 'RET EMEA UKI- Sales')
                        {
                            Trigger.new[i].R_Sales_Leader__c = '00570000002U4M9';
                            Trigger.new[i].Sub_Region_Sales_Leader_Email__c = 'js185378@ncr.com';   
                        }
                        else If(Trigger.new[i].Division_of_User__c == 'RET-EMEA-NORDICS' || Trigger.new[i].Division_of_User__c == 'RET-EMEA-EE-CHANNEL' || Trigger.new[i].Division_of_User__c == 'RET-EMEA-EE-CHANNEL-MGR' || Trigger.new[i].Division_of_User__c == 'RET-MEA-CHANNEL')
                        {
                            Trigger.new[i].R_Sales_Leader__c = '00570000003jQjK';
                            Trigger.new[i].Sub_Region_Sales_Leader_Email__c = 'ok185014@ncr.com';   
                        }
                        else If(Trigger.new[i].Division_of_User__c == 'RET-EMEA-CE-GERMANY')
                        {
                            Trigger.new[i].R_Sales_Leader__c = '00570000001R8tf';
                            Trigger.new[i].Sub_Region_Sales_Leader_Email__c = 'Stefan.Clemens@ncr.com';   
                        }
                        else If(Trigger.new[i].Division_of_User__c == 'RET-PCR-MGR')
                        {
                            Trigger.new[i].R_Sales_Leader__c = '00570000002Ti7k';
                            Trigger.new[i].Sub_Region_Sales_Leader_Email__c = 'yy185027@ncr.com';   
                        }
                        else
                        {
                            Trigger.new[i].R_Sales_Leader__c = '00570000003hDvY';
                            Trigger.new[i].Sub_Region_Sales_Leader_Email__c = 'Mark.Duff@ncr.com';  
                        }
                    }
                    else
                    {   
                        Trigger.new[i].R_Sales_Leader__c ='00570000003hDvY';
                        Trigger.new[i].Sub_Region_Sales_Leader_Email__c = 'Mark.Duff@ncr.com';
                    }
                }
                
                /*
#####################################################################################################################
*-/
                
                If(Trigger.new[i].Approval_Status__c !='New')
                {
                    Trigger.new[i].adderror('PreSales Fund Request can only be created with New Status'); 
                }
                /*
#####################################################################################################################
*-/
                
                /*    
                If(! Trigger.new[i].Division_of_User__c.contains('FIN'))
                {
                Trigger.new[i].addError("Only Finance Presales Funding Request can be created in system");  
                
                }
                *-/  
                If(Trigger.new[i].TriggerController__c == True)
                {
                    Trigger.new[i].TriggerController__c = False;
                } 
                
            }
            
        }                  
        
        
        /*
#####################################################################################################################
*-/
        
        if(trigger.isupdate)
        {  
            for(integer i = 0; i<Trigger.new.size();i++)
            {
                
                /*
#####################################################################################################################
*-/
                
                If(Trigger.new[i].Approval_Status__c=='Approved')
                {
                    string PSFRCategory;
                    
                    If(Trigger.new[i].PFR_Presales_Category__c.contains('1'))
                    {PSFRCategory = '1-Network Cert' ;}
                    
                    if(Trigger.new[i].PFR_Presales_Category__c.contains('2'))
                    {PSFRCategory = '2-Early Presales';}
                    
                    if(Trigger.new[i].PFR_Presales_Category__c.contains('3'))
                    {PSFRCategory = '3-POC';}
                    
                    if(Trigger.new[i].PFR_Presales_Category__c.contains('4'))
                    {PSFRCategory = '4-SOW';}
                    
                    if(Trigger.new[i].PFR_Presales_Category__c.contains('5'))
                    {PSFRCategory = '5-PS work-ahead';}
                    
                    if(Trigger.new[i].PFR_Presales_Category__c.contains('6'))
                    {PSFRCategory = '6-Non Standard';}                 
                    
                    If(OppMap!= null && !OppMap.isEmpty() && OppMap.containsKey(Trigger.new[i].PFR_Opportunity__c)  )
                    { 
                        Trigger.new[i].PFR_Approval_Number__c =  OppMap.get(Trigger.new[i].PFR_Opportunity__C).Account.Account_Region__c+'_'+OppMap.get(Trigger.new[i].PFR_Opportunity__C).Account.Account_Country_Code__c+'_'+system.today().Year()+system.today().Month()+'_'+Trigger.new[i].name+'_'+PSFRCategory+'_'+Trigger.new[i].Total_Value_of_Resources__c+'_'+Trigger.new[i].Recoverable__c;
                    }
                    else 
                    {
                        Trigger.new[i].PFR_Approval_Number__c =  '_'+system.today().Year()+system.today().Month()+'_'+Trigger.new[i].name+'_'+PSFRCategory+'_'+Trigger.new[i].Total_Value_of_Resources__c+'_'+Trigger.new[i].Recoverable__c;
                    }
                    
                }
                
                /*
#####################################################################################################################
*-/ 
                
                If(Trigger.new[i].PSFR_Authentication_Trigger__c==True)
                {
                    Trigger.new[i].PSFR_Authentication_Token_Text__c = '#'+string.valueOf(Trigger.new[i].Name)+'#'+string.valueOf(Trigger.new[i].lastModifiedDate)+string.valueOf(Trigger.new[i].TriggerController__c)+string.valueOf(Trigger.new[i].Region__c)+string.valueOf(Trigger.new[i].Recoverable__c)+'###'+string.valueOf(Trigger.new[i].Division_of_User__c)+'#';
                    
                }
                
                If(Trigger.new[i].PSFR_PSANumber__c != null && Trigger.new[i].Approval_Status__c !='Approved')
                {
                    Trigger.new[i].adderror('PSA Number can only be added after Approved Request'); 
                }
            }
            
            
        }
        
        
    } */
}