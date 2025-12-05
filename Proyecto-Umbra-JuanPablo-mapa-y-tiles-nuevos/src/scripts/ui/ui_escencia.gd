extends CanvasLayer


@onready var escence_container: HBoxContainer = $HBoxContainer

func actualizar_escencia(escencia_actual: int)->void:
	#Para modificar la cantidad de escencia que tiene el personaje
	for i in range(escence_container.get_child_count()):
		var escencia = escence_container.get_child(i)
		escencia.visible = i < escencia_actual
