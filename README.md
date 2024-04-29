# IKno

IKno is an prototype application for authoring and presenting educational subject matter. It aims to leverage conceptual structures inherent in language to to sequence information to the reader such that learning time is minimized.

## Subjects and Topics

Information in IKno is organized into subjects and topics. A subject is composed of a set of topics.

IKno knows how topics depend on each other, allowing topics to presented in a sequence that optimizes learning effectiveness.

Currently, IKno subjects are incomplete and have been authored solely for the purpose of testing IKno. The most complete subject and one that will be expanded upon is Business Process Management. There is also a subject describing IKno itself that you may find of interest.

## Learning Mode

Learning mode refers to having IKno step you through topics based on what you already know. Topics are ordered from the most fundamental to the most complex.

There are two ways to use learning mode: at the subject level or at the topic level.

At the subject level, IKno will present topics from the subject as a whole.

At the topic level, IKno will present only those topics required for the understanding of the selected topic.

## Testing Mode

In Testing mode, IKno will present questions on the topics that you have learned.

Again, there are two ways to use testing mode: at the subject level or at the topic level.

At the subject level, IKno will present questions from the subject as a whole.

At the topic level, IKno will present only those questions required relevant to a selected topic.

Note: If the author of an IKno subject hasn't written any questions, testing mode won't be available or visible.

## Using IKno

Every effort has been made to make IKno as simple as possible, so you will likely be able to surmise, for the most part, how things work.

However, if you want a better understanding or are just curious, you can find detailed information describing IKno by clicking on the List of Subjects button below and then clicking in the IKno subject.

## Running Locally

````
$ mix ecto.create
````
````
$ mix ecto.migrate
````
````
$ mix phx.server
````

## Publically available

IKno is deployed at [https://irvine-i-kno.fly.dev/](https://irvine-i-kno.fly.dev/). Feel free to take a look and try it out.

## Comments, Question, Issues

Please file an issue in GitHub.
