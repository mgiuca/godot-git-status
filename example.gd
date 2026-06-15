extends Control

@onready var lbl_version : Label = $VBoxContainer/LblVersion
@onready var lbl_git_hash : Label = $VBoxContainer/LblGitHash

func _ready() -> void:
  # Display the version number and git hash in the corner of the screen.
  # HINT: In a real project, you would probably make this text really small with
  # no words, and show it in the corner of your menu or something.
  lbl_version.text = 'Version number: %s' % get_version_number()
  lbl_git_hash.text = 'Git hash: %s' % GitStatus.get_hash_string()

static func get_version_number() -> String:
  # Get the version number from the project settings.
  return ProjectSettings.get_setting('application/config/version')
