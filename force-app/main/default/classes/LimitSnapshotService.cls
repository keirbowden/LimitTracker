public with sharing class LimitSnapshotService 
{
    @TestVisible private static LimitSnapshotService instance;

    private Map<String, LimitSnapshot> trackersByName=new Map<String, LimitSnapshot>();

    private LimitSnapshotService() 
    {
    }

    public static LimitSnapshotService GetService()
    {
        if (null==instance)
        {
            instance=new LimitSnapshotService();
        }

        return instance;
    }

    public void startTracking(String name)
    {
        LimitSnapshot snapshot=new LimitSnapshot(name);
        trackersByName.put(name, snapshot);
    }

    public void startTracking(String name, String additionalInfo)
    {
        LimitSnapshot snapshot=new LimitSnapshot(name, additionalInfo);
        trackersByName.put(name, snapshot);
    }

    public LimitSnapshot stopTracking(String name)
    {
        LimitSnapshot start=trackersByName.remove(name);

        LimitSnapshot snapshot=new LimitSnapshot(name);

        snapshot.offsetFromStart(start);

        return snapshot;
    }
    
    public void publishSnapshot(LimitSnapshot snapshot)
    {
        publishSnapshots(new List<LimitSnapshot>{snapshot});
    }

    public void publishSnapshots(List<LimitSnapshot> snapshots) 
    {
        List<Limit_Snapshot__e> lsEvents=new List<Limit_Snapshot__e>();
        for (LimitSnapshot snapshot : snapshots)
        {
            Limit_Snapshot__e lsEvent=snapshot.toSnapshotEvent();
            lsEvents.add(lsEvent);
        }

        List<Database.SaveResult> results = EventBus.publish(lsEvents);

        // Inspect publishing result for each event
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) 
            {
                System.debug('Successfully published event.');
            } 
            else 
            {
                for(Database.Error err : sr.getErrors()) 
                {
                    System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                }
            }       
        }
    }
}