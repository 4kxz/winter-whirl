class_name LeaderBoard extends Node

var game_API_key = ""
var development_mode = true
var leaderboard_key = "leaderboard-1"
var session_token = ""

var label: Label
var best_time: float

var auth_http: HTTPRequest
var leaderboard_http: HTTPRequest
var submit_score_http: HTTPRequest
var set_name_http: HTTPRequest
var get_name_http: HTTPRequest


func _ready():
	_authentication_request()


func _authentication_request():
	# Check if a player session exists
	var player_session_exists = false
	var player_identifier : String
	var file = FileAccess.open("user://LootLocker.data", FileAccess.READ)
	if file != null:
		player_identifier = file.get_as_text()
		print("player ID="+player_identifier)
		file.close()
 
	if player_identifier != null and player_identifier.length() > 1:
		print("player session exists, id="+player_identifier)
		player_session_exists = true
	if(player_identifier.length() > 1):
		player_session_exists = true
		
	## Convert data to json string:
	var data = {
		"game_key": game_API_key,
		"game_version": "0.0.0.1",
		"development_mode": true,
	}
	
	# If a player session already exists, send with the player identifier
	if player_session_exists:
		data = {
			"game_key": game_API_key,
			"player_identifier": player_identifier,
			"game_version": "0.0.0.1",
			"development_mode": true,
		}
	
	# Add 'Content-Type' header:
	var headers = ["Content-Type: application/json"]
	
	# Create a HTTPRequest node for authentication
	auth_http = HTTPRequest.new()
	add_child(auth_http)
	auth_http.request_completed.connect(_on_authentication_request_completed)
	auth_http.request("https://api.lootlocker.io/game/v2/session/guest", headers, HTTPClient.METHOD_POST, JSON.stringify(data))
	
	print("Authentication data")
	print(data)


func _on_authentication_request_completed(_result, _response_code, _headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	
	# Save the player_identifier to file
	var file = FileAccess.open("user://LootLocker.data", FileAccess.WRITE)
	var data = json.get_data()
	file.store_string(data["player_identifier"])
	file.close()
	
	# Save session_token to memory
	session_token = data["session_token"]
	
	# Print server response
	print("Authentication response")
	print(json.get_data())
	
	# Get leaderboards
	_update_leaderboards()
	auth_http.queue_free()


func _update_leaderboards():
	print("Getting leaderboards")
	var url = "https://api.lootlocker.io/game/leaderboards/"+leaderboard_key+"/list?count=10"
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	
	# Create a request node for getting the highscore
	leaderboard_http = HTTPRequest.new()
	add_child(leaderboard_http)
	leaderboard_http.request_completed.connect(_on_leaderboard_request_completed)
	
	# Send request
	leaderboard_http.request(url, headers, HTTPClient.METHOD_GET, "")


func _on_leaderboard_request_completed(_result, _response_code, _headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	
	# Formatting as a leaderboard
	var leaderboardFormatted = ""
	var data = json.get_data()
	var items = data["items"]
	if items:
		for n in items.size():
			var i = items[n]
			var score = _format_time(float(i.score) / 1000)
			leaderboardFormatted += "%s. %s - %s\n" % [i.rank, i.player.name, score]
	label.text = leaderboardFormatted
	
	# Clear node
	leaderboard_http.queue_free()


func upload_score():
	var data = { "score": str(best_time * 1000) }
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	submit_score_http = HTTPRequest.new()
	add_child(submit_score_http)
	submit_score_http.request_completed.connect(_on_upload_score_request_completed)
	# Send request
	submit_score_http.request("https://api.lootlocker.io/game/leaderboards/"+leaderboard_key+"/submit", headers, HTTPClient.METHOD_POST, JSON.stringify(data))
	
	print("Upload score data")
	print(data)


func _on_upload_score_request_completed(_result, _response_code, _headers, body) :
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	
	# Print data
	print(json.get_data())
	
	# Clear node
	submit_score_http.queue_free()
	
	_update_leaderboards()


func change_player_name(player_name: String):
	print("Changing player name")
	
	var data = { "name": str(player_name) }
	var url =  "https://api.lootlocker.io/game/player/name"
	var headers = ["Content-Type: application/json", "x-session-token:" + session_token]
	
	# Create a request node for getting the highscore
	set_name_http = HTTPRequest.new()
	add_child(set_name_http)
	set_name_http.request_completed.connect(_on_player_set_name_request_completed)
	# Send request
	set_name_http.request(url, headers, HTTPClient.METHOD_PATCH, JSON.stringify(data))


func _on_player_set_name_request_completed(_result, _response_code, _headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	
	# Print data
	print("Set name response")
	print(json.get_data())
	
	set_name_http.queue_free()


func get_player_name():
	print("Getting player name")
	var url = "https://api.lootlocker.io/game/player/name"
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	
	# Create a request node for getting the highscore
	get_name_http = HTTPRequest.new()
	add_child(get_name_http)
	get_name_http.request_completed.connect(_on_player_get_name_request_completed)
	# Send request
	get_name_http.request(url, headers, HTTPClient.METHOD_GET, "")


func _on_player_get_name_request_completed(_result, _response_code, _headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	
	print("Get name response")
	print(json.get_data())


func _format_time(time) -> String:
	var minutes = int(time / 60)
	var seconds = int(time) % 60
	var milliseconds = int((time - int(time)) * 100)
	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]
