trigger LimitSnapshotEvent_ai on Limit_Snapshot__e (after insert) 
{
    LimitTrackerServiceIF trackerService=LimitTrackerService.GetService();
    trackerService.processSnapshotEvents(Trigger.new);
}