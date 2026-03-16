public with sharing class LimitSnapshotDAO {
    public LimitSnapshotDAO() {
    }

    public Map<Id, sObject> getRelatedRecords(Set<Id> relatedRecordIds) {
        Map<String, Set<Id>> relatedRecordIdsByObjectName=new Map<String, Set<Id>>();
        for (Id relatedId : relatedRecordIds) {
            Schema.SObjectType sobType = relatedId.getSObjectType();
            if (sobType != null) {
                String objectName = sobType.getDescribe().getName();
                Set<Id> ids = relatedRecordIdsByObjectName.get(objectName);
                if (ids == null) {
                    ids = new Set<Id>();
                    relatedRecordIdsByObjectName.put(objectName, ids);
                }
                ids.add(relatedId);
            }
        }

        Map<Id, sObject> sobjectsById=new Map<Id, sObject>();
        for (String objectName : relatedRecordIdsByObjectName.keySet()) {
            Set<Id> relatedRecordIdsForObjectName = relatedRecordIdsByObjectName.get(objectName);
            String query = 'SELECT Id, Name, LastModifiedDate FROM ' + objectName + ' WHERE Id IN :relatedRecordIdsForObjectName';
            List<sObject> sobjectsFromDB=Database.query(query);
            for (sObject sobjectFromDB : sobjectsFromDB) {
                sobjectsById.put(sobjectFromDB.Id, sobjectFromDB);
            }
        }

        return sobjectsById;
    }

    public Limit_Tracker_Snapshot__c getLimitSnapshot(Id recordId) {
        return [select Id, User__c, Additional_Information__c, LastModifiedDate from Limit_Tracker_Snapshot__c where Id=:recordId];
    }
}