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

    function cfRetrieveInfo(string[] memory _ids) public view returns (CauseContract.ContractInfo[] memory) {
        CauseContract.ContractInfo[] memory infos = new CauseContract.ContractInfo[](_ids.length);
        for (uint i = 0; i < _ids.length; i++) {
            infos[i] = deployedCauses[_ids[i]].retrieveInfo();
        }
        return infos;
    }

    function cfRetrieveIds() public view returns (string[] memory) {
        return ids;
    }
}
