global class ChangeIdeaStatusScheduled implements Schedulable {
   global void execute(SchedulableContext ctx) {
     List <Idea> ideas = new List <idea> ([SELECT Id FROM Idea WHERE Status = 'Under Point Threshold' and voteTotal >= 100 limit 100]);
     if (ideas.size() > 0) {
         for (Idea ideaRec: ideas) {
             ideaRec.status = 'Product Team Review';
         }
         update ideas;
     }
   }   
}