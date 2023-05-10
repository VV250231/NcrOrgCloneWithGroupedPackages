/* ----------------------------------------------------------------------------------------------------------------------------------------------------------
   Name:            IdeaCommentCount.cls
   Description:     On insert, Delete of IdeaComment record 
   Date             Version         Author                             Summary of Changes 
  ------------      ----------      -----------------                  ---------------------------------------------------------------------------------------------------
  12 APR 2016         1.0            Sumit Arora                     Initial Release 
------------------------------------------------------------------------------------------------------------------------------------------------------------ */ 
public class NCR_IdeaCommentCount {
         public static void IdeaCommentInsert(List<IdeaComment> CommentList){
         
        list<idea> IdeaList=new list <idea>();
        Map<Id,id> commentMap=new Map<Id,String>();
        Map<Id,string> usermap=new Map<Id,String>();
        Map<Id,decimal> Countermap=new Map<Id,decimal>();
        for(ideacomment ic:CommentList)
            {
                commentMap.put(ic.createdbyid,ic.ideaid);
            }
            
        if(!commentMap.isEmpty()){  
            for(user user:[select id,Name from user where id in : commentMap.keyset() limit :Limits.getLimitDmlRows()])
            {
                
                usermap.put(commentMap.get(user.id),user.name);
            }
        }


        map<id,idea> idealistnew=new map<id,idea> ([select id,Di_Idea_Product_Manager_Name__c,Counter__c from idea where (id in :usermap.keyset() AND counter__c!=null) limit :Limits.getLimitDmlRows()]);
        
        for(idea idea:idealistnew.values())
        {
            Countermap.put(idea.id,idea.counter__c);
        }
        
        for(ideacomment ic:CommentList)
        {   idea idearec=idealistnew.get(ic.ideaid);
                if(idearec!=null && idearec.Di_Idea_Product_Manager_Name__c==usermap.get(ic.ideaid) && Countermap.containskey(ic.ideaid)){  
                            idearec.counter__c=Countermap.get(ic.ideaid)+1;
                            idealist.add(idearec);
                }
        }
            if(idealist.size()>0){
                try{
                  Database.update(idealist);
                }
                catch(Exception e){
                    System.debug('@@@Exception'+e);
                }
            }
         }

    public static void IdeaCommentDelete(List<IdeaComment> CommentList){
        list<idea> IdeaList=new list <idea>();
        Map<Id,id> commentMap=new Map<Id,String>();
        Map<Id,string> usermap=new Map<Id,String>();
        Map<Id,decimal> Countermap=new Map<Id,decimal>();
        for(ideacomment ic:CommentList)
            {
                commentMap.put(ic.createdbyid,ic.ideaid);
            }
        if(!commentMap.isEmpty()){      
            for(user user:[select id,Name from user where id in : commentMap.keyset() limit :Limits.getLimitDmlRows()])
            {
                
                usermap.put(commentMap.get(user.id),user.name);
            }
        }

        map<id,idea> idealistnew=new map<id,idea> ([select id,Di_Idea_Product_Manager_Name__c,Counter__c from idea where (id in :usermap.keyset() AND counter__c!=null) limit :Limits.getLimitDmlRows()]);
        for(idea idea:idealistnew.values())
        {
            Countermap.put(idea.id,idea.counter__c);
        }
        for(ideacomment ic:CommentList)
        {   idea idearec=idealistnew.get(ic.ideaid);
                if(idearec!=null && idearec.Di_Idea_Product_Manager_Name__c==usermap.get(ic.ideaid) && Countermap.containskey(ic.ideaid) ){
                        idearec.counter__c=Countermap.get(ic.ideaid)-1;
                        idealist.add(idearec);
                }
        }

        if(idealist.size()>0){
                    try{
                      Database.update(idealist);
                    }
                    catch(Exception e){
                        System.debug('@@@Exception'+e);
                    }
        }
    }
}