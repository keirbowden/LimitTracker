@isTest
private class LimitTrackerServiceTest 
{

    private static LimitTrackerService GetService()
    {
        LimitTrackerService service = LimitTrackerService.GetService();
        service.trackingEnabled=true;

        return service;
    }

    @IsTest
    private static void TestGetServiceNotNull()
    {
        LimitTrackerService service = GetService();
        Assert.isNotNull(service, 'GetService() should never return null');
    }

    @IsTest
    private static void TestGetServiceSingleton()
    {
        LimitTrackerService service = GetService();
        
        Profile prof=[select Id from Profile where Name='System Administrator'];
        User testUser = new User(FirstName = 'Test', LastName = 'User',
                                 Email = 'testuser@bb.lc25.test250527',
                                 Username = 'testuser@bb.lc25.test250527',
                                 Alias = 'tuser',
                                 TimeZoneSidKey = 'America/Los_Angeles',
                                 LocaleSidKey = 'en_US',
                                 EmailEncodingKey = 'UTF-8',
                                 ProfileId = prof.Id,
                                 LanguageLocaleKey = 'en_US');
        insert testUser;

        LimitTrackerService service2;
        System.runAs(TestUser)
        {
             service2 = LimitTrackerService.GetService();
        }

        Assert.areEqual(service, service2, 'GetService() should always return the singleton instance');
    }

    @IsTest
    private static void TestStartTracking()
    {
        LimitTrackerService service = GetService();
        Test.startTest();
        service.StartTracking('Test1');
        Test.stopTest();

        Assert.isTrue(service.trackersByName.containsKey('Test1'), 'Tracker should have been created for Test1');
    }

    @IsTest
    private static void TestStartTrackingAdditionalInfo()
    {
        LimitTrackerService service = GetService();
        Test.startTest();
        service.StartTracking('Test1', 'Additional Info');
        Test.stopTest();

        Assert.isTrue(service.trackersByName.containsKey('Test1'), 'Tracker should have been created for Test1');
        Assert.areEqual(service.trackersByName.get('Test1').additionalInfo, 'Additional Info', 
                                'Additional information not captured or incorrect');
    }

    @IsTest
    private static void TestStopTracking()
    {
        LimitTrackerService service = GetService();

        Test.startTest();
        LimitSnapshot lss=service.stopTracking('Test Tracker');
        Test.stopTest();

        Assert.areEqual(lss.name, 'Test Tracker', 'Stopped tracker name does not match requested');
    }

    @IsTest
    private static void TestStopAndPublish()
    {
        Limit_Tracker__c tracker=new Limit_Tracker__c(Name='Test Tracker');
        insert tracker;

        LimitTrackerService service = GetService();
        service.StartTracking('Test Tracker', 'Unit Test');

        Test.startTest();
        service.stopTrackingAndPublishSnapshot('Test Tracker');
        Test.stopTest();        

        List<Limit_Tracker__c> trackersFromDB=[select Name, 
                                               (select Name, Additional_Information__c from Limit_Tracker_Snapshots__r)
                                               from Limit_Tracker__c
                                               where name=:Tracker.Name];
        Assert.areEqual(trackersFromDB.size(), 1, 'Unable to retrieve limit tracker after insertion');
        Assert.areEqual(trackersFromDB[0].Limit_Tracker_Snapshots__r.size(), 1,
                        'Expected there to be 1 limit tracker snapshot after publishing an event');
    }

    @IsTest
    private static void TestBreachThreshold()
    {
        Limit_Tracker__c tracker=new Limit_Tracker__c(Name='Test Tracker',
                                                      CPU_Alert_Threshold_1__c=1);
        insert tracker;

        LimitTrackerService service = GetService();
        Test.startTest();
        service.StartTracking('Test Tracker', 'Unit Test');

        for (Integer idx=0; idx<500; idx++)
        {
            String val=''+idx;
        }
        service.stopTrackingAndPublishSnapshot('Test Tracker');
        Test.stopTest();
    }
}
