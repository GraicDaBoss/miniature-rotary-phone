# The Creature & The Bells  
AA26 Assignment — Grace C23320076

---

## What Is It?

This project is a glowing alien sea creature that inhabits a dark mysterious void and performs a scaled musical sequence every time it runs. The creature is nameless and mysterious by design — it drifts autonomously through its world, seeks out glowing bells placed by the player, and plays them in scale order (Scale in C). It's an impatient creature, who grows happy or frustrated depending on outcomes.

The concept was inspired by Harold Halibut, a game with a rich alien environment that feels genuinely inhabited. There's a small portion in this game in which bells and symbols are rang and the aliens react and I wanted to emulate this. I wanted something that felt like a smart instrument as well as a character with needs. It's an entity with its own internal logic that the player observes and composes around rather than directly controls.

---

## Controls

| Input      | Action                                           |
|------------|--------------------------------------------------|
| Left click | Place a bell at that position                    |
| Right click| Cycle to the next note (C D E F G A B) used for testing |
| R          | Clear all bells and reset the creature           |

---

## How The System Works

### The Creature

The creature is built from a chain of CSGSphere3D nodes driven by a SpineAnimator I got from the repo that calculates offsets between body segments on startup and updates them every physics frame. The result is a tail that lags behind the head and bends naturally as the creature turns, giving it a fluid, organic quality without any hand-keyed animation.

Movement is handled by CreatureController, which accumulates steering forces each frame, limits them by mass and max speed, and updates position directly, the same but different approach used in the base repo's boid system. The creature faces its direction of travel using a Basis.looking_at slerp to avoid the flipping that comes with direct rotation assignment.

---

### The Harmonic Scale System

The most original part of the project is HarmonicSystem. Rather than giving the creature free roam, it enforces a musical rule: bells must be collected in scale order. The system stores the pentatonic-extended major scale (C D E F G A B) as an ordered array. When the creature looks for its next target, get_next_note() finds the current note's index in the scale and returns the next one, going back to C after B.

CreatureBrain calls get_nearest_valid_bell() which filters the placed bells array to only those matching the required next note, then returns the closest one by distance. The creature also applies a steering avoidance force away from bells that are the wrong note, so it doesn't just ignore them it actively steers around them.

My initial method was a system in which the creature chose harmonically valid bells. There was a larger array of notes and at runtime a unique song was indeed played depending on which notes were placed and when, but this ended up creating a long script which used the same method as the major scale but just didn't sound as nice.

---

### The FSM

The creature's behaviour is managed by a Finite State Machine inherited from the base repo, with three custom states:

**WanderState** — picks random targets in the world and drifts toward them. Checks for nearby bells every frame and transitions to SeekBell when one is found.

**SeekBellState** — steers toward the target bell using an arrive force with a slowing radius. Validates the bell on arrival — rings it and transitions to Listen if correct, rejects it and returns to Wander if not.

**ListenState** — brings the creature to a gentle drift and waits for a duration calculated from its current energy level. Higher energy means shorter pauses — the creature gets more excited as the performance builds.

This follows the Single Responsibility Principle — each state owns only its own logic and communicates through the brain rather than reaching directly into other states. CreatureBrain acts as a shared data model, which keeps the states themselves clean and swappable.

---

### The Emotion System

CreatureBrain tracks a satisfaction value that decays slowly over time and restores when a bell is collected. This drives both the visual pulse in bodypulse.gd and the light colour. It's teal when happy, yellow when curious, red when upset or restless. The creature will stare at the player and approach the camera if it's annoyed. The pulse rate also increases with the creature's energy level, so visually it builds toward something as more bells are collected. The states depend on how many bells are placed, how many are correct and how many are played.

This is an example of the open closed principle. Adding a new emotion or visual response doesn't require modifying the FSM or controller, just reading from the brain's public API (is_angry(), is_happy() etc).

---

## What I Learned

The biggest technical challenge was getting steering physics to work with Godot's scene architecture. My first approach used CharacterBody3D with move_and_slide() which fought constantly against the custom velocity — gravity, floor normals and physics layers all interfered with what should have been simple vector math. Switching to a plain Node3D that updates global_position directly each frame, exactly like the base repo's boid system, solved it immediately. The lesson was to understand what the engine is doing before fighting it.

I also learned a lot about how FSMs interact with scene trees. The State base class uses get_parent() to find its state machine, which means the structure of the scene tree directly affects whether the code works — a small thing but it took a while to diagnose when states were reparented during restructuring.

The harmonic system was the most satisfying thing to write. It started as a chord compatibility table (any harmonically valid note can follow any other) and evolved into a strict scale sequence, which turned out to be both simpler to implement and more musically interesting — the creature always plays a recognisable rising scale, just in a different rhythm and path depending on where the bells are.

---

## What I Would Add With More Time

- Bells that are dynamic and offer unique musical simulation on runtime.
- A second creature with a different scale (minor or pentatonic) that performs simultaneously, creating two interweaving melodies
- XR support — the void environment and floating bells would translate well to a VR experience

---

## References & Sources

- Base repo forked from skooter500/miniature-rotary-phone — SpineAnimator, StateMachine, State, NoiseWander, steering behaviours  
- Bell sound: Singing Bowl Single Strike by S-Light on freesound.org — CC0 licence  
- Harold Halibut (2024, Slow Bros.) — visual and conceptual inspiration  
- Godot 4 documentation — CharacterBody3D motion modes, Basis.looking_at, GPUParticles3D
