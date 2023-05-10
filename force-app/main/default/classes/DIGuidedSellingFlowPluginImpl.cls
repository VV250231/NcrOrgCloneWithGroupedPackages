global class DIGuidedSellingFlowPluginImpl implements zqu.SelectProductComponentOptions.IGuidedSellingFlowPlugin
{    
   public List<ID> getFlows(Id quoteId)
   {
      List < Id > flowIds = new List < Id >();

      if(String.isBlank(quoteId)) return flowIds;

      // Retrieve the quote based on Id
      List < zqu__Quote__c > quoteList = [SELECT Name, zqu__SubscriptionType__c,/* zqu__Opportunity__r.Solution_Portfolio__c,*/ zqu__Opportunity__r.Opportunity_Classification__c,zqu__Opportunity__r.Account.Subscription_Group__c FROM zqu__Quote__c WHERE Id = :quoteId];
      if(quoteList.isEmpty()) return flowIds;
      
      // Determine the string to query flows based on the subscription type of the quote
      //String flowName = quoteList[0].zqu__SubscriptionType__c == 'New Subscription' ? 'New %' : '%Amend%"';

      // Query for flows based on the name and IncludeInProductSelector flag
      List < zqu__GuidedSellingFlow__c > flows = 
         DIQuoteUtil.isDigitalInsight(quoteList[0].zqu__Opportunity__r) ?
         [SELECT Id FROM zqu__GuidedSellingFlow__c WHERE zqu__IncludeInProductSelector__c = true and (not Name like 'Renew%') and Name = 'Add DI Product' order by Name asc]
         : 
         [SELECT Id FROM zqu__GuidedSellingFlow__c WHERE zqu__IncludeInProductSelector__c = true and (not Name like 'Renew%') and Name != 'Add DI Product' order by Name asc];
      if(flows.isEmpty()) return flowIds; 

      // If flows were found, add their ids to the result list
      for(zqu__GuidedSellingFlow__c flow : flows) {
         flowIds.add(flow.Id);
      }
      return flowIds;
    }
 }