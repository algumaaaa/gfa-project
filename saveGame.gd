extends Node

var map: int = 1
const FILE_LOC = "user://gore.save"
 

func saveGame(value: int) -> void:
	var saveFile = File.new()
	saveFile.open(FILE_LOC, File.WRITE)
	map = value
	saveFile.store_var(map)
	saveFile.close()


func loadGame() -> void:
	var loadFile = File.new()
	if !loadFile.file_exists(FILE_LOC):
		return
	loadFile.open(FILE_LOC, File.READ)
	map = loadFile.get_var()
	loadFile.close()
