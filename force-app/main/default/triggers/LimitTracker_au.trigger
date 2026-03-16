trigger LimitTracker_au on Limit_Tracker__c (after update)
{
    LimitTrackerServiceIF trackerService=LimitTrackerService.GetService();
    trackerService.processUpdates(Trigger.old, Trigger.new);
}