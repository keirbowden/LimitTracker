public with sharing class LimitSnapshot 
{
    public String name;
    public Integer cpu;
    public Integer heap;
    public Integer dmlRecords;
    public Integer dmlStatements;
    public Integer soqlQueries;
    public Integer soqlRecords;
    public String additionalInfo;

    public LimitSnapshot(String name)
    {
        this.name=name;
        this.cpu=Limits.getCpuTime();
        this.heap=Limits.getHeapSize();
        this.dmlRecords=Limits.getDmlRows();
        this.dmlStatements=Limits.getDmlStatements();
        this.soqlQueries=Limits.getQueries();
        this.soqlRecords=Limits.getQueryRows();
    }

    public LimitSnapshot(String name, String additionalInfo)
    {
        this(name);
        this.additionalInfo=additionalInfo;
    }

    public void offsetFromStart(LimitSnapshot start)
    {
        // if start is null, we'll assume it is for the entirety
        // of the transaction.
        if (null!=start)
        {
            this.cpu-=start.cpu;
            this.heap-=start.heap;
            this.dmlRecords-=start.dmlRecords;
            this.dmlStatements-=start.dmlStatements;
            this.soqlQueries-=start.soqlQueries;
            this.soqlRecords-=start.soqlRecords;
            this.additionalInfo=start.additionalInfo;
        }
    }

    public LimitSnapshot(Limit_Tracker_Snapshot__c snapshot)
    {
        this.name=snapshot.Name;
        this.cpu=snapshot.CPU__c.intValue();
        this.heap=snapshot.Heap__c.intValue();
        this.dmlRecords=snapshot.DML_Records__c.intValue();
        this.dmlStatements=snapshot.DML_Statements__c.intValue();
        this.soqlQueries=snapshot.SOQL_Queries__c.intValue();
        this.soqlRecords=snapshot.SOQL_Records__c.intValue();
        this.additionalInfo=snapshot.Additional_Information__c;
    }

    public LimitSnapshot(Limit_Snapshot__e snapshot)
    {
        this.name=snapshot.Name__c;
        this.cpu=snapshot.CPU__c.intValue();
        this.heap=snapshot.Heap__c.intValue();
        this.dmlRecords=snapshot.DML_Records__c.intValue();
        this.dmlStatements=snapshot.DML_Statements__c.intValue();
        this.soqlQueries=snapshot.SOQL_Queries__c.intValue();
        this.soqlRecords=snapshot.SOQL_Records__c.intValue();
        this.additionalInfo=snapshot.Additional_Information__c;
    }

    public Limit_Snapshot__e toSnapshotEvent()
    {
        Limit_Snapshot__e snEv=new Limit_Snapshot__e(Name__c=this.name,
                                                     CPU__c=this.cpu,
                                                     Heap__c=this.heap,
                                                     DML_Records__c=this.dmlRecords,
                                                     DML_Statements__c=this.dmlStatements,
                                                     SOQL_Queries__c=this.soqlQueries,
                                                     SOQL_Records__c=this.soqlRecords,
                                                     Additional_Information__c=this.additionalInfo);
        return snEv;
    }        
}