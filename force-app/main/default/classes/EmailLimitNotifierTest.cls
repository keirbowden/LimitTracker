@isTest
private class EmailLimitNotifierTest {
    @IsTest
    private static void TestNotifier(){
        EmailLimitNotifier notifier=new EmailLimitNotifier();
        notifier.configure('to=keir.bowden@googlemail.com');

        LimitTrackerAlert alert=new LimitTrackerAlert('Test Tracker', 'CPU exceeded 5000');
        notifier.notify(new List<LimitTrackerAlert>{alert});
    }
}