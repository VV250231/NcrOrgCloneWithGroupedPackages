public with sharing class ObjectSequenceHandler implements Queueable{
    //Constants 
    private final String DATATYPE_REFERENCE = 'Reference';
    private final List<String> IGNORE_SOBJECT_LIST = new List<String>{
        /*'User',
        'Group',
        'Organization',
        'Profile',
        'RecordType',
        'ContentVersion',
        'ContentDocumentLink',
        'NetworkActivityAudit',
        'FeedItem',
        'EventRelation',
        'TaskRelation',
        'TopicAssignment',
        'NetworkUserHistoryRecent',
        'ContentDistribution',
        'CollaborationGroupRecord',
        'ContactRequest',
        'DuplicateRecordItem',
        'ProcessException',
        'Attachment',
        'Note',
        'Event',
        'Task',
        'EmailMessage',
        'FeedAttachment',
        'RecordAction',
        'EntitySubscription',
        'FeedComment',
        'OutgoingEmail',
        'VideoCallParticipant',
        'FinanceTransaction'*/
    };
        
        /*,,
        'OutgoingEmail',
        'VideoCallParticipant',
        'FinanceTransaction'
        'manp__Booking__c',
        'manp__Concert_Detail__c',
        'manp__Concert__c'*/
    //Variables
    private List<String> inputSObjects = new List<String>();
    private Map<String,Set<String>> parentChildMap;
    private Map<String,Set<String>> childParentMap;
    private Integer loopCount = 0;
    private Integer batchSize = 500; //Default

    //Constructor
    public ObjectSequenceHandler(List<String> inputSObjects,Integer size){
        this.inputSObjects = inputSObjects;    
        this.parentChildMap = new Map<String,Set<String>>();    
        this.childParentMap = new Map<String,Set<String>>();
        this.batchSize = size;
    }
    public ObjectSequenceHandler(List<String> inputSObjects,Map<String,Set<String>> parentChildMap,Map<String,Set<String>> childParentMap,Integer counter,Integer size){
        this.inputSObjects = inputSObjects;    
        this.parentChildMap = parentChildMap;    
        this.childParentMap = childParentMap;
        this.loopCount = counter;
        this.batchSize = size;
    }

    public void execute(QueueableContext context) {
        Integer startIndex = this.loopCount*batchSize;
        Integer calculateEndIndex = batchSize*(1+loopCount);
        Integer totalSObjectSize = inputSObjects.size();
        Integer endIndex = calculateEndIndex>totalSObjectSize ? totalSObjectSize : calculateEndIndex;
        getHierarchy(startIndex,endIndex);
        this.loopCount++;
        if(endIndex<totalSObjectSize){
            System.enqueueJob(new ObjectSequenceHandler(
                this.inputSObjects,
                this.parentChildMap,
                this.childParentMap,
                this.loopCount,
                this.batchSize
            ));
        }else{
         /*   Set<String> unStoredObjects = new Set<String>();
            for(String sObjectRecord : this.inputSObjects){
                if(!this.parentChildMap.containsKey(sObjectRecord)){
                    unStoredObjects.add(sObjectRecord);
                }
            }
            System.debug('unStoredObjects : '+JSON.serialize(unStoredObjects));
          */
             System.enqueueJob(new ObjectSequenceHelper(
                 this.parentChildMap,
                 this.childParentMap
             ));
            //new ObjectSequenceHelper(this.parentChildMap,this.childParentMap).setHierarchyMap();
            // System.debug('The Parent is '+JSON.serialize(this.parentChildMap));
            // System.debug('The Child is '+JSON.serialize(this.childParentMap));
        }
    }
    
    public void getHierarchy(Integer startIndex,Integer endIndex){
        SObjectType sObjectData;
        DescribeSObjectResult sObjectDescribe;
        Map<String,SObjectField> sObjectFieldMap;
        DescribeFieldResult selectedField;
        String referenceObjectAPIName = '';
        
        for(Integer index = startIndex;index<endIndex;index++){
            sObjectData = Schema.getGlobalDescribe().get(this.inputSObjects[index]);
            if(sObjectData==null){continue;}
            sObjectFieldMap = sObjectData.getDescribe().fields.getMap();
            for(String field:sObjectFieldMap.keySet()){
                selectedField = sObjectFieldMap.get(field).getDescribe();
                //if(this.DATATYPE_REFERENCE.equalsIgnoreCase(String.ValueOf(selectedField.getType()))){
                if(this.DATATYPE_REFERENCE.equalsIgnoreCase(String.ValueOf(selectedField.getType())) && selectedField.isCreateable()){
                    for(Schema.SObjectType reference : selectedField.getReferenceTo()){
                        referenceObjectAPIName = String.valueOf(reference.getDescribe().getName());
                        System.debug('referenceObjectAPIName : '+referenceObjectAPIName);
                        System.debug('inputSobject : '+this.inputSObjects[index]);
                        if(!inputSObjects.contains(referenceObjectAPIName) || referenceObjectAPIName==inputSObjects[index] || IGNORE_SOBJECT_LIST.contains(referenceObjectAPIName)){continue;}
                        if(!parentChildMap.containsKey(this.inputSObjects[index])){
                            parentChildMap.put(this.inputSObjects[index],new Set<String>());
                        }else if(!parentChildMap.containsKey(referenceObjectAPIName)){
                            parentChildMap.put(referenceObjectAPIName,new Set<String>());
                        }
                        if(!childParentMap.containsKey(referenceObjectAPIName)){
                            childParentMap.put(referenceObjectAPIName,new Set<String>());
                        }else if(!childParentMap.containsKey(this.inputSObjects[index])){
                            childParentMap.put(this.inputSObjects[index],new Set<String>());
                        }
                        //M
                        childParentMap.get(referenceObjectAPIName).add(this.inputSObjects[index]);
                        //if(parentChildMap.containsKey(referenceObjectAPIName) && parentChildMap.get(referenceObjectAPIName).contains(this.inputSObjects[index])){continue;}
                        parentChildMap.get(this.inputSObjects[index]).add(referenceObjectAPIName);
                    }
                }
            }
        }
        System.debug('The Maps Value is : '+childParentMap);
        System.debug('The Maps Value is : '+parentChildMap);
    }
}