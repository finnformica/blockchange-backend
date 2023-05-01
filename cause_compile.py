from web3 import Web3
from solcx import compile_files, compile_source
import json
import os

LOCAL_URL = "http://127.0.0.1:8545"

# for Ganache:
w3 = Web3(Web3.HTTPProvider(LOCAL_URL))

w3.eth.default_account = w3.eth.accounts[0]

print(f"Connected to Ganache: {w3.is_connected()}")
print(f"Default account: {w3.eth.accounts[0]}")

# compile contract
contract_name = "CauseFactory.sol"
compile = compile_files([contract_name], output_values=["abi", "bin"])
abi = list(compile.values())[0]["abi"]
bin = list(compile.values())[0]["bin"]

# instantiate contract
ContractFactory = w3.eth.contract(abi=abi, bytecode=bin)

# deploy contract
tx_hash = ContractFactory.constructor().transact()
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
deployed_contract = w3.eth.contract(address=tx_receipt.contractAddress, abi=abi)

with open("../constants/contractInfo.json", "w") as file:
    contract_info = {"abi": abi, "address": tx_receipt.contractAddress}
    json.dump(contract_info, file)
    print("Contract info saved successfully")


print("Contract deployed at:", tx_receipt.contractAddress)