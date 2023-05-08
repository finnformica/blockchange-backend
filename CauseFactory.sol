// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./CauseContract.sol";

contract CauseFactory {

    // store all ids
    string[] public ids;

    // store all deployed causes
    mapping(string => CauseContract) public deployedCauses;

    function checkIfIdUnique(string memory _id) public view returns (bool) {
        return address(deployedCauses[_id]) == address(0);
    }

    function createCauseContract(string memory _id, string memory _name, string memory _description, string memory _websiteURL, string memory _thumbnailURL, string memory _email) public {
        require(checkIfIdUnique(_id), "ID already exists");
        address payable _admin = payable(msg.sender);

        CauseContract newCause = new CauseContract(_id, _name, _admin, _description, _websiteURL, _thumbnailURL, _email);
        deployedCauses[_id] = newCause;
        
        ids.push(_id);
    }

    function cfRetrieveInfo(string[] memory _ids) public view checkIfAllIdExists(_ids) returns (CauseContract.ContractInfo[] memory) {
        CauseContract.ContractInfo[] memory infos = new CauseContract.ContractInfo[](_ids.length);
        for (uint i = 0; i < _ids.length; i++) {
            infos[i] = deployedCauses[_ids[i]].retrieveInfo();
        }
        return infos;
    }

    function cfRetrieveIds(string memory id) public view checkIfIdExists(id) returns (string[] memory) {
        return ids;
    }

    modifier checkIfIdExists(string memory id) {
        bool idExists = false;
        for (uint i = 0; i < ids.length; i++) {
            if (keccak256(abi.encodePacked(ids[i])) == keccak256(abi.encodePacked(id))) {
                idExists = true;
                break;
            }
        }
        require(idExists, "ID does not exist");
        _;
    }

    modifier checkIfAllIdExists(string[] memory _ids) {
        for (uint i = 0; i < _ids.length; i++) {
            bool AllIdExists = false;
            for (uint j = 0; j < ids.length; j++) {
                if (keccak256(abi.encodePacked(ids[j])) == keccak256(abi.encodePacked(_ids[i]))) {
                    AllIdExists = true;
                    break;
                }
            }
            require(AllIdExists, "There are IDs that do not exist");
        }
        _;
    }

}
