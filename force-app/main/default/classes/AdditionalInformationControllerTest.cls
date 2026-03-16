@IsTest
private class AdditionalInformationControllerTest {
    @isTest
    static void TestGetAdditionalRecords()
    {
        Account acc=new Account(Name='Unit Test');
        insert acc;

        LimitSnapshotServiceStub lssStub=new LimitSnapshotServiceStub();
        lssStub.associatedRecords=
            new List<AssociatedRecord>{
                new AssociatedRecord('parentId', acc, 'All good')
            };

        LimitSnapshotService.instance=lssStub;
        Test.startTest();
        List<AssociatedRecord> associatedRecords=
            AdditionalInformationController.getAssociatedRecords('a00Aw00000QBgMpIAL');
        Test.stopTest();
        Assert.areEqual(1, associatedRecords.size(), 'Expected 1 associated record');
    }
}