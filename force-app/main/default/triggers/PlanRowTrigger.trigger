trigger PlanRowTrigger on ALTF__Account_Plan_Row__c (after insert) {

    // This trigger should handle batces including rows from different plans.
    // However it does not support differnet plans with different date ranges. 
    // It includes this restriction so that if avoids have to call the Synchroniser 
    // a non determinitic number of times. If it detects variation in data ranges 
    // it will fail


    if (Trigger.isAfter && Trigger.isInsert) {
        Set<Id> accountIds = new Set<Id>();

        for (ALTF__Account_Plan_Row__c row : Trigger.new) {
            accountIds.add(row.altf__effective_account_id__c);
        }

        DateRange range = getPlanDateRange();

        new SynchronisePlannedOpportunities().createAccountOpportunities(accountIds, range.startDate, range.endDate, null);
    }
    

    //
    // Utility functions support the main code above
    // 

    public  DateRange getPlanDateRange() {
        
        Set<Id> planIds = new Set<Id>();

        for (ALTF__Account_Plan_Row__c row : Trigger.new) {
            planIds.add(row.altf__account_plan__c);
        }

        List<ALTF__Account_Plan__c> plans = [
            select id, altf__min_plan_start_date__c, altf__max_plan_end_date__c
            from altf__account_plan__c
            where id in :planids
        ];


        return validatePlanDateRanges(plans);
    }


    private DateRange validatePlanDateRanges(List<ALTF__Account_Plan__c> plans) {
        
        DateRange range = new DateRange();

        for (ALTF__Account_Plan__c plan : plans) {
            
            if (plan.altf__min_plan_start_date__c != null) {
                if (range.startDate != null && range.startDate != plan.altf__min_plan_start_date__c) {
                    throw new DateRangeMismatchException('All plans must share the same date range');                   
                }

                range.startDate = plan.altf__min_plan_start_date__c;
            }

            if (plan.altf__max_plan_end_date__c != null) {
                if (range.endDate != null && range.endDate != plan.altf__max_plan_end_date__c) {
                    throw new DateRangeMismatchException('All plans must share the same date range');                   
                }

                range.endDate = plan.altf__max_plan_end_date__c;
            }
        }

        return range;
    }


    public class DateRangeMismatchException extends Exception {}

    public class DateRange {
        Date startDate {get;set;}
        Date endDate {get;set;}
    }
}