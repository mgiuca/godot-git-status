extends Control

@onready var lbl_version : Label = $VBoxContainer/LblVersion
@onready var lbl_git_hash : Label = $VBoxContainer/LblGitHash

func _ready() -> void:
  # Display the version number and git hash in the corner of the screen.
  # HINT: In a real project, you would probably make this text really small with
  # no words, and show it in the corner of your menu or something.
  lbl_version.text = 'Version number: %s' % get_version_number()
  lbl_git_hash.text = 'Git hash: %s' % get_git_hash()

static func get_version_number() -> String:
  # Get the version number from the project settings.
  return ProjectSettings.get_setting('application/config/version')

static func get_git_hash() -> String:
  # Get the git status object.
  var git_status : GitStatus.Info = GitStatus.get_status()

  # Turn it into a short user-readable string.
  if git_status.hash == '':
    # This can happen if the project has not been exported properly, or if
    # running in the editor and there is no git repo.
    return '(no git)'
  else:
    # This is the full 40-digit hash.
    var git_hash : String = git_status.hash
    # Just get the first 8 digits (plenty to uniquely identify the build).
    git_hash = git_hash.substr(0, 8)
    if git_status.modified:
      # This indicates that there are uncommitted changes in the repository,
      # which can mean the build does not properly represent the displayed hash.
      # Adding "+changes" makes it clear that this has happened. Builds
      # displaying "+changes" should not be released to users, because who knows
      # what is in them?
      git_hash += '+changes'
    return git_hash
