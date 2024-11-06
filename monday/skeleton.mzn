include "globals.mzn";

int:nrActivity;
int:nrEvents;
int:nrResources;
int:nrSessions;
int:sessionDuration;

type Activity = record(string:event,string:phase,string:resource,int:nr,int:duration,int:participants,int:finals,int:stageNr);

% data arrays
array[1..nrActivity] of Activity:activity;
array[1..nrResources] of string:resources;
array[1..nrEvents] of string:events;

% sum of all the activities duration using the same resource in each session < 240 minutes
constraint Activity.duration<240;


% same event has to be in order, round1-pre-finals



solve satisfy
