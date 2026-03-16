public interface LimitTrackerServiceIF {
    void enableTracking(Boolean enabled);
    void startTracking(String name);
    void startTracking(String name, String additionalInfo);
    LimitSnapshot stopTracking(String name);
    Database.SaveResult stopTrackingAndPublishSnapshot(String name);    
    void stopTrackingAndQueueSnapshot(String name);
    List<Database.SaveResult> publishQueuedSnapshots();
    void processSnapshotEvents(List<Limit_Snapshot__e> snapshots);
    void processUpdates(List<Limit_Tracker__c> oldTrackers, 
                             List<Limit_Tracker__c> newTrackers);
    void processTrackerSnapshots(List<Limit_Tracker_Snapshot__c> snapshots);
}