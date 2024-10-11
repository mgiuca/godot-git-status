@tool
extends EditorExportPlugin

func _get_name() -> String:
  return 'GitStatus'

func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
  var git_hash : String
  git_hash = preload('utility.gd').new().read_hash_from_git()
  if git_hash.length() > 0:
    print('Exporting with git hash: %s' % git_hash)
    add_file('res://git-hash.txt', git_hash.to_ascii_buffer(), false)
  else:
    print('Exporting without git hash')
