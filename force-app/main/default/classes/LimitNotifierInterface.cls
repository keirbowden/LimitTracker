public interface LimitNotifierInterface 
{
    void configure(String config);
    void notify(LimitTrackerAlert alert);
    void notify(List<LimitTrackerAlert> alerts);
}