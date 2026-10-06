extends CanvasLayer

var score = 0

func increment_score():
	score += 1
	$Control/ScoreCounter.text = str(score)

func reset_score():
	score = 0
	$Control/ScoreCounter.text = str(score)
