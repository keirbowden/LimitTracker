trigger LimitSnapshot_ai on Limit_Snapshot__e (after insert) 
{
    LimitTrackerService trackerService=LimitTrackerService.GetService();
    trackerService.processSnapshotEvents(Trigger.new);
}