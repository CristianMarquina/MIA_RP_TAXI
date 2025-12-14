# Taxi Routing Problem - Telingo Solution

## Overview

This project solves the **Taxi Routing Problem** using **Telingo**, a temporal logic programming system built on top of ASP (Answer Set Programming). The goal is to plan the movements of multiple taxis to pick up and deliver passengers to designated stations, respecting constraints such as avoiding buildings, preventing taxi collisions, and managing passenger-taxi interactions.

## Program Description: taxi5_CristianMarquina_JoseBordon.lp

The `taxi5_CristianMarquina_JoseBordon.lp` file contains the core temporal logic program that encodes the taxi routing problem:

### Key Components:

1. **Direction Definitions**
   ```prolog
   direction(-1, 0).  % up
   direction(1, 0).   % down
   direction(0, -1).  % left
   direction(0, 1).   % right
   ```

2. **Initial State Program (#program initial)**
   - Defines the starting positions of taxis and passengers
   - Marks all taxis as free (not carrying passengers)

3. **Dynamic Program (#program dynamic)**
   - **Action Generation:** Each taxi must perform exactly one action per time step
   - **Movement:** Taxis can move in valid directions (not through buildings)
   - **Pickup:** A taxi can pick up a passenger if they're at the same location and the taxi is free
   - **Dropoff:** A taxi can drop off a passenger at any location (ideally at stations)
   - **Inertia rules:** States persist unless changed by actions

4. **Constraints**
   - No taxi collisions (two taxis cannot be in the same cell)
   - No passenger collisions (two passengers cannot be in the same cell)
   - No driving through buildings
   - Passengers cannot share a cell with an occupied taxi
   - Taxis must stay within the grid boundaries

5. **Goal**
   - All passengers must be delivered to stations
   - A passenger is "delivered" when at a station cell and not inside a taxi

## Important Modification to drawtaxi.py

The visualization script was modified with one critical fix:

**Added line (116):**
```python
if len(words)==0: continue
```

**Why it's needed:**
- The solution file from Telingo may contain empty lines between states
- Without this check, the parser would crash when trying to process empty lines
- This line skips empty lines, allowing smooth parsing of the solution file



## Project Structure

```
MIA_RP_TAXI/
├── CristianMarquina-JoseCarlosBordon_Report.pdf              #Report 
├── README.md                                                 # This file
├── extaxi/                                                   # Domain files and solutions
│   ├── dom01.txt - dom10.txt                                 # Input domain files 
│   ├── encode.py                                              # Encoder script
│   ├── sol01.txt - sol10.txt                                  # Reference solutions
│   └── README.md
├── src/                                                    # Source code for solving
│   ├── taxi5_CristianMarquina_JoseBordon.lp                # Main Telingo program (SOLUTION)
│   ├── facts/
│   │   └── domain.lp                                       # Generated facts from domain file
│   ├── drawtaxi_CristianMarquina_JoseBordon.py             # Visualization script
│   ├── picstaxi/                                           # Image assets for visualization
│   └── encode_CristianMarquina_JoseBordon.py               # Encoder script (copy)
```

## How to Use - Step by Step

### Step 1: Encode the Input Domain

Convert an ASCII domain file into logic programming facts.

**Command:**
```bash
cd extaxi
python encode_CristianMarquina_JoseBordon.py dom01.txt dom01.lp
```

**What it does:**
- Reads the ASCII grid from `dom01.txt`
- Generates a logic program file `dom01.lp` containing facts:
  - `cell(Row, Col)` - valid cells in the grid
  - `building(Row, Col)` - building obstacles
  - `station(Row, Col)` - delivery destinations
  - `taxi(ID)` and `taxi_pos(ID, Row, Col)` - taxi initial positions
  - `passenger(ID)` and `passenger_pos(ID, Row, Col)` - passenger initial positions

**Example input format (dom01.txt):**
```
....a.b..
.#######X
1#..X..#.
......2..
```

Where:
- `.` = empty cell
- `#` = building/obstacle
- `X` = station (delivery point)
- `a-z` = passengers
- `1-9` = taxis

**Example output (dom01.lp):**
```prolog
cell(0,0). cell(0,1). ... % all valid cells
building(1,1). building(1,2). ... % building locations
station(1,8). station(2,4). % delivery stations
taxi(1). taxi_pos(1, 2, 0).
taxi(2). taxi_pos(2, 2, 6).
passenger(a). passenger_pos(a, 0, 4).
passenger(b). passenger_pos(b, 0, 6).
```

### Step 2: Generate the Solution Plan

Use Telingo to compute a valid plan that delivers all passengers.

**Setup:** Copy the generated facts file to the source directory:
```bash
cp dom01.lp ../src/facts/domain.lp
```

**Command (in src/ directory):**
```bash
cd ../src
telingo taxi5_CristianMarquina_JoseBordon.lp facts/domain.lp  > sol01.txt
```

**Parameters explained:**
- `taxi5_CristianMarquina_JoseBordon.lp` - Main program (temporal logic encoding of taxi routing)
- `facts/domain.lp` - Generated facts from Step 1
- `--imax=20` - Maximum search depth (20 time steps)
- `> sol01.txt` - Redirect output to solution file

**What happens:**
- Telingo searches for a valid plan
- Generates action sequences for each taxi:
  - `move(T, Direction)` - taxi T moves up/down/left/right
  - `pick(T)` - taxi T picks up a passenger at current location
  - `drop(T)` - taxi T drops off a passenger at current location
  - `wait(T)` - taxi T waits (does nothing)

**Example output (sol01.txt):**
```
Answer: 1
State 0:
State 1:
 do(1,move(1,0)) do(2,move(-1,0))
State 2:
 do(1,move(0,1)) do(2,move(0,-1))
State 3:
 do(1,pick) do(2,move(0,-1))
...
```

### Step 3: Visualize the Solution

Use the visualization script to see the solution graphically.

**Prerequisite:** Install pygame
```bash
pip install pygame
```

**Command:**
```bash
python drawtax_CristianMarquina_JoseBordon.py dom01.txt sol01.txt
```

**Parameters:**
- `dom01.txt` - Original domain file (ASCII grid)
- `sol01.txt` - Solution file from Telingo

**Example with custom delay:**
```bash
python drawtaxi.py dom01.txt sol01.txt 500
```

**Visualization features:**
- Shows the grid with buildings, taxis, and passengers
- Taxis are displayed with numbers (1, 2, etc.)
- Passengers are shown as letters (a, b, etc.)
- Stations are highlighted in yellow
- Animates the solution step by step
- Each state shows one time step of the plan

