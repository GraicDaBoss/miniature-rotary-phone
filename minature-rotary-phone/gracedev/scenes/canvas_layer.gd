extends CanvasLayer

@export var bell_spawner: bellSpawner

var brain: CreatureBrain
var note_names = {
	Bell.Note.C: "C  (Do)",
	Bell.Note.D: "D  (Re)",
	Bell.Note.E: "E  (Mi)",
	Bell.Note.F: "F  (Fa)",
	Bell.Note.G: "G  (Sol)",
	Bell.Note.A: "A  (La)",
	Bell.Note.B: "B  (Ti)",
}

@onready var note_label = $NoteLabel
@onready var mood_label = $MoodLabel

func _ready():
	brain = get_tree().get_first_node_in_group("brain")

func _process(_delta):
	if not brain:
		return
	if not brain.harmonic_system:
		return

	var next = brain.harmonic_system.get_next_note(brain.last_note)
	note_label.text = "  Next:  " + note_names[next]

	var mood = brain.get_emotion_state()
	match mood:
		"happy":
			mood_label.text = "Mood:  Happy ✦"
			mood_label.modulate = Color(0.1, 0.9, 0.8)
		"curious":
			mood_label.text = "Mood:  Curious ?"
			mood_label.modulate = Color(0.9, 0.85, 0.1)
		"angry":
			mood_label.text = "Mood:  Restless ✕"
			mood_label.modulate = Color(1.0, 0.2, 0.1)
