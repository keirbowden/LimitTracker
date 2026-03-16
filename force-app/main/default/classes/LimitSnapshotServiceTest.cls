@isTest
private class LimitSnapshotServiceTest {
    @isTest
    static void TestGetAdditionalRecords()
    {
        Account acc=new Account(Name='Unit Test');
        insert acc;
        
        Limit_Tracker__c tracker=new Limit_Tracker__c(Name='Test Tracker');
        insert tracker;

        Limit_Tracker_Snapshot__c trackerSnapshot=
                                new Limit_Tracker_Snapshot__c();

        trackerSnapshot.CPU__c=1;
        trackerSnapshot.DML_Records__c=1;
        trackerSnapshot.DML_Statements__c=1;
        trackerSnapshot.Heap__c=1;
        trackerSnapshot.SOQL_Queries__c=1;
        trackerSnapshot.SOQL_Records__c=1;
        trackerSnapshot.JSON_Additional_Info__c=true;
        trackerSnapshot.Additional_Information__c=
                '{ "parentAccount": {' +
                '     "recordId":"' + acc.Id + '"' +
                '   }' +
                '}';

        trackerSnapshot.Limit_tracker__c=tracker.Id;    
        trackerSnapshot.User__c=UserInfo.getUserId();
        insert trackerSnapshot;

        LimitSnapshotServiceIF service = LimitSnapshotService.GetService();
        Test.startTest();
        List<AssociatedRecord> associatedRecords=
                    service.getAssociatedRecordsForSnapshot(trackerSnapshot.Id);
        Test.stopTest();
        Assert.areEqual(2, associatedRecords.size(), 
                       'Expected 2 associated records - account and user');
    }
}