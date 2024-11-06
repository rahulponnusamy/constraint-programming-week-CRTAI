% int: n;
% % defining variables
% var 1..n: x;
% var 1..n: y;
% constraint x+y>n;
% solve satisfy

include "globals.mzn";


int:nrActivity;      % 134
int:nrEvents;        % 43
int:nrResources;     % 7
int:nrSessions;      % 16
int:sessionDuration; % 240

type Activity = record(string:event,string:phase,string:resource,int:nr,int:duration,int:participants,int:finals,int:stageNr);

% data arrays
array[1..nrActivity] of Activity:activity;
array[1..nrResources] of string:resources;
array[1..nrEvents] of string:events;

% Decision variables
array[1..nrActivity] of var 1..nrSessions: session; % Session assignment for each activity


% Constraint 1 -- schduling all events with specific sequence of stages
constraint
    forall(i in 1..nrActivity-1 where activity[i].event == activity[i+1].event /\ activity[i].stageNr < activity[i+1].stageNr) (
        session[i] <= session[i+1]
    );

% constraint 2 -- no 2 activities use the same resources
constraint
    forall(s in 1..nrSessions, r in 1..nrResources) (
        let {
        var int: resource_usage = sum(i in 1..nrActivity where activity[i].resource == resources[r] /\ session[i] == s) (activity[i].duration)
        }
        in
        resource_usage <= sessionDuration
    );

% Optional: checking and balancing finals : 
constraint
forall(s in 1..nrSessions) (
    let {
      var int: count_finals = sum(i in 1..nrActivity where activity[i].finals == 1 /\ session[i] == s)(activity[i].finals)
    }
    in
      count_finals <= 3 /\ count_finals >= 2
  );

% Optional: balancing activities in session

constraint
  forall(j in 1..nrSessions) (
        count_eq(session, j) >= 8 /\ count_eq(session, j) <= 9
     )
;


solve satisfy;