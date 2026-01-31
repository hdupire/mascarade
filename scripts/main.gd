extends Node

var current_scene : Node
var music_player: AudioStreamPlayer

func _ready() -> void:
        _setup_background_music()
        load_menu()

func _setup_background_music():
        music_player = AudioStreamPlayer.new()
        add_child(music_player)
        
        var music_path = ProjectSettings.globalize_path("res://assets/mp3/masquerade-ost.mp3")
        if FileAccess.file_exists(music_path):
                var file = FileAccess.open(music_path, FileAccess.READ)
                if file:
                        var data = file.get_buffer(file.get_length())
                        file.close()
                        var stream = AudioStreamMP3.new()
                        stream.data = data
                        stream.loop = true
                        music_player.stream = stream
                        music_player.play()
                        print("Background music started")

func load_menu() -> void:
        _change_scene("res://scenes/main-menu/main-menu.tscn")

func load_game() -> void:
        _change_scene("res://scenes/game/Mascarade.tscn")

func load_masks() -> void:
        _change_scene("res://scenes/masks-page/masks-page.tscn")

func load_powerups() -> void:
        _change_scene("res://scenes/powerup-page/powerup-page.tscn")

func load_settings() -> void:
        _change_scene("res://scenes/settings-page/settings-page.tscn")

func _change_scene(path) -> void:
        if current_scene:
                current_scene.queue_free()

        current_scene = load(path).instantiate()
        add_child(current_scene)
        
        if current_scene.has_signal("play_pressed"):
                current_scene.play_pressed.connect(load_game)
        
        if current_scene.has_signal("open_masks"):
                current_scene.open_masks.connect(load_masks)
        
        if current_scene.has_signal("open_powerups"):
                current_scene.open_powerups.connect(load_powerups)
        
        if current_scene.has_signal("open_settings"):
                current_scene.open_settings.connect(load_settings)
        
        if current_scene.has_signal("back_pressed"):
                current_scene.back_pressed.connect(load_menu)
