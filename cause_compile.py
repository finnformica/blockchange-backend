from web3 import Web3
from solcx import compile_files
import json
import os

LOCAL_URL = "http://127.0.0.1:8545"

# for Ganache:
w3 = Web3(Web3.HTTPProvider(LOCAL_URL))

w3.eth.default_account = w3.eth.accounts[0]

print(f"Connected to Ganache: {w3.isConnected()}")
print(f"Default account: {w3.eth.accounts[0]}")

# compile contract
contract_name = "CauseFactory.sol"
compile = compile_files([contract_name], output_values=["abi", "bin"])
abi = list(compile.values())[0]["abi"]
bin = list(compile.values())[0]["bin"]

# instantiate contract factory
ContractFactory = w3.eth.contract(abi=abi, bytecode=bin)


# compile cause contract
contract_name = "CauseContract.sol"
compile = compile_files([contract_name], output_values=["abi", "bin"])
abi = list(compile.values())[0]["abi"]
bin = list(compile.values())[0]["bin"]

CauseContract = w3.eth.contract(abi=abi, bytecode=bin)


# count how many parameters are required to deploy cause contract from contract factory
constructor_abi = next(item for item in abi if item["type"] == "constructor")
num_args = len(constructor_abi["inputs"])

# Create a list of empty strings with the same length as the number of arguments
empty_args = [""] * num_args

# Deploy the ContractFactory with the empty arguments
tx_hash = ContractFactory.constructor(*empty_args).transact()

# deploy contract
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
deployed_contract = w3.eth.contract(address=tx_receipt.contractAddress, abi=abi)

with open("../constants/contractInfo.json", "w") as file:
    contract_info = {"abi": abi, "address": tx_receipt.contractAddress}
    json.dump(contract_info, file)
    print("Contract info saved successfully")


print("Contract deployed at:", tx_receipt.contractAddress)
