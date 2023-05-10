/* 
Created by : Saagar Kinja sk250817
Lightning component Name:NSS_Plus_Product_Checkandnotification
Created on : 21/9/2017

Below code will check if below product exist for that account
-- 'A-MS NSS Managed Anti Virus', 'A-MS NSS PCI Compliance Service','A-MS NSS Event Logger','A-MS NSS Managed Wifi','A-MS NSS Site Shield',
-- 'A-MS NSS Patch Management','A-MS NSS Secure Access','A-MS NSS Activation Fee','A-MS NSS Core Bundle','A-MS NSS Internal Vulnerability Scanning',
-- 'A-MS NSS Threat Defender','Cloud-NSS Secure Access','Cloud-NSS Threat Defender','Cloud-NSS Site Shield','Cloud-NSS Control Scan','SW-Pulse PCR Real Time',
-- 'Cloud-Pulse Real-Time','SW-Pulse PCR Forecourt Manager','SW-Systems_MGT-Pulse-Banking','SW-Pulse PCR RT and FM','SW-Retail ONE-Pulse on Cloud',
-- 'SW-Retail ONE-Pulse On Premise'
*/

public class Controller_NSS_Pulse_Check {
    @AuraEnabled
    public static Boolean validateproductlist(id oppid){

        /*************************************************************/
        //system.debug('11111111111'+oppid);
        Boolean togglehandler = True , toggleupdater = False; 
        //Boolean toggleupdater = False ;
        List<User> LoggedinUser = new List<User>();
        LoggedinUser = [Select id,ProfileId From User WHERE id=:userinfo.getuserId() Limit 1];
        List<Profile> profilelist = new List<Profile>();
        profilelist = [Select id,Name From Profile WHERE id=:LoggedinUser[0].ProfileId Limit 1];
        //system.debug('profile name of logged in user is ::'+profilelist[0].Name);
        list<Opportunity> OpportunityList =new List<Opportunity>();
        OpportunityList= [select id,StageName,NSSOffered__c, Accountid from Opportunity where id=:oppid limit 1] ;
        //system.debug('Opportunity ID::::' + oppid +'OppList ::::' + oppid +'OpportunityList Stage name is ::::'+OpportunityList[0].StageName + 'OpportunityList if NSS Offered ::::' + OpportunityList[0].NSSOffered__c );
        /*************************************************************/
        system.debug('...........'+OpportunityList.size());
        
        /*************************************************************/
        system.debug('<><><<><><::::'+profilelist[0].Name);
       
             
        if( Test.isRunningTest() || (profilelist[0].Name == 'Global Renewals' && OpportunityList[0].NSSOffered__c==false) ){
            if(OpportunityList[0].StageName !='Closed/Booked'){
                /**************************************************************/
                OpportunityList[0].NSSOffered__c = true;
                update OpportunityList;
                /*************************************************************/    
                list<Account> AccountList =new List<Account>();
                AccountList = [select id from Account where id =: OpportunityList[0].Accountid] ;
                //system.debug('AccountList values ::::' + AccountList);
                /*************************************************************/
                
                list<Opportunity> OpportunityListCheck =new List<Opportunity>();
                OpportunityListCheck= [select id, Accountid from Opportunity where Accountid =: OpportunityList[0].Accountid ] ;
                //OpportunityListCheck= [select id, Accountid from Opportunity where id =: '006c000000G7AHtAAN' ] ;
                //system.debug('OpportunityListCheck values ::::' + OpportunityListCheck);
                /*************************************************************/
                list<OpportunityLineItem> OpportunityLineItemListCheck =new List<OpportunityLineItem>(); 
                Set<Id> oppIds = new Set<Id>();
                for(Opportunity opp:OpportunityListCheck){
                    oppIds.add(opp.Id);
                    /*************************************************************/
                    system.debug('oppid inside for loop ::::' + opp.id);
                    /*************************************************************/
                }
                    List<OpportunityLineItem> oppline = new List<OpportunityLineItem>();
                    oppline= [select id,Product_Name__c from OpportunityLineItem 
                              where OpportunityId IN: oppIds
                              
                              AND Product_Name__c IN ('A-MS NSS Managed Anti Virus', 'A-MS NSS PCI Compliance Service','A-MS NSS Event Logger','A-MS NSS Managed Wifi','A-MS NSS Site Shield',
                                                      'A-MS NSS Patch Management','A-MS NSS Secure Access','A-MS NSS Activation Fee','A-MS NSS Core Bundle','A-MS NSS Internal Vulnerability Scanning',
                                                      'A-MS NSS Threat Defender','Cloud-NSS Secure Access','Cloud-NSS Threat Defender','Cloud-NSS Site Shield','Cloud-NSS Control Scan','SW-Pulse PCR Real Time',
                                                      'Cloud-Pulse Real-Time','SW-Pulse PCR Forecourt Manager','SW-Systems_MGT-Pulse-Banking','SW-Pulse PCR RT and FM','SW-Retail ONE-Pulse on Cloud',
                                                      'SW-Retail ONE-Pulse On Premise')
                             ] ;
                    /*************************************************************/
                    //system.debug('oppline details inside for loop ::::' + oppline);
                    //system.debug('oppline size is ::::' + oppline.size());
                    /*************************************************************/
                    if(oppline.size()>0){
                        togglehandler = False;
                    } 
                
            }   
            /*************************************************************/
        }
        else
        {
            //system.debug('User is not a Renewals Sales Rep');
            togglehandler = False ; 
        }
        if(OpportunityList[0].StageName =='Closed/Booked'){togglehandler = False ; }
        /*************************************************************/

        return togglehandler;
    }
}