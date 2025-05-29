public with sharing class ChatterLimitNotifier implements LimitNotifierInterface 
{
    private Id groupId=null;
    
    public ChatterLimitNotifier() {}

    public void configure(String config) 
    {
        List<String> pairs=config.split(',');
        for (String pair : pairs)
        {
            List<String> eles=pair.split('=');
            String name=eles[0];
            String value=eles[1];
            if ('groupName'==name)
            {
                List<CollaborationGroup> groups=[SELECT Id From CollaborationGroup WHERE Name=:value];
                if (!groups.isEmpty())
                {
                    groupId=groups[0].Id;
                }
            }
        }
    }

    public void notify(LimitTrackerAlert alert)
    {
        this.notify(new List<LimitTrackerAlert>{alert});
    }

    public void notify(List<LimitTrackerAlert> alerts)
    {
        if (null!=groupId)
        {
            List<FeedItem> items=new List<FeedItem>();
            System.debug('Notifying Group ' + groupId + '!');
            for (LimitTrackerAlert alert : alerts)
            {
                System.debug('Alert = ' + alert.message + '!');
                FeedItem item = new FeedItem(
                            parentId = groupId, // where to post message
                            body = alert.message,
                            isRichText = true
                );
                items.add(item);

            }
            insert items;
        }
	}			
}