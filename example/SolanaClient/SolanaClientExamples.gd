extends VBoxContainer

const EXAMPLE_ACCOUNT := "4sGjMW1sUnHzSxGspuhpqLDx6wiyjNtZAMdL4VZHirAn"

const TOTAL_CASES := 8
var passed_test_mask := 0
		

func PASS(unique_identifier: int):
	passed_test_mask += (1 << unique_identifier)
	print("[OK]: ", unique_identifier)


func display_dict(data: Variant, parent: TreeItem):
	if typeof(data) == TYPE_STRING:
		parent.set_text(1, data)
	elif typeof(data) == TYPE_ARRAY:
		for i in range(data.size()):
			var subchild = parent.create_child()
			subchild.set_editable(1, true)
			subchild.set_text(0, str(i))
			display_dict(data[i], subchild)
	elif typeof(data) != TYPE_DICTIONARY:
		parent.set_text(1, str(data))
	else:
		var data_dict: Dictionary = data
		var keys = data_dict.keys()
		for key in keys:
			var subchild = parent.create_child()
			subchild.set_editable(1, true)
			subchild.set_text(0, key)
			display_dict(data_dict[key], subchild)


func add_solana_client() -> SolanaClient:
	var res = SolanaClient.new()
	
	# RPC HTTP URL is set in project settings.
	# You can override it by setting url_override property.

	# Solana Client needs to be in scene tree for async to work.
	add_child(res)
	
	return res

func delete_solana_client(client: SolanaClient):
	remove_child(client)

func get_account_info_demo():
	var client: SolanaClient = add_solana_client()
	client.get_account_info(EXAMPLE_ACCOUNT)
	var response: Dictionary = await client.http_response_received
	assert(response.has("result"))
	display_dict(response["result"], $ResultTree1.create_item())
	delete_solana_client(client)
	PASS(0)

func get_latest_blockhash_demo():
	var client: SolanaClient = add_solana_client()
	client.get_latest_blockhash()
	var response: Dictionary = await client.http_response_received
	assert(response.has("result"))
	display_dict(response["result"], $ResultTree2.create_item())
	delete_solana_client(client)
	PASS(1)
	
func get_minimum_balance_for_rent_extemption_demo():
	const EXAMPLE_DATA_SIZE := 100
	var client: SolanaClient = add_solana_client()
	client.get_minimum_balance_for_rent_extemption(EXAMPLE_DATA_SIZE)
	var response: Dictionary = await client.http_response_received
	assert(response.has("result"))
	display_dict(response["result"], $ResultTree3.create_item())
	delete_solana_client(client)
	PASS(2)


func subscribe_account_demo():
	var client: SolanaClient = add_solana_client()
	client.set_commitment("finalized")
	var account_callback := Callable(self, "_account_subscribe_callback")
	client.account_subscribe(EXAMPLE_ACCOUNT, account_callback)
	
	# Make lamports of the account change to trigger the callback.
	client.request_airdrop(EXAMPLE_ACCOUNT, 1000000)
	var airdrop_response = await client.http_response_received
	assert(airdrop_response.has("result"))
	var airdrop_signature: String = airdrop_response["result"]
	
	var signature_callback := Callable(self, "_signature_subscribe_callback")
	client.signature_subscribe(airdrop_signature, signature_callback, "finalized")
	
	# Keep the client node in the tree to keep it processing
	# You should call unsubscribe_all() when you are done.
	
	PASS(3)


func synchronous_client_call():
	# Same call to get account info but synchronous.
	var client = SolanaClient.new()
	var response = client.get_account_info(EXAMPLE_ACCOUNT)
	assert(response.has("result"))
	display_dict(response["result"], $ResultTree4.create_item())
	PASS(6)


func get_program_accounts_demo():
	const account = "CLUBHBUKuKxWmRpJkAZEWqadeu9A8FB5TdzzKRJiEdXq";
	var client: SolanaClient = add_solana_client()
	const filters = [
		{ 
			"memcmp" : {
		"offset": 0,
		"bytes": "FZFe",
		"encoding": "base64"
	}
		},
		{
			"dataSize": 592
		}
	]
	client.get_program_accounts(account, false, filters)
	
	var response : Dictionary = await client.http_response_received
	assert(response.has("result"))
	var accounts = response["result"]
	
	display_dict(accounts, $ResultTree5.create_item())
	delete_solana_client(client)
	PASS(7)


func _ready():
	get_account_info_demo()
	get_latest_blockhash_demo()
	get_minimum_balance_for_rent_extemption_demo()
	subscribe_account_demo()
	get_program_accounts_demo()
	synchronous_client_call()


func _account_subscribe_callback(_params):
	PASS(4)

func _signature_subscribe_callback(_params):
	PASS(5)

func _on_timeout_timeout():
	for i in range(TOTAL_CASES):
		if ((1 << i) & passed_test_mask) == 0:
			print("[FAIL]: ", i)

