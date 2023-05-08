from web3 import Web3
from solcx import compile_files
import json

LOCAL_URL = "http://127.0.0.1:8545"

# for Ganache:
w3 = Web3(Web3.HTTPProvider(LOCAL_URL))

w3.eth.default_account = w3.eth.accounts[0]

print(f"Connected to Ganache: {w3.is_connected()}")
print(f"Default account: {w3.eth.accounts[0]}\n")

# compile contract
contract_name = "CauseFactory.sol"
compile = compile_files([contract_name], output_values=["abi", "bin"])

factory_compile = compile["CauseFactory.sol:CauseFactory"]
contract_compile = compile["CauseContract.sol:CauseContract"]

factory_abi = factory_compile["abi"]
factory_bin = factory_compile["bin"]

contract_abi = contract_compile["abi"]
contract_bin = contract_compile["bin"]

# instantiate ContractFactory
ContractFactory = w3.eth.contract(abi=factory_abi, bytecode=factory_bin)

# deploy ContractFactory
tx_hash = ContractFactory.constructor().transact()

# deploy contract
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
contract_factory_deployed = w3.eth.contract(
    address=tx_receipt.contractAddress, abi=factory_abi
)

with open("../constants/contractInfo.json", "w") as file:
    contract_info = {
        "factory_abi": factory_abi,
        "factory_address": tx_receipt.contractAddress,
        "contract_abi": contract_abi,
    }
    json.dump(contract_info, file)
    print("Contract factory info saved successfully")


print("Contract factory deployed at:", tx_receipt.contractAddress)

# load sample cause data
with open("sample-causes.json") as file:
    causes = json.load(file)

# deploy sample CauseContracts
for cause in causes:
    tx_hash = contract_factory_deployed.functions.createCauseContract(
        cause["id"],
        cause["title"],
        cause["desc"],
        "",
        cause["image_url"],
        cause["email"],
    ).transact()

    tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)

    # success = 1, error = 0
    print("\nStatus:", "success" if tx_receipt.status else "error")
    print("Cause contract deployed by:", tx_receipt["from"])
    print("Tx hash:", tx_receipt.transactionHash.hex())


# retrieve all deployed CauseContract ids
ids = contract_factory_deployed.functions.cfRetrieveIds().call()
print("\nCause ids:", ids)

# retrieve info from first CauseContract
info = contract_factory_deployed.functions.cfRetrieveInfo(ids[:1]).call()
print("\nCause info:", json.dumps(info, indent=4))
