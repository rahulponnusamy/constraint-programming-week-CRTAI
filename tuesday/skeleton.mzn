include "globals.mzn";

int:nrActivity;
int:nrEvents;
int:nrResources;
int:nrSessions;
int:sessionDuration;
int:nrPrecedences;
int:nrConflicts;
int:nrAthletesPerSession;

type Activity = record(string:event,string:phase,string:resource,int:nr,int:duration,int:participants,int:finals,int:stageNr);
type Precedence = record(string:temporalRelation,string:event,string:before,string:after,int:beforeNr,int:afterNr);
type Conflict = record(string:event1,string:event2);

% data arrays
array[1..nrActivity] of Activity:activity;
array[1..nrPrecedences] of Precedence:precedences;
array[1..nrConflicts] of Conflict:conflicts;
array[1..nrResources] of string:resources;
array[1..nrEvents] of string:events;
