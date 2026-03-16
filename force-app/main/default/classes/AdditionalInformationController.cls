public with sharing class AdditionalInformationController 
{
    @AuraEnabled(cacheable=true)
    public static List<AssociatedRecord> getAssociatedRecords(Id limitTrackerId)
    {
        List<AssociatedRecord> associatedRecords= 
            LimitSnapshotService.GetService().getAssociatedRecordsForSnapshot(limitTrackerId);

        for (AssociatedRecord record : associatedRecords)
        {
            System.debug('Associated record: ' + record.label + ' - ' + record.message);
        }

        return associatedRecords;
    }
}