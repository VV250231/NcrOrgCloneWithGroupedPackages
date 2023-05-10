@Istest
class ChangeIdeaStatusScheduledTEST{
    static testmethod void testChangeIdeaStatusScheduled() {
        Community community = [ SELECT Name, Id FROM Community WHERE IsActive = true LIMIT 1 ];
        Idea idObj = new Idea(Title = 'Test_Idea123',Status = 'Under Point Threshold',communityId =community.Id,Body='Body');
        insert idObj;
        List<vote> voteList = new list<vote>();
        List<User> userList = [select id from user where profile.name='04 NSC UI Administrator' and  isActive = true limit 10];
        for(integer i=0;i<10;i++){
            System.runAs(userList[i]){
                vote voteObj = new vote(parentid=idObj.id,type='Up');
                voteList.add(voteObj);
                insert voteObj;
            }
        }
        Test.startTest();
        String sch = '0 0 * * * ?';
        String jobId = System.schedule('ChangeIdeaStatusScheduled', sch, new ChangeIdeaStatusScheduled());
        Test.stopTest();
        Idea idObj1 = [select status from idea where id=:idObj.id];
        System.assert(idObj1.status!=null);
    }
}