/**
 * Utility class for common operations
 *
 * Any classes that use Schema.SObjectField, this property is object by calling "Schema.Account.Description"
 * This allows type safety to ensure that code will not break if fields are changed
 * this will not work with person accounts
 *
 */
public class ApexUtils {
    private static final String ID_STR = 'Id'; 

    /**
     * Given a list and a string property (of an ID field), return a set of the extracted ids
     * (Example: Given a list of contacts where prop='AccountId', return a set of the account Id's)
     * @param  items [description]
     * @param  prop  [description]
     * @return       [description]
     */
    public static Set<Id> pluckIdSet(List<SObject> items, Schema.SObjectField prop) {
        Set<Id> ids = new Set<Id>();
        for(SObject obj : items) {
            try {
                if(obj.get(prop) != null) {
                    ids.add((Id)obj.get(prop));
                }
            } catch (Exception ex) {
                System.debug('Error processing record, ignoring ' + ex.getStackTraceString());
            }
        }
        return ids;
    }

    /**
     * Given a list and a string property (of an ID field), return a set of the extracted ids
     * (Example: Given a list of contacts where prop='AccountId', return a set of the account Id's)
     * This method allows relationships - Ex. 'Account.CreatedBy.Id'
     * @param  items [description]
     * @param  prop  [description]
     * @return       [description]
     */
    public static Set<Id> pluckIdSet(List<SObject> items, String prop) {
        Set<Id> ids = new Set<Id>();
        for(SObject obj : items) {
            try {
                if(prop.contains('.')) {
                    SObject currObj = obj;
                    List<String> fields = prop.split('\\.');
                    for(String field : fields) {
                        try {
                            currObj = (SObject)currObj.getSobject(field);
                        } catch (Exception ex) {
                            ids.add((Id)currObj.get(field));
                        }
                    }
                } else if (obj.get(prop) != null) {
                    ids.add((Id)obj.get(prop));
                }
            } catch (Exception ex) {
                System.debug('Error processing record, ignoring ' + ex.getStackTraceString());
            }
        }
        return ids;
    }

    /**
     * Given a list and a string property (of a String field), return a set of the extracted values
     * (Example: Given a list of contacts where prop='FirstName', return a set of the contacts first name)
     * @param  items [description]
     * @param  prop  [description]
     * @return       [description]
     */
    public static Set<String> pluckStringSet(List<SObject> items, Schema.SObjectField prop) {
        Set<String> strings = new Set<String>();
        for(SObject obj : items) {
            try {
                if(obj.get(prop) != null) {
                    strings.add((String)obj.get(prop));
                }
            } catch (Exception ex) {
                System.debug('Error processing record, ignoring ' + ex.getStackTraceString());
            }
        }
        return strings;
    }

    /**
     * Given a list and a string property (of a String field), return a set of the extracted values
     * The string version provides the ability to get relationship fields - e.x. 'Account.CreatedBy.Name'
     * @param  items [description]
     * @param  prop  [description]
     * @return       [description]
     */
    public static Set<String> pluckStringSet(List<SObject> items, String prop) {
        Set<String> strings = new Set<String>();
        for(SObject obj : items) {
            try {
                if(prop.contains('.')) {
                    SObject currObj = obj;
                    List<String> fields = prop.split('\\.');
                    for(String field : fields) {
                        try {
                            currObj = (SObject)currObj.getSobject(field);
                        } catch (Exception ex) {
                            strings.add((String)currObj.get(field));
                        }
                    }
                } else if (obj.get(prop) != null) {
                    strings.add((String)obj.get(prop));
                }
            } catch (Exception ex) {
                System.debug('Error processing record, ignoring ' + ex.getStackTraceString());
            }
        }
        return strings;
    }

    /**
     * Build a map from two proprties on a list of objects
     * Example: Given a list of Opportunites, passing in prop1='Id', prop2='AccountId', get a map back with the opp id to the account id
     * If two records have the same value for key, then record later in the list will overwrite prior value
     * @param  items list of SObject
     * @param  key Property to get a map by
     * @param  value [description]
     * @return       [description]
     */
    public static Map<String, String> pluckMap(List<SObject> items, Schema.SObjectField key, Schema.SObjectField value) {
        Map<String, String> outputMap = new Map<String, String>();
        for(SObject obj : items) {
            try {
                if(obj.get(key) != null && obj.get(value) != null) {
                    outputMap.put((String)obj.get(key), (String)obj.get(value));
                }
            } catch (Exception ex) {
                System.debug('Error processing record, ignoring ' + ex.getStackTraceString());
            }
        }
        return outputMap;
    }

