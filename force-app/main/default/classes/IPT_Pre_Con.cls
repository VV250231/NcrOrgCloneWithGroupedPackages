public class IPT_Pre_Con {
	@AuraEnabled
    public static UserDetail getUserDetail() {
        UserDetail uDetail = new UserDetail();
        uDetail.fristName = UserInfo.getFirstName();
        uDetail.lastName = UserInfo.getLastName();
        uDetail.Email = UserInfo.getUserEmail();   
        return uDetail;
    }
    
    public Class UserDetail {
        @AuraEnabled public String fristName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String Email;
    }
}