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


% decision variable declaration
array[1..nrActivity] of var 1..nrSessions: x_out;

% Resource usage constraints
constraint
forall(r in 1..nrResources, s in 1..nrSessions) (
    let {
      var int: resource_usage = sum(i in 1..nrActivity where activity[i].resource == resources[r] /\ x_out[i] == s) (activity[i].duration)
    }
    in
      resource_usage <= sessionDuration
  );


% Event sequencing constraint: for all activities if activity.event is same and stageNr is in ascendingorder then  and x_out[e]<x_out[e+1]

constraint
  forall(e in 1..nrActivity-1 where activity[e].event == activity[e+1].event /\ activity[e].stageNr < activity[e+1].stageNr  ) (
    x_out[e] <= x_out[e+1]
  );
  


% Optional: checking and balancing finals : 
constraint
forall(s in 1..nrSessions) (
    let {
      var int: count_finals = sum(i in 1..nrActivity where activity[i].finals == 1 /\ x_out[i] == s)(activity[i].finals)
    }
    in
      count_finals <= 3 /\ count_finals >= 2
  );





% Optional: balancing activities in session

constraint
  forall(j in 1..nrSessions) (
        count_eq(x_out, j) >= 8 /\ count_eq(x_out, j) <= 9
     )
;




solve satisfy;