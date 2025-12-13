% =========================================================
% taxi_direct.lp
% Version optimizada: Usa move(T,D) directamente sin traduccion.
% =========================================================

% --- 1. DEFINICIONES ESTATICAS (BASE) ---
#program base.

% Definimos la relacion entre LETRA y COORDENADAS
dir(u, -1, 0). 
dir(d,  1, 0). 
dir(l,  0, -1). 
dir(r,  0,  1). 

% Helper: Adyacencia
% Calculamos la siguiente casilla basandonos en los numeros (DR, DC)
adj(R, C, DR, DC, R+DR, C+DC) :- 
    _cell(R, C),_dir(D, DR, DC), _cell(R+DR, C+DC), not _building(R+DR, C+DC).

% =========================================================
% PROGRAMA INICIAL (t=0)
% =========================================================
#program initial.

at(T, R, C) :- _taxi_pos(T, R, C).
passenger_at(P, R, C) :- _passenger_pos(P, R, C).
free(T) :- _taxi(T).

% =========================================================
% PROGRAMA DINAMICO (t > 0)
% =========================================================
#program dynamic.

% 1. GENERACION DE ACCIONES (DIRECTA)
% Generamos directamente move, pick, drop o wait.
% Usamos _dir(D,_,_) para obtener las letras u,d,l,r disponibles.
1 { 
    move(T, D) : _dir(D, _, _); 
    pick(T); 
    drop(T); 
    wait(T) 
} 1 :- _taxi(T).

% 2. FISICA DEL MOVIMIENTO
% Si me muevo en direccion D, busco sus coordenadas DR, DC y calculo destino
at(T, R2, C2) :- 
    'at(T, R, C), 
    move(T, D),           % Accion: Moverse en direccion D (ej: 'r')
    _dir(D, DR, DC),      % Traducir D a numeros (ej: 'r' -> 0, 1)
    _adj(R, C, DR, DC, R2, C2). % Calcular adyacencia valida

% Inercia de Posicion (Si NO hay accion move, me quedo)
at(T, R, C) :- 
    'at(T, R, C), 
    not move(T, _). 

% 3. RECOGER (PICK)
inside(P, T) :-
    pick(T),              % Accion directa
    'at(T, R, C),
    'passenger_at(P, R, C),
    'free(T).

% 4. DEJAR (DROP)
passenger_at(P, R, C) :-
    drop(T),              % Accion directa
    'at(T, R, C),
    'inside(P, T).

free(T) :- 
    drop(T), 
    'inside(P, T).

% 5. INERCIAS DE ESTADO
% Pasajero dentro sigue dentro
inside(P, T) :- 'inside(P, T), not drop(T).

% Pasajero fuera sigue fuera (si no es recogido)
picked_now(P) :- pick(T), 'at(T,R,C), 'passenger_at(P,R,C), 'free(T).
passenger_at(P, R, C) :- 'passenger_at(P, R, C), not picked_now(P).

% Taxi libre sigue libre
free(T) :- 'free(T), not pick(T).

% 6. RESTRICCIONES
:- at(T1, R, C), at(T2, R, C), T1 < T2. 
:- passenger_at(P1, R, C), passenger_at(P2, R, C), P1 < P2. 
occupied(T) :- inside(_, T).
:- passenger_at(P, R, C), at(T, R, C), occupied(T).
:- at(T1, R1, C1), at(T2, R2, C2), 'at(T1, R2, C2), 'at(T2, R1, C1), T1 < T2.

% =========================================================
% PROGRAMA FINAL (Objetivo)
% =========================================================
#program final.

delivered(P) :- passenger_at(P, R, C), _station(R, C), not inside(P, _).
goal :- #count { P : _passenger(P), not delivered(P) } == 0.

:- not _passenger(_). 
:- not goal.

% =========================================================
% VISUALIZACION
% Ya no hace falta traduccion, porque los predicados ya son los correctos.
% =========================================================
#show. 
#show move/2.
#show pick/1.
#show drop/1.
#show wait/1.