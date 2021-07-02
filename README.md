# Event Driven Solution

Scope
```
Design a system composed of one or more services that consumes events from a stream. Some types of the events should be stored for further operations while others should be enriched and forwarded as explained below.

The events coming from the stream are:

● user events, with average throughput of 20 per second
● subscription events, 5 per second
● lesson events, 100 per second


The system should store the current state of a user subscription in a database. This state information should be used to enrich lesson events by adding subscription_status, subscription_type (from subscription event) and country (from user event) attributes for all users. This subscription data should match the language of the lesson. A user can be associated with multiple subscriptions, each for a different language. A specific lesson can be associated with one language and one user only. All events should be forwarded to another, output stream after processing.

We can assume that the events are pushed to the stream in the correct order for a given user, for example, a subscription event will never enter the stream before the user (create) event.
```

AWS Services used..
```
IAM         =   For managing access and permissions.
Lambda      =   Trigger functions to process events.
SQS         =   As a message queue to receive events from application.
DynamoDB    =   To store user subscription data.
S3          =   To store all events after processing.
```

## Architecture Design

* Assuming events are pushed to SQS queue from application.

1. On successfully receiving events from application to SQS FIFO Queue, "lambda" will gets triggered which pulls events in a batch wise.
2. User/subscription events - Based on create or update operation, lambda updates the dynamodb table that stores user subscriptions.
3. Lesson events - Lambda gets item from dynamodb based on userID from the event and enrich lesson events by adding subscriptiontype, subscriptionstatus and country.
4. All events are processed by adding new key=value to json. [event-processed = true/false]

## Ways to scaleup if the volume increases.

Current volume

```
UserEvents            - 5 per second
SubscriptionEvents    - 20 per second
LessonEvents          - 100 per second.
```

AWS Services configuration.

* *SQS FIFO Queue*
        > Queue can stream upto 1000 events per second. So that mean Queue can handle upto 8 times increase in load.

* *Lambda*
        > Pulls the events based on batch size set.
        > For current capacity it can be set to 130.
        > If volume increases, we can increas batch size and may also need to incrase lambda memory size after testing.

* *DynamoDB*
        > We can increase read/write capacity units to handle increase in reads/writes on table.
        > For current volume, we can set,
                read capacity - 100
                write capacity - 25
        > We can also opt for DynamoDB On-demand read/write capacity mode. It has capable of serving thousands of requests per second without capacity planning.

* *S3Buckets*
        > As S3 provides unlimited storage, we do not have to worry about increase in load.


### Data Structure for User Subscriptions data
```
    Name            Type
1. UserName        String
2. UserUUID        String
3. FirstName       String  
4. LastName        String
5. Country         String
6. Active          Boolean
7. Subscriptions   Map

Example  

{
  "Active": true,
  "Country": "India",
  "FirstName": "Gaman",
  "LastName": "Ramachandrappa",
  "Subscriptions": {
    "English": {
      "SubscriptionName": "Quarterly",
      "SubscriptionPeriod": 60,
      "SubscriptionStatus": "Active",
      "SubscriptionType": "Quarterly"
    }
  },
  "UserName": "Gaman Ram",
  "UserUUID": "2"
}
```

### Package structure
```
function.zip = zipped package containing lambda function and its dependencies.
policies     = IAM policies folder containing policies to create a Execution Role for Lambda.
terraform    = Contains terraform scripts to set up the infrastructure(Services).
README.md    = Architecture design and details.
```

