#program base.

% Define the direction letters and their corresponding row and column changes
dir(u, -1, 0). 
dir(d,  1, 0). 
dir(l,  0, -1). 
dir(r,  0,  1). 

% Helper: adjacency predicate
adj(R, C, DR, DC, R+DR, C+DC) :- 
    _cell(R, C),_dir(D, DR, DC), _cell(R+DR, C+DC), not _building(R+DR, C+DC).

% t = 0
#program initial.

at(T, R, C) :- _taxi_pos(T, R, C).
passenger_at(P, R, C) :- _passenger_pos(P, R, C).
free(T) :- _taxi(T).

% t > 0
#program dynamic.


% Choice rule: one move per taxi per step
1 { 
    move(T, D) : _dir(D, _, _); 
    pick(T); 
    drop(T); 
    wait(T) 
} 1 :- _taxi(T).


% Movement effect
at(T, R2, C2) :- 
    'at(T, R, C), 
    move(T, D),           
    _dir(D, DR, DC),      
    _adj(R, C, DR, DC, R2, C2). % calculate next position

% Stay rule for position
at(T, R, C) :- 
    'at(T, R, C), 
    not move(T, _). 

% Rule to pick up 
inside(P, T) :-
    pick(T),              % Action
    'at(T, R, C),
    'passenger_at(P, R, C),
    'free(T).

% Rule to drop off 
passenger_at(P, R, C) :-
    drop(T),              % Action
    'at(T, R, C),
    'inside(P, T).

% Rule to free taxi after drop
free(T) :- 
    drop(T), 
    'inside(P, T).

% passenger inside stays inside unless dropped
inside(P, T) :- 'inside(P, T), not drop(T).

%aux predicate to identify newly picked passengers
picked_now(P) :- pick(T), 'at(T,R,C), 'passenger_at(P,R,C), 'free(T).
% passenger not picked now stays put
passenger_at(P, R, C) :- 'passenger_at(P, R, C), not picked_now(P).
% taxi not picking stays free
free(T) :- 'free(T), not pick(T).

% Constraints
% Cant be two taxis in the same cell at the same time
:- at(T1, R, C), at(T2, R, C), T1 < T2. 
% Cant be two passengers in the same cell
:- passenger_at(P1, R, C), passenger_at(P2, R, C), P1 < P2. 
% Taxi cannot pick up if already carrying someone
occupied(T) :- inside(_, T).
:- passenger_at(P, R, C), at(T, R, C), occupied(T).
% No swapping of taxis
:- at(T1, R1, C1), at(T2, R2, C2), 'at(T1, R2, C2), 'at(T2, R1, C1), T1 < T2.


% The final program
#program final.

% Goal: all passengers delivered
% A passenger is delivered if they are at a station and not inside any taxi
delivered(P) :- passenger_at(P, R, C), _station(R, C), not inside(P, _).
% The goal is achieved when all passengers are delivered
goal :- #count { P : _passenger(P), not delivered(P) } == 0.

:- not _passenger(_). 
:- not goal.


% Visualization 
#show. 
#show move/2.
#show pick/1.
#show drop/1.
#show wait/1.