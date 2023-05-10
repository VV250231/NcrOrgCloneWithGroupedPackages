@isTest 
private class MqlSqlSalDateStamp_test {
    static testMethod void MqlSqlSalDateStamp() {
       Lead l = new lead();
       l.lastname = 'test';
       //l.recordtypeid = '012700000001S2W' ;
       l.status = 'open';
       l.company = 'test' ;
       insert l;
    
       // Retrieve the new book
       l = [SELECT id, status FROM lead WHERE Id =:l.Id];
       l.status = 'Accepted';
       update l;
       
              l = [SELECT id, status FROM lead WHERE Id =:l.Id];
       l.status = 'Qualified';
       update l;
       lead leadObj = [SELECT id, status FROM lead WHERE Id =:l.Id];
       System.assert(leadObj.status == 'Qualified');
       }
}