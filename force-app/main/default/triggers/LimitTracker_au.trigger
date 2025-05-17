trigger LimitTracker_au on Limit_Tracker__c (after update)
{
    LimitTrackerService trackerService=LimitTrackerService.GetService();
    trackerService.processUpdates(Trigger.old, Trigger.new);
}