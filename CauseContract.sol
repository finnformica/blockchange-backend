// SPDX-License-Identifier: MIT
pragma solidity ^0.8;


contract CauseContract {

    // admin address
    address payable owner;

    // human-readable contract id
    string id;

    constructor(string memory _id) {
        owner = payable(msg.sender);
        id = _id;
    }

    function retrieveInfo() public pure returns (string memory) {
        // not returning transaction information yet
        return "Hello World";
    }

    function donate() public payable {
        require(msg.value > 0, "You must send some Ether");
    }

    function withdraw() public payable {
        require(authenticateAdmin(), "You are not the owner of this contract");
        owner.transfer(address(this).balance);
    }

    function authenticateAdmin() public view returns (bool) {
        require(owner == msg.sender, "You are not the owner of this contract");
        return true;
    }
}