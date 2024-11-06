include "ide/vis.mzn";
include "globals.mzn";

% constant variables
int:nrActivity;      % 134
int:nrEvents;        % 43
int:nrResources;     % 7
int:nrSessions;      % 16
int:sessionDuration; % 240
int:nrPrecedences;   % 91
int:nrConflicts;     % 41
int:nrAthletesPerSession; % 250


type Activity = record(string:event,string:phase,string:resource,int:nr,int:duration,int:participants,int:finals,int:stageNr);

type Precedence = record(string:temporalRelation,string:event,string:before,string:after,int:beforeNr,int:afterNr);

type Conflict = record(string:event1,string:event2);

% data arrays
array[1..nrActivity] of Activity:activity;
array[1..nrPrecedences] of Precedence:precedences;
array[1..nrConflicts] of Conflict:conflicts;
array[1..nrResources] of string:resources;
array[1..nrEvents] of string:events;


% Decision variables
array[1..nrActivity] of var 1..nrSessions: session;
% output vis_line(session, "x-value"); % Session assignment for each activity
% array[1..nrActivity] of var 1..8: days;


% Constraint 1 -- schduling all events with specific sequence of stages
constraint
    forall(i in 1..nrActivity-1 where activity[i].event == activity[i+1].event /\ activity[i].stageNr < activity[i+1].stageNr) (
        session[i] <= session[i+1]
    );

% constraint 2 --  resources usage under 240 
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
      count_finals <= 4 /\ count_finals >= 1
  );

% Optional: balancing activities in session:

constraint
  forall(j in 1..nrSessions) (
        count_eq(session, j) >= 8 /\ count_eq(session, j) <= 9
     )
;


% Constraint 4 -- Athlete capacity in each session
constraint
    forall(s in 1..nrSessions) (
        let {
           var int: capacity = sum(i in 1..nrActivity where session[i] == s) (activity[i].participants)}
            in
            capacity <= 250
    );
    
    
% constraint 5  -- control over the temporal ordering of the events.
    
    
constraint
forall(p in 1..nrPrecedences) (
  let{
   var int: before_index = session[precedences[p].beforeNr];
   var int: after_index = session[precedences[p].afterNr]
   } in 
    if  precedences[p].temporalRelation == "Same" then before_index == after_index
    elseif  precedences[p].temporalRelation == "PreviousSession" then after_index - 1== before_index
    elseif  precedences[p].temporalRelation == "Yesterday" then (after_index + 1)div 2 - 1  == (before_index + 1)div 2
    elseif  precedences[p].temporalRelation == "DayBeforeYesterday" then (after_index + 1)div 2 - 2  == (before_index + 1)div 2
    elseif  precedences[p].temporalRelation == "ThreeDays" then (after_index + 1)div 2 - 3  == (before_index + 1)div 2
    
    else true
    endif
      );
      
     
      
  
         
% % contraint 6: conflict constraint


constraint
    forall(c in 1..nrConflicts) (
        forall(i in 1..nrActivity-1, j in 1..nrActivity-1 where activity[i].event == conflicts[c].event1 /\ activity[j].event == conflicts[c].event2)
        (session[i] != session[j]
        )
        );
        
        

%  maximize

array[1..nrSessions] of int: session_profit_indexing = [2, 3, 2, 3, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 2, 3];


% create array for visualization
          
array[1..nrActivity] of int: y_axis = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134];
        
 

    
solve maximize sum(i in 1..nrActivity where activity[i].finals==1)(session_profit_indexing[session[i]]);


output vis_line(_objective, "test vis");

output vis_scatter(session, y_axis, "sessions", "activities");



% constraint for precwedence using days and sessions
% constraint
% forall(p in 1..nrPrecedences) (
%   let{
%    var int: before_index = session[precedences[p].beforeNr];
%    var int: after_index = session[precedences[p].afterNr] } in 
%     if  precedences[p].temporalRelation == "same" then before_index == after_index
%     elseif  precedences[p].temporalRelation == "PreviousSession" then after_index - 1== before_index
%     elseif  precedences[p].temporalRelation == "Yesterday" then (after_index + 1)div 2 - 1  == (before_index + 1)div 2
%     elseif  precedences[p].temporalRelation == "DayBeforeYesterday" then (after_index + 1)div 2 - 2  == (before_index + 1)div 2
%     elseif  precedences[p].temporalRelation == "ThreeDays" then (after_index + 1)div 2 - 3  == (before_index + 1)div 2
    
%     else true
%     endif
%       );
      

% day and session constraint      
                  
% constraint
% forall(i in 1..nrActivity) (
%      session[i] >= 2*days[i]- 1 /\ session[i] <= 2*days[i]
    
%       ); 


    

