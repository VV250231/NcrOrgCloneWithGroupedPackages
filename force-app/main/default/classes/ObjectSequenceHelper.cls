public with sharing class ObjectSequenceHelper implements Queueable{
    private Map<String,Set<String>> parentChildMap;
    private Map<String,Set<String>> childParentMap;
    private Map<String,Integer> hierarchyLevelMap = new Map<String,Integer>();
    List<String> sObjectList = new List<String>();
    private Integer loopCount = 0;
    private Integer batchSize = 200;
    private List<SequenceObject> sequenceObjectList = new List<SequenceObject>();
    private SequenceObject sequenceObjectRecord;
    public Integer loopCountStore = 0;
    public Integer loopStateCount = 0;
    private Set<String> loopedObjects = new Set<String>();
    private Set<String> relatedUnloopedObjects = new Set<String>();
    private Map<String,Integer> objectLoopCount = new Map<String,Integer>();
    private Integer counter = 0;

    public ObjectSequenceHelper(Map<String,Set<String>> parentChildMap,Map<String,Set<String>> childParentMap) {
        this.parentChildMap = parentChildMap;
        this.childParentMap = childParentMap;
        this.sObjectList = new List<String>(this.parentChildMap.keySet());
        for(String sObjectName : this.parentChildMap.keySet()){
            //if(this.childParentMap.containsKey(sObjectName)){
            //parentChildMap.get(sObjectName).removeAll(this.childParentMap.get(sObjectName));
            sequenceObjectRecord = new SequenceObject();
            sequenceObjectRecord.objectName = sObjectName;
            sequenceObjectRecord.referenceSize = parentChildMap.get(sObjectName).size();
            sequenceObjectRecord.referenceSet = parentChildMap.get(sObjectName);
            sequenceObjectList.add(sequenceObjectRecord);
            //}
        }
        System.debug('The Map Value is : '+JSON.serialize(this.parentChildMap));
        sequenceObjectList.sort();
        System.debug('The Map Value is : '+JSON.serialize(this.sequenceObjectList));
    }

    public ObjectSequenceHelper(Map<String,Set<String>> parentChildMap,Map<String,Integer> hierarchyLevelMap,List<String> sObjectList,List<SequenceObject> sequenceObjectList,Integer loopCount){
        this.parentChildMap = parentChildMap;
        this.hierarchyLevelMap = hierarchyLevelMap;
        this.sObjectList = sObjectList;
        this.sequenceObjectList = sequenceObjectList;
        this.loopCount = loopCount;
    }

    public void execute(QueueableContext context) {
        Integer startIndex = this.loopCount*batchSize;
        Integer calculateEndIndex = batchSize*(1+this.loopCount);
        Integer totalSObjectSize = this.sequenceObjectList.size();
        Integer endIndex = calculateEndIndex>totalSObjectSize ? totalSObjectSize : calculateEndIndex;
        this.getHierarchyLevel(startIndex,endIndex);
        this.loopCount++;
        if(endIndex<totalSObjectSize){
            System.enqueueJob(new ObjectSequenceHelper(
                this.parentChildMap,
                this.hierarchyLevelMap,
                this.sObjectList,
                this.sequenceObjectList,
                this.loopCount
            ));
        }
        else{
            generateCSV(this.hierarchyLevelMap);
            //System.debug('The Final Map Value is : '+JSON.serialize(this.hierarchyLevelMap));
        }
    }
        
    public void getHierarchyLevel(Integer startIndex,Integer endIndex){
        for(Integer index = startIndex;index< endIndex;index++){
            System.Debug('The Index is : '+index);
            System.Debug('The value is : '+this.sequenceObjectList[index].objectName);
            this.loopCountStore = index;
            if(this.hierarchyLevelMap.containsKey(this.sequenceObjectList[index].objectName)){continue;}
            getLevelNumber(this.sequenceObjectList[index].objectName);
            this.objectLoopCount.clear();
            if(!this.loopedObjects.isEmpty()){
                this.loopedObjects.clear();
                this.relatedUnloopedObjects.clear();
            }
        }
    }

    public Integer getLevelNumber(String objectName){
        //this.counter++;
        if(!this.objectLoopCount.containsKey(objectName)){this.objectLoopCount.put(objectName,1);}
        else{this.objectLoopCount.put(objectName,this.objectLoopCount.get(objectName)+1);}
        System.Debug('The value 1 is : '+this.sequenceObjectList[loopCountStore].objectName);
        System.Debug('The value 2 is : '+objectName);
        System.debug('The Loop Count is : '+loopStateCount);
        System.debug('The Loop Count Map is : '+this.objectLoopCount.get(objectName));
        System.debug('The Counter : '+this.counter);
        if(this.hierarchyLevelMap.containsKey(objectName)){
            return this.hierarchyLevelMap.get(objectName);
        }
        if(this.objectLoopCount.containsKey(objectName) && this.objectLoopCount.get(objectName)>=2){
            System.debug('The Loop is Detected');
            System.debug('The Loop Count Map is : '+this.objectLoopCount.get(objectName));
            this.objectLoopCount.put(objectName,this.objectLoopCount.get(objectName)+1);
            this.resolveLooping(this.sequenceObjectList[this.loopCountStore].objectName);
            this.setValuesToLoopedObjects();
            // this.objectLoopCount.put(objectName,0);
        }  
         
        if(!this.parentChildMap.containsKey(objectName)){
            this.hierarchyLevelMap.put(objectName,1);
            return 1;
        }
        else if(this.parentChildMap.containsKey(objectName) && this.parentChildMap.get(objectName).isEmpty()){
            this.hierarchyLevelMap.put(objectName,1);
            return 1;
        }
        else{
            Integer level = 0;
            Integer calculatedLevel = 0;
            for(String childSObjectName : this.parentChildMap.get(objectName)){
                calculatedLevel = this.hierarchyLevelMap.containsKey(childSObjectName) ?  this.hierarchyLevelMap.get(childSObjectName) : getLevelNumber(childSObjectName);
                level = level>calculatedLevel ? level : calculatedLevel;
            }
            if(!loopedObjects.contains(objectName)){this.hierarchyLevelMap.put(objectName,++level);}
        }
        return this.hierarchyLevelMap.get(objectName);
    }
    
    public void resolveLooping(String objectName){
        if(!this.parentChildMap.containsKey(objectName)){
            this.hierarchyLevelMap.put(objectName,1);
            this.relatedUnloopedObjects.add(objectName);
            return;
        }
        else if(this.parentChildMap.containsKey(objectName) && this.parentChildMap.get(objectName).isEmpty()){
            this.hierarchyLevelMap.put(objectName,1);
            this.relatedUnloopedObjects.add(objectName);
            return;
        }
        for(String childObject : this.parentChildMap.get(objectName)){
            if(this.loopedObjects.contains(childObject)){
                continue;
            }else if(this.hierarchyLevelMap.containsKey(childObject)){
                this.relatedUnloopedObjects.add(childObject);
            }
            else{
                loopedObjects.add(childObject);
                resolveLooping(childObject);
            }
        }
    }
    
    public void setValuesToLoopedObjects(){
        Integer maxValue = 0;
        Integer currentValue = 0;
        System.debug('The Loop Objects is : '+JSON.serialize(this.relatedUnloopedObjects));
        System.debug('The UNLoop Objects is : '+JSON.serialize(this.loopedObjects));
        this.loopedObjects.removeAll(this.relatedUnloopedObjects);
        System.debug('The UNLoop Objects is : '+JSON.serialize(this.loopedObjects));
        for(String childObject : this.relatedUnloopedObjects){
            System.debug('The hierarchyLevelMap Value is : '+this.hierarchyLevelMap.get(childObject));
            currentValue = this.hierarchyLevelMap.get(childObject);
            if(currentValue>maxValue){maxValue = currentValue;}
        }
        System.debug('The Max Value is : '+maxValue);
        for(String loopObject : this.loopedObjects){
            this.hierarchyLevelMap.put(loopObject,maxValue+1);
        }
        for(String loopObject : this.loopedObjects){
            System.debug('The loopObject Value is : '+this.hierarchyLevelMap.get(loopObject));
        }
    }

    @future
    public static void generateCSV(Map<String,Integer> hierarchyLevelMap){
        //System.debug('The Final Map 123 Value is : '+JSON.serialize(hierarchyLevelMap));
        Map<String,List<String>> levelHierarchyMap = new Map<String,List<String>>();
        Map<String,Integer> levelSizeMap = new Map<String,Integer>();
        String level = '';
        Integer maxSize = 0;
        Integer currentSize = 0;
        for(String sObjectName : hierarchyLevelMap.keySet()){
            level = 'Level '+ hierarchyLevelMap.get(sObjectName);
            if(!levelHierarchyMap.containsKey(level)){
                levelHierarchyMap.put(level,new List<String>());
            }
            levelHierarchyMap.get(level).add(sObjectName);
        }
        //System.debug('The Level Map Value is : '+JSON.serialize(levelHierarchyMap));
        for(String levelNumber : levelHierarchyMap.keySet()){
            currentSize = levelHierarchyMap.get(levelNumber).size();
            maxSize = currentSize>maxSize ? currentSize : maxSize;
            levelSizeMap.put(levelNumber,currentSize);
        }
        List<String> csvRows = new List<String>();
        for(Integer index = 0;index<maxSize;index++){
            String rows = '';
            for(Integer value = 1;value<=levelHierarchyMap.size();value++){
                if(index<levelHierarchyMap.get('Level '+value).size()){
                    rows+= levelHierarchyMap.get('Level '+value)[index]+',';
                }else{
                    rows+=' ,';
                }
            }
            csvRows.add(rows);
        }
        String csvHeader = String.join(new List<String>(levelHierarchyMap.keySet()),',') + '\n';
        String csvFile = csvHeader + String.join(csvRows,'\n');

        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S'; //denotes it resides on Salesforce
        cv.Title = 'SequenceTable.csv'; //title of the file
        cv.PathOnClient = 'SequenceTable.csv'; // full path within Salesforce this can just be the name of file to be in the library
        cv.VersionData = Blob.valueOf(csvFile); //file data
        insert cv;
    }
}