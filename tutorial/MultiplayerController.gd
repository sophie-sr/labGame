extends Control

@export var Address = "127.0.0.1" #Might need to change in the future depending on things
@export var port = 8910
var peer

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	if "--server" in OS.get_cmdline_args():
		hostGame()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#this gets called on the server and clients
func peer_connected(id):
	print("player connected " + str(id))

#this gets called on the server and clients	
func peer_disconnected(id):
	print("player disconnected " + str(id))
	GameManager.Players.erase(id)
	var players = get_tree().get_nodes_in_group("Player")
	for i in players:
		if i.name == str(id):
			i.queue_free()

#called only from clients
func connected_to_server():
	print("connected to server")
	sendPlayerInformation.rpc_id(1, $LineEdit.text, multiplayer.get_unique_id())

#called only from clients
func connection_failed():
	print("connection failed")
	
@rpc("any_peer")
func sendPlayerInformation(name, id):
	if !GameManager.Players.has(id):
		GameManager.Players[id] = {
			"name": name, 
			"id": id,
			"score": 0
		}
	
	#if done on peer connected, everyone has to run peer connected on their on machine
	if multiplayer.is_server():
		for i in GameManager.Players:
			sendPlayerInformation.rpc(GameManager.Players[i].name , i)
	
@rpc("any_peer","call_local")
func StartGame():
	var scene = load("res://testScene.tscn").instantiate()
	get_tree().root.add_child(scene)
	
	#self.hide()   #For some reason in the tutorial they are hiding sself?
	
func hostGame():
	peer = ENetMultiplayerPeer.new()
	var maxPlayers = 2 #max of 32 players
	var error = peer.create_server(port, maxPlayers) #
	if error != OK:
		print("cannot host : " + str(error))
		return
	
	#Look at ENetConnection to change enumerations depending on the scenario
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting For Players!")

func _on_host_button_down():
	hostGame()
	sendPlayerInformation($LineEdit.text, multiplayer.get_unique_id())
	pass # Replace with function body.


func _on_join_button_down():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(Address, port)
	
	#Look at ENetConnection to change enumerations depending on the scenario
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	
	pass # Replace with function body.


func _on_start_game_button_down():
	#RPC remote procedure call
	StartGame.rpc()
	
	
	pass # Replace with function body.
