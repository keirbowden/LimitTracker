public with sharing class LimitTrackerService 
{
    @TestVisible private static LimitTrackerService instance;

    private LimitTrackerService() 
    {

    }

    public static LimitTrackerService GetService()
    {
        if (null==instance)
        {
            instance=new LimitTrackerService();
        }

        return instance;
    }

    public void processSnapshotEvents(List<Limit_Snapshot__e> snapshots)
    {
        Map<String, List<Limit_Snapshot__e>> snapshotsByName=
                        new Map<String, List<Limit_Snapshot__e>>();

        for (Limit_Snapshot__e snapshot : snapshots)
        {
            List<Limit_Snapshot__e> snapshotsForName=
                    snapshotsByName.get(snapshot.Name__c);

            if (null==snapshotsForName)
            {
                snapshotsForName=new List<Limit_Snapshot__e>();
                System.debug('Name = ' + snapshot.Name__c);
                snapshotsByName.put(snapshot.Name__c, snapshotsForName);
            }

            snapshotsForName.add(snapshot);
        }

        List<Limit_Tracker__c> limitTrackers=
                    [select Id, Name
                     from Limit_Tracker__c 
                     where Name in :snapshotsByName.keySet()];

        List<Limit_Tracker_Snapshot__c> trackerSnapshotsToAdd=
                    new List<Limit_Tracker_Snapshot__c>();

        for (Limit_Tracker__c tracker : limitTrackers)
        {
            DateTime lastDT=null;

            List<Limit_Snapshot__e> snapshotsForTracker=
                    snapshotsByName.get(tracker.Name);

            for (Limit_Snapshot__e snapshot : snapshotsForTracker)
            {
                Limit_Tracker_Snapshot__c trackerSnapshot=
                                    new Limit_Tracker_Snapshot__c();

                trackerSnapshot.CPU__c=snapshot.CPU__c;
                trackerSnapshot.DML_Records__c=snapshot.DML_Records__c;
                trackerSnapshot.DML_Statements__c=snapshot.DML_Statements__c;
                trackerSnapshot.Heap__c=snapshot.Heap__c;
                trackerSnapshot.SOQL_Queries__c=snapshot.SOQL_Queries__c;
                trackerSnapshot.SOQL_Records__c=snapshot.SOQL_Records__c;
                trackerSnapshot.Additional_Information__c=snapshot.Additional_Information__c;
                trackerSnapshot.Limit_tracker__c=tracker.Id;    
                trackerSnapshotsToAdd.add(trackerSnapshot);

                if ( (null==lastDT) || (snapshot.CreatedDate > lastDT) )
                {
                    lastDT=snapshot.CreatedDate;
                    tracker.CPU_Last__c=snapshot.CPU__c;
                    tracker.Heap_Last__c=snapshot.Heap__c;  
                    tracker.DML_Records_Last__c=snapshot.DML_Records__c;    
                    tracker.DML_Statements_Last__c=snapshot.DML_Statements__c;  
                    tracker.SOQL_Queries_Last__c=snapshot.SOQL_Queries__c;  
                }
            }
        }

        insert trackerSnapshotsToAdd;
        update limitTrackers;
    }

    public void processUpdates(List<Limit_Tracker__c> oldTrackers, 
                                List<Limit_Tracker__c> newTrackers)
    {
        System.debug('Processing tracker updates');
        for (Integer idx=0; idx<oldTrackers.size(); idx++)
        {
            Limit_Tracker__c oldTracker=oldTrackers[idx];
            Limit_Tracker__c newTracker=newTrackers[idx];

            raiseAlerts('Heap', oldTracker.Heap_Last__c.intValue(), 
                        newTracker.Heap_Last__c.intValue(),
                        newTracker.Heap_Alert_Threshold_1__c?.intValue(),
                        newTracker.Heap_Alert_Change__c?.intValue());
            
            raiseAlerts('CPU', oldTracker.CPU_Last__c.intValue(), 
                        newTracker.CPU_Last__c.intValue(),
                        newTracker.CPU_Alert_Threshold_1__c?.intValue(),
                        newTracker.CPU_Alert_Change__c?.intValue());
        }
    }

    private void raiseAlerts(String which, Integer oldVal, Integer newVal,
                             Integer alertThreshold, Integer changePercent)
    {
        System.debug('Old ' + which + ' = ' + oldVal);
        System.debug('New ' + which + ' = ' + newVal);

        if (oldVal<newVal)
        {
            System.debug(which + ' increased');
            if ( (null!=alertThreshold) && (newVal>alertThreshold) )
            {
                System.debug(which + ' alert threshold 1 exceeded');
            }
                
            // don't alert for the first record
            if ( (null!=changePercent) && (0!=oldVal) )
            {
                Integer diff=newVal-oldVal;
                Integer percent=(diff * 100) / oldVal;
                if (percent>=changePercent)
                {
                    System.debug(which + ' percentage change exceeded');
                }                    
            }
        }
    }
}