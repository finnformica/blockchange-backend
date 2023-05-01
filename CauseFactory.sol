// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./CauseContract.sol";

contract CauseFactory {

    // store all deployed causes
    mapping(string => CauseContract) public deployedCauses;

    function checkIfIdUnique(string memory _id) public view returns (bool) {
        return address(deployedCauses[_id]) == address(0);
    }

    function createCauseContract(string memory _id) public {
        require(checkIfIdUnique(_id), "ID already exists");
        CauseContract newCause = new CauseContract(_id);
        deployedCauses[_id] = newCause;
    }

    function cfRetrieveInfo(string memory _id) public view returns (CauseContract.ContractInfo memory) {
        return deployedCauses[_id].retrieveInfo();
    }
}

