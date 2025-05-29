public with sharing class EmailLimitNotifier implements LimitNotifierInterface
{
    private String toAddress;
    
    public EmailLimitNotifier() {}

    public void configure(String config) 
    {
        List<String> pairs=config.split(',');
        for (String pair : pairs)
        {
            List<String> eles=pair.split('=');
            String name=eles[0];
            String value=eles[1];
            if ('to'==name)
            {
                toAddress=value;
            }
        }
    }

    public void notify(LimitTrackerAlert alert)
    {
        this.notify(new List<LimitTrackerAlert>{alert});
    }

    public void notify(List<LimitTrackerAlert> alerts)
    {
        if (null!=toAddress)
        {
            System.debug('Send emails to ' + toAddress + '!');
            List<Messaging.SingleEmailMessage> messages=new List<Messaging.SingleEmailMessage>();
            for (LimitTrackerAlert alert : alerts)
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSubject(alert.title);
                mail.setHtmlBody(alert.message);
                mail.setSaveAsActivity(false);
                mail.setToAddresses(new List<String>{toAddress});
                messages.add(mail);
            }
    
            List<Messaging.Sendemailresult> resultList = Messaging.sendEmail(messages , false);
            for (Messaging.Sendemailresult result : resultList)
            {
                if (!result.isSuccess())
                {
                    System.debug('Email failed :' + result.getErrors()[0].getMessage());
                }
            }
        }
    }
}