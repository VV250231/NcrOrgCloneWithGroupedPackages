/*
#####################################################################################################################
# Project Name..........: NSC Sales Central                                                                         #
# File..................: DMLOptions.cls                                                                            #
# Version...............: 1                                                                                         #
# Created by............: Ajay Dixit                                                                           #
# Created Date..........: 09-05-2011                                                                                #
# Last Modified by......: Nagendra Singh                                                                            #
# Last Modified Date....: 28-07-2016                                                                               #
# Description...........: To fire lead assignement logic                                                                                        #

Modification History:
Date           Dev. Name           User Story  
27-7-2016      Nagendra Singh      Removed @future  from class to improove permormance in lightning                                                                       #
#####################################################################################################################
*/

public with sharing class DMLOptions {
    
    @future
    public static void performAssignmentRule(List<String> lst){
        system.debug('lst>>>>>>>>>' + lst);
        List<lead> leads= [select id from Lead where id IN :lst];
        if(leads!=null && leads.size()>0){
            Database.DMLOptions dmo = new Database.DMLOptions();
            //Changes done by Yogesh - related to Story EBA_SF-1919
            Id assnMntId= NSCCommonInfoUtil.getIdOf('DMLAssnMntId'); 
            // dmo.assignmentRuleHeader.assignmentruleid= '01Q70000000FyUS';
            // End by Yogesh
            dmo.assignmentRuleHeader.assignmentruleid= assnMntId;
            dmo.EmailHeader.triggerAutoResponseEmail = true;
            dmo.EmailHeader.triggerUserEmail = true;
            dmo.EmailHeader.triggerOtherEmail = true;
            for(Lead l : leads){
                
                l.setOptions(dmo);
            }
            database.update(leads);
        }
    }
}