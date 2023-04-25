// SPDX-License-Identifier: MIT
pragma solidity ^0.8;


contract CauseContract {

    // admin address
    address payable admin;

    // contract address
    address payable contractAddress;

    // blockchange wallet address
    address payable blockchange;

    // human-readable contract id
    string id;

    // transaction struct
    struct Transaction {
        address sender;
        uint256 amount;
        uint256 timestamp;
        uint256 blockNumber;
        uint256 gasUsed;
        uint256 transactionFee;
    }

    // incoming donations
    Transaction[] incoming;

    // outgoing funding
    Transaction[] outgoing;

    // contract information struct
    struct ContractInfo {
        string id;
        address admin;
        Transaction[] incoming;
        Transaction[] outgoing;
        address contractAddress;
    }

    uint256 constant BASIS_POINTS = 5; // move the basic points to its own variable
    uint256 constant DECIMALS = 1e18; // change the amount to amount * 1e18 in function (withdraw), unit: Wei-> ETH

    constructor(string memory _id) {
        admin = payable(msg.sender);
        contractAddress = payable(address(this));
        id = _id;
    }

    function retrieveInfo() public view returns (ContractInfo memory) {
        return ContractInfo(id, admin, incoming, outgoing, contractAddress);
    }


    function donate() public payable {
        require(msg.value > 0, "You must send some Ether");

        uint256 transactionFee = (msg.value * tx.gasprice * BASIS_POINTS) / 10000; // Transaction fee of 5bps (by default)
        incoming.push(Transaction(msg.sender, msg.value - transactionFee, block.timestamp, block.number, tx.gasprice, transactionFee));

        blockchange.transfer(transactionFee);
}

    function withdraw(uint256 _amount) public payable onlyAdmin {
        require(address(this).balance > _amount, "There is no Ether to withdraw");
        uint256 amount = _amount * DECIMALS;
        outgoing.push(Transaction(msg.sender, amount, block.timestamp, block.number, tx.gasprice, 2));

        // use the transfer method to transfer the amount to the admin's address
        (bool success, ) = admin.call{value: amount}("");
        require(success, "Withdrawal failed");
    }

    function authenticateAdmin() public view onlyAdmin returns (bool) {
        return true;
    }

    function updateAdmin(address _newAdmin) public onlyAdmin {
        admin = payable(_newAdmin);
    }

    modifier onlyAdmin() {
        require(admin == msg.sender, "You are not the admin of this contract");
        _;
    }
}