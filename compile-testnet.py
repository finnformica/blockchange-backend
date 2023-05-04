from web3 import Web3
from solcx import compile_files
from dotenv import load_dotenv
import json
import os

load_dotenv()

INFURA_API_KEY = os.getenv("INFURA_API_KEY")
INFURA_URL = f"https://sepolia.infura.io/v3/{INFURA_API_KEY}"

METAMASK_SKEY = os.getenv("METAMASK_SKEY")

# for Ganache:
w3 = Web3(Web3.HTTPProvider(INFURA_URL))

# w3.eth.default_account = w3.eth.accounts[0]

print(w3.is_connected())

# get address
addr = w3.eth.account.from_key(METAMASK_SKEY).address
print(f"Metamask address: {addr}")

# compile contract
contract_name = "CoinFlip.sol"
compile = compile_files([contract_name], output_values=["abi", "bin"])
abi = list(compile.values())[0]["abi"]
bin = list(compile.values())[0]["bin"]

# instantiate contract
contract = w3.eth.contract(abi=abi, bytecode=bin)

# build transaction
build_tx = contract.constructor().build_transaction(
    {
        "from": addr,
        "nonce": w3.eth.get_transaction_count(addr),
        # "gas": 3000000,
        # "gasPrice": w3.toWei("3", "gwei"),
    }
)

# sign transaction
sign_tx = w3.eth.account.sign_transaction(build_tx, METAMASK_SKEY)

# deploy contract
tx_hash = w3.eth.send_raw_transaction(sign_tx.rawTransaction)
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
deployed_contract = w3.eth.contract(address=tx_receipt.contractAddress, abi=abi)

with open("../constants/contractInfo.json", "w") as file:
    contract_info = {"abi": abi, "address": tx_receipt.contractAddress}
    json.dump(contract_info, file)
    print("Contract info saved successfully")


print("Contract deployed at:", tx_receipt.contractAddress)
