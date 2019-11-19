extends CanvasLayer

func _ready():
	play_transition()

func play_transition():
	$AnimationPlayer.play("come_into_picking_screen")