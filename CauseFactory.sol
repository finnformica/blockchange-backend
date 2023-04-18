// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./CauseContract.sol";

contract CauseFactory {

    mapping(string => CauseContract) public deployedCauses;

    function createCauseContract(string memory _id) public {
        CauseContract newCause = new CauseContract(_id);
        deployedCauses[_id] = newCause;
    }

    function getDeployedCauseFromId(string memory _id) public view returns (CauseContract) {
        return deployedCauses[_id];
    }
}