//Reason to create this object to avoid Stack depth 1001 error
public with sharing class SequenceObject implements Comparable{
    public SequenceObject() {

    }

    public String objectName;
    public Integer referenceSize;
    public Set<String> referenceSet;

    public SequenceObject(String objectName,Integer referenceSize,Set<String> referenceSet){
        this.objectName = objectName;
        this.referenceSize = referenceSize;
        this.referenceSet = referenceSet;
    }

    public Integer compareTo(Object compareTo) {
        SequenceObject compareToOppy = (SequenceObject)compareTo;
        if(referenceSize == compareToOppy.referenceSize) return 0;
        else if(referenceSize > compareToOppy.referenceSize) return 1;
        else return -1;
    }
}