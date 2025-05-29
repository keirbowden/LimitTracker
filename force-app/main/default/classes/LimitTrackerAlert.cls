public with sharing class LimitTrackerAlert 
{
    public String title {get; set;}
    public String message {get; set;}

    public LimitTrackerAlert(String title, String message) 
    {
        this.title=title;
        this.message=message;
    }
}