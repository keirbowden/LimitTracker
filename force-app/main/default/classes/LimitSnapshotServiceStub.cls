public with sharing class LimitSnapshotServiceStub implements LimitSnapshotServiceIF {
    public List<AssociatedRecord> associatedRecords;

    public List<AssociatedRecord> getAssociatedRecordsForSnapshot(Id limitSnapshotId){
        return associatedRecords;
    }
}