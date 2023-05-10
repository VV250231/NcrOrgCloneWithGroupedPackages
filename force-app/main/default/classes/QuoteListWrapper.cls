// Created By: Dharmendra K Pandey
// wrapper class with @AuraEnabled and {get;set;} properties 
public class QuoteListWrapper{
    @AuraEnabled
    public List<SBQQ__Quote__c> quotetList{get;set;}
    @AuraEnabled
    public String quoteURL{get;set;}
}