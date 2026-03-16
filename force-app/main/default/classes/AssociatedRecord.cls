public class AssociatedRecord
{
    @AuraEnabled
    public String label;

    @AuraEnabled
    public sObject record;

    @AuraEnabled
    public String message;

    public AssociatedRecord(String label, sObject record, String message) {
        this.label=label;
        this.record=record;
        this.message=message;
    }
}