    /**
     * Same logic as pluckMap, but value is of type Object and will need to be casted to proper type
     * @param  items list of SObject
     * @param  key Property to get a map by
     * @param  value [description]
     * @return       [description]
     */
    public static Map<String, Object> pluckMapAny(List<SObject> items, Schema.SObjectField key, Schema.SObjectField value) {
        Map<String, Object> propToPropMap = new Map<String, Object>();
        for(SObject obj : items) {
            try {
                if(obj.get(key) != null && obj.get(value) != null) {
                    propToPropMap.put((String)obj.get(key), obj.get(value));
                }
            } catch (Exception ex) {
                System.debug('Error processing record, ignoring ' + ex.getMessage() + ex.getStackTraceString());
            }
        }
        return propToPropMap;
    }

    /**
     * Group a list of SObjects by any field on the SObject.
     * @param  items list of SObject
     * @param  field Property to get a map by
     * @return       [description]
     */
    public static Map<String, List<SObject>> groupBy(List<SObject> items, Schema.SObjectField field) {
        Map<String, List<SObject>> propToPropMap = new Map<String, List<SObject>>();
        for(SObject obj : items) {
            try {
                if(obj.get(field) != null) {
                    if(!propToPropMap.containsKey((String)obj.get(field))) {
                        propToPropMap.put((String)obj.get(field), new List<SObject>());
                    }
                    propToPropMap.get((String)obj.get(field)).add(obj);

                } else {
                    System.debug(field + ' is null, ignoring record: ' + obj);
                }
            } catch (Exception ex) {
                System.debug('Error processing record, ignoring ' + ex.getMessage() + ex.getStackTraceString());
            }
        }
        return propToPropMap;
    }

    /**
     * Group a list of SObjects by any field on the SObject.
     * This version of the method supports passing in a string key with relationship fields
     * For example, if you want to group Contacts by Contact.Account.Name
     * @param  items list of SObject
     * @param  field Property to get a map by
     * @return       [description]
     */
    public static Map<String, List<SObject>> groupBy(List<SObject> items, String field) {
      Map<String, List<SObject>> propToPropMap = new Map<String, List<SObject>>();
      for(SObject obj : items) {
          try {
              SObject baseObj = obj;
              SObject tempObj = obj; // if field has a "." this holds the nested objects until fields is reached
              String currField = field;
              // If provided field is using dot notation, get nested object and field
              if(field.contains('.')) {
                  List<String> fields = field.split('\\.');
                  for(String splitField : fields) {
                      try {
                          tempObj = (SObject)tempObj.getSobject(splitField);
                      } catch (Exception ex) {
                          currField = splitField;
                      }
                  }
              }

              if(tempObj.get(currField) != null) {
                  if(!propToPropMap.containsKey((String)tempObj.get(currField))) {
                      propToPropMap.put((String)tempObj.get(currField), new List<SObject>());
                  }
                  propToPropMap.get((String)tempObj.get(currField)).add(baseObj);

              } else {
                  System.debug(currField + ' is null, ignoring record: ' + baseObj);
              }
          } catch (Exception ex) {
              System.debug('Error processing record, ignoring ' + ex.getMessage() + ex.getStackTraceString());
          }
      }
      return propToPropMap;
    }

    /**
     * Sames as groupBy, but only returns one record per key
     * if two records have the same key, the record later in the list will overwrite the previous record
     * @param  items list of records
     * @param  key  field key
     * @return       [description]
     */
    public static Map<String, SObject> groupByFlat(List<SObject> items, Schema.SObjectField key) {
        Map<String, SObject> propToSObjMap = new Map<String, SObject>();
        for(SObject obj : items) {
            try {
                if(obj.get(key) != null) {
                    propToSObjMap.put((String)obj.get(key), obj);
                }
            } catch (Exception ex) {
                System.debug('Error processing record, ignoring ' + ex.getMessage() + ex.getStackTraceString());
            }
        }
        return propToSObjMap;
    }

