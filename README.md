# Limit Tracker

(Code originally created to accompany London's Calling 2025 talk).

## Overview

Limit Tracker allows you to measure the impact of your code on Salesforce Transaction Governor Limits. It has the following key benefits:
- Granular - if you need to, you can measure the limit usage down to a single line of code. 
- Unobtrusive - the limits information is captured in an immediately published Platform Event, thus ensuring no impact on the current transaction in terms of writing to the database etc. All decisions and automation are handled in a separate transaction.
- Simple - simply create your Limit Tracker object, then all you need is one line of Apex to start tracking, and a second line to finish tracking and either publish the event or retain it for bulk publishing later in the transaction.

## Installation - IMPORTANT
The trigger that consumes the platform event executes as a regular user rather than the Automated Process User, but obviously this is different for every org. In order to deploy the application you will need to do one of the following:
- Update the username in the `PlatformEventSubscriberConfigs/LimitSnapshot_ai.platformEventSubscriberConfig-neta.xml` file to one that is present in your org
- Delete the `PlatformEventSubscriberConfigs/LimitSnapshot_ai.platformEventSubscriberConfig-neta.xml` and have the trigger execute as the Automated Process User - note that this means you will need to do additional work to be able to configure the Email notifier, as the Automated Process User can't send emails unless it is assigned an existing, verified organization-wide email address.

After deploying the code to your org, assign yourself the `LimitsTracking` permission set. 

## Usage

In order to track limit consumption you will need to create at least one instance of the `Limit Tracker` sObject - in fact it's highly likely that you'll want to create a number of these. This is the parent object that each tracking snapshot is associated with, and that allows you to monitor changes over time. Choose a unique name for each `Limit Tracker` as this is how they are identified.

Once you have one or more trackers in place, capturing snapshots is just a couple of lines of code - get the `LimitTrackerService`, start tracking for a specific `Limit Tracker` - use the unique name you specified when creating the tracker, and pass any additional information you want captured with the snapshot. Once the processing you wish to track is complete - in this case a fairly useless loop to consume some CPU - stop tracking and either publish the snapshot immediately or queue it for publication later in the transaction.

````
LimitTrackerService lts=LimitTrackerService.GetService();
lts.startTracking('Loop1', 'processOpp <p>Opp Id: 006RR00000Lfc65YAB</p>');
for (Integer idx1=0; idx1<100; idx1++)
{
    for (Integer idx2=0; idx2<2000; idx2++)
    {
        String val=''+idx1+':'+idx2;
    }
}
lts.stopTrackingAndPublishSnapshot('Loop1');
````

Once you have captured some snapshots you'll be able to see any patterns emerging through the embedded charts in the `Limit Tracker` Lighting record page:

<img width="946" alt="Screenshot 2025-06-22 at 12 41 29" src="https://github.com/user-attachments/assets/291dc9ce-3e3a-42a8-9506-05aec3cb2320" />

At present it is your responsibility to clean up old snapshots or trackers that are no longer required - a batch job will be added in a future release.
