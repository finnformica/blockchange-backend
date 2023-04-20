// SPDX-License-Identifier: MIT
pragma solidity ^0.8;


contract CauseContract {

    // admin address
    address payable admin;

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
        address admin;
        Transaction[] incoming;
        Transaction[] outgoing;
    }

    constructor(string memory _id) {
        admin = payable(msg.sender);
        id = _id;
    }

    function retrieveInfo() public view returns (ContractInfo memory) {
        return ContractInfo(id, admin, incoming, outgoing);
    }

    function donate() public payable {
        require(msg.value > 0, "You must send some Ether");
        incoming.push(Transaction(msg.sender, msg.value));
    }

    function withdraw() public payable onlyAdmin {
        require(address(this).balance > 0, "There is no Ether to withdraw");
        outgoing.push(Transaction(msg.sender, address(this).balance));
        admin.transfer(address(this).balance);
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