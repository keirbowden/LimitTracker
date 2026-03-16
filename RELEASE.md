# Limit Tracker Release Notes

## 0.8

Added ability to identify related records via additional information in JSON format.

`LimitTrackerService` now implements `LimitTrackerServiceIF` - note that any code using the `GetService` method needs to be updated to expect a `LimitTrackerServiceIF` response.
