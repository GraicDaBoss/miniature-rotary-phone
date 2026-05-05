# The Creature & The Bells  
**AA26 Assignment — Grace C23320076**

---

## What Is It?

This project is a glowing alien sea creature that inhabits a dark, mysterious void and performs a scaled musical sequence every time it runs.

The creature is nameless and mysterious by design — it drifts autonomously through its world, seeks out glowing bells placed by the player, and plays them in scale order (Scale in C). It's an impatient creature, who grows happy or frustrated depending on outcomes.

The concept was inspired by *Harold Halibut*, a game with a rich alien environment that feels genuinely inhabited. There’s a small portion in this game in which bells and symbols are rung and the aliens react — this project emulates that idea.

The goal was to create something that feels like a smart instrument as well as a character with needs. It's an entity with its own internal logic that the player observes and composes around rather than directly controls.

---

## Controls

| Input       | Action                                      |
|------------|---------------------------------------------|
| Left Click | Place a bell at that position               |
| Right Click| Cycle to the next note (C D E F G A B)      |
| R          | Clear all bells and reset the creature      |

---

## How The System Works

### The Creature

The creature is built from a chain of `CSGSphere3D` nodes driven by a `SpineAnimator` (from the base repo). It calculates offsets between body segments on startup and updates them every physics frame.

This creates a tail that lags behind the head and bends naturally, giving it a fluid, organic quality without hand-keyed animation.

Movement is handled by `CreatureController`, which:
- Accumulates steering forces each frame  
- Limits them by mass and max speed  
- Updates position directly  

This is similar to the boid system in the base repo.

The creature faces its direction of travel using `Basis.looking_at` with `slerp` to avoid rotation flipping.

---

### The Harmonic Scale System

The core system is `HarmonicSystem`.

Instead of free movement, the creature follows a musical rule:  
**bells must be collected in scale order (C D E F G A B).**

- Notes are stored as an ordered array  
- `get_next_note()` returns the next note in sequence  
- Loops back to C after B  

`CreatureBrain`:
- Calls `get_nearest_valid_bell()`  
- Filters bells by the correct next note  
- Selects the closest valid bell  

The creature also:
- Applies avoidance steering away from incorrect notes  
- Actively steers around invalid bells instead of ignoring them  

#### Previous Approach

Originally, the system allowed any harmonically valid note using a larger array.  
While it produced unique sequences, it:
- Required more complex logic  
- Sounded less musically coherent  

Switching to a strict scale made it:
- Simpler  
- More predictable  
- More satisfying musically  

---

### The FSM (Finite State Machine)

The creature uses an FSM inherited from the base repo with three states:

#### WanderState
- Picks random targets  
- Drifts through the world  
- Checks for nearby bells  
- Transitions to `SeekBellState`

#### SeekBellState
- Moves toward a target bell using an arrive force  
- Slows within a radius  
- On arrival:
  - If correct → ring bell → go to `ListenState`  
  - If incorrect → return to `WanderState`

#### ListenState
- Slows to a gentle drift  
- Waits based on energy level  
- Higher energy = shorter pauses  

This follows the **Single Responsibility Principle**:
- Each state handles only its own logic  
- Communication happens through `CreatureBrain`  
- States remain modular and swappable  

---

### The Emotion System

`CreatureBrain` tracks a **satisfaction value**:

- Decreases over time  
- Increases when correct bells are collected  

This drives:
- Body pulse (`bodypulse.gd`)  
- Light colour  

#### Emotional States:
- **Teal** → Happy  
- **Yellow** → Curious  
- **Red** → Upset / Restless  

Behaviour changes:
- Approaches player when annoyed  
- Pulse rate increases with energy  
- Visual intensity builds as bells are collected  

This follows the **Open/Closed Principle**:
- New emotions can be added without modifying FSM logic  
- States read from `CreatureBrain` API (`is_happy()`, `is_angry()`, etc.)

---

## What I Learned

### Steering vs Engine Physics
Using `CharacterBody3D` with `move_and_slide()` caused conflicts:
- Gravity  
- Floor normals  
- Physics layers  

Switching to `Node3D` with direct `global_position` updates:
- Simplified movement  
- Matched the boid system  
- Solved control issues  

**Key lesson:** Understand the engine before fighting it.

---

### FSM and Scene Tree Structure

The `State` class uses `get_parent()` to locate the state machine.

This means:
- Scene hierarchy directly affects functionality  
- Reparenting nodes can break behaviour  

---

### Harmonic System Evolution

Started as:
- Chord compatibility system  

Evolved into:
- Strict scale sequence  

Result:
- Simpler implementation  
- More musically satisfying output  
- Predictable but still dynamic behaviour  

---

## What I Would Add With More Time

- Dynamic bells with runtime musical variation  
- A second creature using a different scale (minor/pentatonic)  
- XR / VR support for immersive interaction  

---

## References & Sources

- Base repo: `skooter500/miniature-rotary-phone`  
  - SpineAnimator  
  - StateMachine  
  - Steering behaviours  

- Bell sound: *Singing Bowl Single Strike* — S-Light (freesound.org, CC0)  

- *Harold Halibut* (2024, Slow Bros.) — inspiration  

- Godot 4 Documentation:  
  - `CharacterBody3D`  
  - `Basis.looking_at`  
  - `GPUParticles3D`  

---

