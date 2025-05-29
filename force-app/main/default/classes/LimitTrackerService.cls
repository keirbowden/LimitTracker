public with sharing class LimitTrackerService 
{
    @TestVisible 
    private static LimitTrackerService instance;

    @TestVisible
    private Map<String, LimitSnapshot> trackersByName=new Map<String, LimitSnapshot>();

    @TestVisible
    public List<LimitSnapshot> snapshotsToPublish = new List<LimitSnapshot>();

    @TestVisible
    private Boolean trackingEnabled=false;

    private LimitTrackerService() 
    {

    }

    public static LimitTrackerService GetService()
    {
        if (null==instance)
        {
            instance=new LimitTrackerService();
            instance.getConfiguration();
        }

        return instance;
    }

    private void getConfiguration()
    {
        Limit_Tracker_Configuration__mdt config = 
                Limit_Tracker_Configuration__mdt.getInstance('Default');
    
        if (null!=config)
        {
            trackingEnabled=config.Enabled__c;
        }
    }

    public void startTracking(String name)
    {
        if (trackingEnabled)
        {
            LimitSnapshot snapshot=new LimitSnapshot(name);
            trackersByName.put(name, snapshot);
        }
    }

    public void startTracking(String name, String additionalInfo)
    {
        if (trackingEnabled)
        {
            LimitSnapshot snapshot=new LimitSnapshot(name, additionalInfo);
            trackersByName.put(name, snapshot);
        }
    }

    public LimitSnapshot stopTracking(String name)
    {
        LimitSnapshot snapshot=null;

        if (trackingEnabled)
        {
            LimitSnapshot start=trackersByName.remove(name);

            snapshot=new LimitSnapshot(name);

            snapshot.offsetFromStart(start);
        }

        return snapshot;
    }
    
    public Database.SaveResult stopTrackingAndPublishSnapshot(String name)
    {
        Database.SaveResult result=null;
        if (trackingEnabled)
        {        
            LimitSnapshot snapshot=stopTracking(name);

            result=this.publishSnapshot(snapshot);
        }

        return result;
    }
    
    public void stopTrackingAndQueueSnapshot(String name)
    {
        if (trackingEnabled)
        {
            LimitSnapshot snapshot=stopTracking(name);

            snapshotsToPublish.add(snapshot);
        }
    }

    public List<Database.SaveResult> publishQueuedSnapshots()
    {
        List<Database.SaveResult> results=null;

        if (trackingEnabled)
        {
            if (!snapshotsToPublish.isEmpty())
            {
                results=publishSnapshots(snapshotsToPublish);
            }
        }

        return results;
    }

    private Database.SaveResult publishSnapshot(LimitSnapshot snapshot)
    {
        Database.SaveResult result=null;

        if (trackingEnabled)
        {
            List<Database.SaveResult> results=publishSnapshots(new List<LimitSnapshot>{snapshot});

            result=results[0];
        }

        return result;
    }

    private List<Database.SaveResult> publishSnapshots(List<LimitSnapshot> snapshots) 
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

        return results;
    }

    public void processSnapshotEvents(List<Limit_Snapshot__e> snapshots)
    {
        if (trackingEnabled)
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

            Map<Id, Limit_Tracker__c> limitTrackersById=new Map<Id, Limit_Tracker__c>(
                        [select Id, Name
                         from Limit_Tracker__c 
                         where Name in :snapshotsByName.keySet()]);

            List<Limit_Tracker_Snapshot__c> trackerSnapshotsToAdd=
                        new List<Limit_Tracker_Snapshot__c>();

            Map<Id, Limit_Tracker_Snapshot__c> lastSnapshotForTracker=new Map<Id, Limit_Tracker_Snapshot__c>();

            for (Limit_Tracker__c tracker : limitTrackersById.values())
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
                    trackerSnapshot.User__c=snapshot.User_Id__c;
                    trackerSnapshotsToAdd.add(trackerSnapshot);

                    if ( (null==lastDT) || (snapshot.CreatedDate > lastDT) )
                    {
                        lastDT=snapshot.CreatedDate;
                        tracker.CPU_Last__c=snapshot.CPU__c;
                        tracker.Heap_Last__c=snapshot.Heap__c;  
                        tracker.DML_Records_Last__c=snapshot.DML_Records__c;    
                        tracker.DML_Statements_Last__c=snapshot.DML_Statements__c;  
                        tracker.SOQL_Queries_Last__c=snapshot.SOQL_Queries__c;  
                        lastSnapshotForTracker.put(tracker.Id, trackerSnapshot);
                    }
                }
            }

            insert trackerSnapshotsToAdd;
            for (Id trackerId : lastSnapshotForTracker.keySet())
            {
                System.debug('Setting limit tracker ' + limitTrackersById.get(trackerId).Name + ' last to ' + lastSnapshotForTracker.get(trackerId).Id);
                limitTrackersById.get(trackerId).Last_Snapshot__c=lastSnapshotForTracker.get(trackerId).Id;
            }
            update limitTrackersById.values();
        }
    }

    public void processUpdates(List<Limit_Tracker__c> oldTrackers, 
                                List<Limit_Tracker__c> newTrackers)
    {
        if (trackingEnabled)
        {
            List<Id> snapshotIds=new List<Id>();
            for (Limit_Tracker__c tracker : newTrackers)
            {
                snapshotIds.add(tracker.Last_Snapshot__c);   
            }
            Map<Id, Limit_Tracker_Snapshot__c> snapshotsById=
                           new Map<Id, Limit_Tracker_Snapshot__c>([select Id, Additional_Information__c 
                                               from Limit_Tracker_Snapshot__c where Id in :snapshotIds]);
                                               
            List<LimitTrackerAlert> alerts=new List<LimitTrackerAlert>();

            System.debug('Processing tracker updates');
            for (Integer idx=0; idx<oldTrackers.size(); idx++)
            {
                Limit_Tracker__c oldTracker=oldTrackers[idx];
                Limit_Tracker__c newTracker=newTrackers[idx];

                alerts.addAll(raiseAlerts(newTracker, snapshotsById.get(newTracker.Last_Snapshot__c), 
                                'Heap', oldTracker.Heap_Last__c.intValue(), 
                            newTracker.Heap_Last__c.intValue(),
                            newTracker.Heap_Alert_Threshold_1__c?.intValue(),
                            newTracker.Heap_Alert_Change__c?.intValue()));
                
                alerts.addAll(raiseAlerts(newTracker, snapshotsById.get(newTracker.Last_Snapshot__c), 
                            'CPU', oldTracker.CPU_Last__c.intValue(), 
                            newTracker.CPU_Last__c.intValue(),
                            newTracker.CPU_Alert_Threshold_1__c?.intValue(),
                            newTracker.CPU_Alert_Change__c?.intValue()));
            }

            if (!alerts.isEmpty())
            {
                sendAlerts(alerts);
            }
        }
    }

    private List<LimitTrackerAlert> raiseAlerts(Limit_Tracker__c tracker, Limit_Tracker_Snapshot__c last, 
                                                String which, 
                                                Integer oldVal, Integer newVal,
                                                Integer alertThreshold, Integer changePercent)
    {
        List<LimitTrackerAlert> alerts=new List<LimitTrackerAlert>();

        System.debug('Old ' + which + ' = ' + oldVal);
        System.debug('New ' + which + ' = ' + newVal);

        if (oldVal<newVal)
        {
            System.debug(which + ' increased');
            if ( (null!=alertThreshold) && (newVal>alertThreshold) )
            {
                alerts.add(new LimitTrackerAlert(tracker.Name + ' ' + which + ' limit consumption alert',
                              'The ' + which + ' limit consumption alert threshold of ' + alertThreshold + 
                              ' has been exceeded with a value of ' + newVal + 
                              '<p>Additional information:</p>' + 
                              '<p>' + last.Additional_Information__c + '</p>')); 
                System.debug(which + ' alert threshold 1 exceeded');
            }
                
            // don't alert for the first record
            if ( (null!=changePercent) && (0!=oldVal) )
            {
                Integer diff=newVal-oldVal;
                Integer percent=(diff * 100) / oldVal;
                System.debug('Percent = ' + percent + ' and threshold = ' + changePercent);
                if (percent>=changePercent)
                {
                    alerts.add(new LimitTrackerAlert(tracker.Name + ' ' + which + ' limit consumption alert',
                              'The ' + which + ' limit consumption percentage change of ' + newVal + 
                                ' exceeded the configured value of ' + changePercent + 
                                '<p>Additional information:</p>' + 
                                '<p>' + last.Additional_Information__c + '</p>')); 

                    System.debug(which + ' percentage change exceeded');
                }                    
            }
        }

        return alerts;
    }

    public void sendAlerts(List<LimitTrackerAlert> alerts)
    {
        System.debug('Alerts = ' + alerts);
        List<LimitNotifierInterface> notifiers=new List<LimitNotifierInterface>();

        List<Limit_Alert_Notifier__mdt> notifierMDTs=Limit_Alert_Notifier__mdt.getAll().values();
        for (Limit_Alert_Notifier__mdt notifierMDT : notifierMDTs)
        {
            System.Type notType=Type.forName(notifierMDT.Namespace__c,
                                            notifierMDT.Apex_Class__c);

            LimitNotifierInterface notifier=(LimitNotifierInterface) notType.newInstance();
                                                  

            notifier.configure(notifierMDT.Additional_Config__c);
            notifiers.add(notifier);
        }

        for (LimitNotifierInterface notifier : notifiers)
        {
            notifier.notify(alerts);
        }
    }
}