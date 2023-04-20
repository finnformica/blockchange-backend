// SPDX-License-Identifier: MIT
pragma solidity ^0.8;


contract CauseContract {

    // admin address
    address payable owner;

    // human-readable contract id
    string id;

    // transaction struct
    struct Transaction {
        address sender;
        uint amount;
    }

    // incoming donations
    Transaction[] incoming;

    // outgoing funding
    Transaction[] outgoing;

    // contract information struct
    struct ContractInfo {
        string id;
        address owner;
        Transaction[] incoming;
        Transaction[] outgoing;
    }

    constructor(string memory _id) {
        owner = payable(msg.sender);
        id = _id;
    }

    function retrieveInfo() public view returns (ContractInfo memory) {
        return ContractInfo(id, owner, incoming, outgoing);
    }

    function donate() public payable {
        require(msg.value > 0, "You must send some Ether");
        incoming.push(Transaction(msg.sender, msg.value));
    }

    function withdraw() public payable onlyAdmin {
        require(address(this).balance > 0, "There is no Ether to withdraw");
        outgoing.push(Transaction(msg.sender, address(this).balance));
        owner.transfer(address(this).balance);
    }

    function authenticateAdmin() public view onlyAdmin returns (bool) {
        return true;
    }

    modifier onlyAdmin() {
        require(owner == msg.sender, "You are not the owner of this contract");
        _;
    }
}