public class coOpReqExt {
    public User currentUser {get;set;}
    
    public coOpReqExt(ApexPages.StandardController sc) {
        List<User> users = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
        if (users.size() > 0)
        currentUser  = users[0];
    }
}