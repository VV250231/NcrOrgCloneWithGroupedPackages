/*
##################################################################################################
# Project Name..........: Account Point Of Contact(APOC)
# File............................: UserDownExtension.cls                                                        
# Created by................: Varsha Pal                                                                   
# Created Date...........: 03/02/2020 (MM/DD/YYYY)                                                                             
# Last Modified by......:  Varsha Pal
# Last Modified Date..: 03/02/2020 (MM/DD/YYYY)
# Description...............: This class is used from visualforce page(DowngradeOfUser) associated to a custom link(Downgrade) on user record if we want to downgrade
an employee(who is a salesforce standard user) to the partner license user(if APOC records assigned to downgraded user else it will just deactivate the user)
# Test Class - UserUpDownTest
# JIRA Story - #EBA_SF-1092(P1: APOC: APOC record re-assignment automation) 
##################################################################################################
*/
public class UserDownExtension{
    public Id uId {get;set;}
    public string errormsg{get;set;}
    public boolean showerr{get;set;}
    public string succMsg{get;set;}
    public String lname,uname,qlid;
    public User usr;
    public boolean isAPOCUsr{get;set;}
    public Contact c;
    public User u{get;set;}
    public UserDownExtension(ApexPages.standardController con){
        uId = con.getId();
        showerr=false;
    }
    public pagereference downgrade(){
        usr =[Select id,usertype,isactive,username,firstname,lastname,Quicklook_Id__c,Email from user where id =:uid];
        if(usr.Quicklook_ID__c.length()>8||!usr.IsActive){
            errormsg=UpDownGrade__c.getValues('DwnErrMsg').value__c;//This user is already downgraded.
            showerr=true;
        }else{
            if(usr.UserType=='PowerPartner'){
                errormsg=UpDownGrade__c.getValues('DwnErrMsgStd').value__c;//You cannot downgrade the salesforce community license
                showerr=true;
            }
            lname = usr.lastname;
            uname = usr.Username;
            qlid = usr.Quicklook_ID__c;	
        }
        return null;
    }
    public pagereference save(){  
        List<ASM_Role_Hierarchy__c> APOCL = [select id from ASM_Role_Hierarchy__c where Role_User_Name__c = :uId and Role_User_Name__c!=null];         
        User u;
        if(APOCL.size()>0){
            String ms = '-'+string.valueof(Math.abs(Crypto.getRandomLong())).substring(0,2);
            u = new User(id = usr.id,lastname = lname+'-INACTIVE',Username = uname+ms,Quicklook_ID__c = qlid+ms,IsActive = false);
            isAPOCUsr= true;
            UserDeactivateNotification.manUpdt = false;
        }else{
            u = new User(id = usr.id,IsActive = false);
            isAPOCUsr = false;
        }
        try{
            update u;
            if(!isAPOCUsr){
            	return new PageReference(String.format(UpDownGrade__c.getValues('UserLink').value__c,new List<String>{URL.getSalesforceBaseUrl().getHost(),u.id}));
            }else{
                return null;
            }
            	//succMsg = UpDownGrade__c.getValues('SuccMsg').value__c;
        }catch(Exception e){
            errormsg=e.getMessage();
                showerr=true;
            return null;
        }
    }
    public pagereference createCon(){
        if(isAPOCUsr){
            String qlidlike = '%'+qlid+'%';
            List<User> usrs = [Select id,isactive,username,quicklook_Id__c,lastname,profileId from User where quicklook_Id__c like :qlidlike and usertype='powerpartner' and user_profile__C='BPM Partner Community User'];
            if(usrs.size()>=1){
                User u = new User(id = usrs[0].id,lastname = lname,Username = uname,Quicklook_ID__c = qlid,isactive = true);
                try{
                    update u;
                  //  succMsg = UpDownGrade__c.getValues('SuccMsg').value__c;//Congratulations,User downgraded successfully!!!
                }catch(Exception e){
                    errormsg=e.getMessage();
                    showerr=true;
                }  
            }
            else{
                try{
                    c= new contact(Firstname=usr.FirstName,Lastname=lname,Quicklook_id__C=qlid,isbpmcommunityuser__C=true,accountid=UpDownGrade__c.getValues('PrtnrAccId').value__c,email=usr.Email);
                    insert c;
                    //succMsg = UpDownGrade__c.getValues('SuccMsg').value__c;//Congratulations,User downgraded successfully!!!
                    
                }catch(Exception e){
                     errormsg=e.getMessage();
                    showerr=true;
                }
            }
       		Database.executeBatch(new APOCReassignmentBatch(uId));
        }
        return null;
    }
    public pagereference getUsr(){
        if(!showErr){
            try{
                u = [Select id from user where quicklook_id__c = :qlid];
                 UserUpExtension.copyPermSet(usr.id,u.id);
                return new PageReference(String.format(UpDownGrade__c.getValues('UserLink').value__c,new List<String>{URL.getSalesforceBaseUrl().getHost(),u.id}));
            }
            catch(Exception e){
                succMsg = UpDownGrade__c.getValues('UsrNotFndMsg').value__c;//Process completed but unable to validate the user. Please check user manually. If not found, try again.
                return null;
            }
        }else{
            return null;
        }
    }
     public pagereference cancel(){
		return new PageReference(String.format(UpDownGrade__c.getValues('UserLink').value__c,new List<String>{URL.getSalesforceBaseUrl().getHost(),usr.id}));
     }
}