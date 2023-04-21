// SPDX-License-Identifier: MIT
pragma solidity ^0.8;


contract CauseContract {

    // admin address
    address payable admin;

    // contract address
    address payable contractAddress;

    // charityx wallet address
    address payable charityx;
    uint256 feePercent = 1;

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

        incoming.push(Transaction(msg.sender, msg.value * (100 - feePercent) / 100, block.timestamp, block.number, tx.gasprice, 2));

        charityx.transfer(msg.value * feePercent / 100);
    }

    function withdraw(uint256 _amount) public payable onlyAdmin {
        require(address(this).balance > _amount, "There is no Ether to withdraw");
        outgoing.push(Transaction(msg.sender, _amount, block.timestamp, block.number, tx.gasprice, 2));

        // use the transfer method to transfer the amount to the admin's address
        (bool success, ) = admin.call{value: _amount}("");
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