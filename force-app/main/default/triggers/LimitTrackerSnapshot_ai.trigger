trigger LimitTrackerSnapshot_ai on Limit_Tracker_Snapshot__c (before insert) {
    LimitTrackerServiceIF trackerService=LimitTrackerService.GetService();
    trackerService.processTrackerSnapshots(Trigger.new);

}