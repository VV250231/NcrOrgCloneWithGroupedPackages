// ===========================================================================
// Object: INCRDefaultValuePlugin
// Company: Cloudware Connections, Inc.
// Author: Reid Beckett
// Purpose: Interface for division-specific implemenations to set default values on the Quote
// ===========================================================================
// Changes: 2016-03-18 Reid Beckett
//           Class created
// ===========================================================================
global interface INCRDefaultValuePlugin 
{
    void populateDefaultFieldValue(Opportunity opp, zqu__Quote__c record, zqu.PropertyComponentController.ParentController parentController);
}