     /**
     * Get a list of records where the specified value changed
     * @param  items       trigger.new
     * @param  oldItemsMap trigger.oldMap
     * @param  fields      string | string[], name(s) of property to check
     * @return             
     */
    public static List<SObject> findChangedRecs(List<SObject> items, Map<Id, SObject> oldItemsMap, Schema.SObjectField field) {
        return findChangedRecs(items, oldItemsMap, new List<Schema.SObjectField>{field});
    }
    public static List<SObject> findChangedRecs(List<SObject> items, Map<Id, SObject> oldItemsMap, List<Schema.SObjectField> fields) {
        List<SObject> changedObjects = new List<SObject>();
        for(SObject obj : items) {
            for(Schema.SObjectField field : fields) {
                try {
                    Object newObjValue = obj.get(field);
                    Object oldObjValue = oldItemsMap.get((Id)obj.get(ID_STR)).get(field);
                    if(newObjValue != oldObjValue) {
                        changedObjects.add(obj);
                        break; // do not need to continue checking for this record
                    }
                } catch (Exception ex) {
                    System.debug('Error processing record, ignoring ' + ex.getStackTraceString());
                }
            }

        }
        return changedObjects;
    }

    /**
     * Same as findChangedRecs, but check if changed values meet a specific new value
     * @param  items            List of new records
     * @param  oldItemsMap      Map of old records
     * @param  field            The field on the SObject to check
     * @param  expectedNewValue The value that is desired on the new records. IF the value on the new record equals this value, then the old record is checked
     *                          to see if the value is set differently
     * @return                  List of eligible objects, or an empy list
     */
    public static List<SObject> findChangedRecsWithMatchingVal(List<SObject> items, Map<Id, SObject> oldItemsMap, Schema.SObjectField field, Object expectedNewValue) {
        List<SObject> changedObjects = new List<SObject>();
        for(SObject obj : items) {
            try {
                Object newObjValue = obj.get(field);
                if(newObjValue == expectedNewValue) {
                    Object oldObjValue = oldItemsMap.get((Id)obj.get(ID_STR)).get(field);
                    if(newObjValue != oldObjValue) {
                        changedObjects.add(obj);
                    }
                }
            } catch (Exception ex) {
                System.debug('Error processing record, ignoring ' + ex.getStackTraceString());
            }
        }
        return changedObjects;
    }

    /**
     * Given a newList and oldMap, return the records that have a matching old value and new value.
     * This use-case is used when we only want to match records that had a specific value to begin with where the field was changed to another specified value
     * Example: Status changed from "Draft" to "Cancelled"
     * @param  items            List of new records
     * @param  oldItemsMap      Map of old records
     * @param  field            The field on the SObject to check
     * @param  oldValue         Old value of the record that the value should had to be considered to be returned
     * @param  expectedNewValue Value that the record should have to be returned
     * @return                  List of eligible objects, or an empy list
     */
    public static List<SObject> findChangedRecsWithMatchingVal(List<SObject> items, Map<Id, SObject> oldItemsMap, Schema.SObjectField field, Object oldValue, Object expectedNewValue) {
        List<SObject> changedObjects = new List<SObject>();
        for(SObject obj : items) {
            try {
                Object newObjValue = obj.get(field);
                Object oldObjValue = oldItemsMap.get((Id)obj.get(ID_STR)).get(field);
                if(oldObjValue == oldValue && newObjValue == expectedNewValue) {
                    changedObjects.add(obj);
                }
            } catch (Exception ex) {
                System.debug('Error processing record, ignoring ' + ex.getStackTraceString());
            }
        }
        return changedObjects;
    }

    /**
     * Same as findChangedRecs, but check if changed values meet a specific new value
     * @param  items            List of new records
     * @param  field            The field to check
     * @param  expectedValue    Return the record if the field's value equals this value
     * @return                  List of records where the field == expectedValue
     */
    public static List<SObject> findRecsWithMatchingValue(List<SObject> items, Schema.SObjectField field, Object expectedValue) {
        List<SObject> matchedObjects = new List<SObject>();
        for(SObject obj : items) {
            try {
                if(obj.get(field) == expectedValue) {
                    matchedObjects.add(obj);
                }
            } catch (Exception ex) {
                System.debug('Error processing record, ignoring ' + ex.getStackTraceString());
            }
        }
        return matchedObjects;
    }

    /**
     * Same as findChangedRecs, but check if changed values meet a specific new value
     * @param  items            List of new records
     * @param  field            The field to check
     * @param  expectedValue    Return the record if the field's value does not equals this value
     * @return                  List of records where the field != expectedValue
     */
    public static List<SObject> findRecsWithNonMatchingValue(List<SObject> items, Schema.SObjectField field, Object expectedValue) {
        List<SObject> matchedObjects = new List<SObject>();
        for(SObject obj : items) {
            try {
                if(obj.get(field) != expectedValue) {
                    matchedObjects.add(obj);
                }
            } catch (Exception ex) {
                System.debug('Error processing record, ignoring ' + ex.getStackTraceString());
            }
        }
        return matchedObjects;
    }
}