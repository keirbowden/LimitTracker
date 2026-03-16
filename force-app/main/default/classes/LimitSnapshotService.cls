public with sharing class LimitSnapshotService implements LimitSnapshotServiceIF {
    @TestVisible 
    private static LimitSnapshotServiceIF instance;

    @TestVisible
    private LimitSnapshotDAO dao=new LimitSnapshotDAO();

    private LimitSnapshotService() 
    {
    }

    public static LimitSnapshotServiceIF GetService()
    {
        if (null==instance)
        {
            instance=new LimitSnapshotService();
        }

        return instance;
    }

    public List<AssociatedRecord> getAssociatedRecordsForSnapshot(Id limitSnapshotId) {
        Map<Id, String> labelsByRecordId=new Map<Id, String>();

        Limit_Tracker_Snapshot__c snapshot=dao.getLimitSnapshot(limitSnapshotId);
        labelsByRecordId.put(snapshot.User__c, 'Running User');
        Map<String, Object> propsByName = 
                    (Map<String, Object>) JSON.deserializeUntyped(snapshot.Additional_Information__c);

        for (String propName: propsByName.keySet()) {
            System.debug('Handling property ' + propName);
            Map<String, Object> propValue = (Map<String, Object>) propsByName.get(propName);            
            if (propValue.containsKey('recordId')) {
                Id recordId = (Id) propValue.get('recordId');
                labelsByRecordId.put(recordId, propName);
            }
        }

        Map<Id, sObject> recordsById=dao.getRelatedRecords(labelsByRecordId.keySet());

        List<AssociatedRecord> associatedRecords=new List<AssociatedRecord>();
        
        for (Id recordId : labelsByRecordId.keySet()) {
            String label=labelsByRecordId.get(recordId);
            sObject record=recordsById.get(recordId);
            String message;
            if (null==record) {
                message='Record not found - has it been deleted?';
            }
            else if ((DateTime) (record.get('LastModifiedDate'))>snapshot.LastModifiedDate) {
                message='Record has been updated since snapshot was taken';
            }
            System.debug('Label = ' + label);
            System.debug('Last modified = ' + (DateTime) (record.get('LastModifiedDate')));
            System.debug('Snapshot date = ' + snapshot.LastModifiedDate);
            associatedRecords.add(new AssociatedRecord(label, recordsById.get(recordId),
                                                        message));
        }

        return associatedRecords;
    }
}