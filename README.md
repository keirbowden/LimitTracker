# Limit Tracker

(Code originally created to accompany London's Calling 2025 talk).

## Overview

Limit Tracker allows you to measure the impact of your code on Salesforce Transaction Governor Limits. It has the following key benefits:
- Granular - if you need to, you can measure the limit usage down to a single line of code. 
- Unobtrusive - the limits information is captured in an immediately published Platform Event, thus ensuring no impact on the current transaction in terms of writing to the database etc. All decisions and automation are handled in a separate transaction.
- Simple - simply create your Limit Tracker object, then all you need is one line of Apex to start tracking, and a second line to finish tracking and either publish the event or retain it for bulk publishing later in the transaction.

## IMPORTANT
The trigger that consumes the platform event executes as a regular user rather than the Automated Process User, but obviously this is different for every org. In order to deploy the application you will need to do one of the following:
- Update the username in the `PlatformEventSubscriberConfigs/LimitSnapshot_ai.platformEventSubscriberConfig-neta.xml` file to one that is present in your org
- Delete the `PlatformEventSubscriberConfigs/LimitSnapshot_ai.platformEventSubscriberConfig-neta.xml` and have the trigger execute as the Automated Process User - note that this means you will need to do additional work to be able to configure the Email notifier, as the Automated Process User can't send emails unless it is assigned an existing, verified organization-wode email address.
