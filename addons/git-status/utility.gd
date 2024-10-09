extends Node

## Gets the current git hash. Only available if the project was exported.
## If the hash is not available, returns the empty string.
func get_hash() -> String:
  var file = FileAccess.open('res://git-hash.txt', FileAccess.READ)
  if file == null:
    return ''
  return file.get_as_text()
