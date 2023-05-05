// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract CauseContract {

    // admin address
    address payable admin;

    // contract address
    address payable contractAddress;

    // blockChange wallet address
    address payable blockChange;

    // donation total tracker
    uint256 causeTotal;

    uint256 constant BASIS_POINTS = 50;
    
    // cause inputs
    string id;
    string name;
    string description;
    string websiteURL;
    string thumbnailURL;
    string email;
    
    // incoming donations
    Transaction[] incoming;

    // outgoing funding
    Transaction[] outgoing;

    // donor proportion tracking
    mapping(address => uint256) public donorTotals;
    
    mapping(address => bool) public addressDonated;

    // causeState flag -> 1 = False, 2 = True
    uint256 public causeState = 1;

    // contract information struct
    struct ContractInfo {
        string id;
        string name;
        address admin;
        Transaction[] incoming;
        Transaction[] outgoing;
        address contractAddress;
        uint256 causeTotal;
        uint256 causeState;
        string email;
        string description;
        string website;
        string thumbnail;
    }

    // transaction struct
    struct Transaction {
        address sender;
        uint256 amount;
        uint256 timestamp;
        uint256 blockNumber;
        uint256 gasUsed;
        uint256 transactionFee;
    }

    constructor(string memory _id, string memory _name, address payable _admin, string memory _description, string memory _websiteURL, string memory _thumbnailURL, string memory _email) {
        admin = _admin;
        contractAddress = payable(address(this));

        blockChange = payable(msg.sender);
        
        // initialise cause inputs
        id = _id;
        name = _name;
        description = _description;
        websiteURL = _websiteURL;
        thumbnailURL = _thumbnailURL;
        email = _email;
    }

    function retrieveInfo() public view returns (ContractInfo memory) {
        return ContractInfo(
            id, 
            name, 
            admin, 
            incoming, 
            outgoing, 
            contractAddress, 
            causeTotal, 
            causeState, 
            email, 
            description, websiteURL, thumbnailURL);
    }

    function donate() public payable{
        require(msg.value > 0, "You must send some Ether");
        require(causeState == 1, "This cause has ended, your funds have been returned");

        uint256 gasStart = gasleft();

        uint256 transactionFee = (msg.value*BASIS_POINTS) / 1000; // Transaction fee of 5bps (by default)
        
        (bool success, ) = blockChange.call{value: transactionFee}("");
        require(success, "Transfer failed.");

        uint256 gasUsed = gasStart - gasleft();
        uint256 gasPrice = tx.gasprice;
        uint256 gasFee = gasUsed * gasPrice;

         // update donor proportion
        donorTotals[msg.sender] += msg.value;

        //update causeTotal
        causeTotal += (msg.value - transactionFee);
        // causeStats(causeTotal);

        incoming.push(Transaction(msg.sender, msg.value - transactionFee, block.timestamp, block.number, gasFee, transactionFee));          
    }

    function withdraw(uint256 _amount) public payable onlyAdmin {
        require(address(this).balance > _amount, "Insufficient funds for withdrawal");
        
        uint256 gasStart = gasleft();
        


        // use the transfer method to transfer the amount to the admin's address
        (bool success, ) = admin.call{value: _amount}("");
        require(success, "Withdrawal failed");

        uint256 gasUsed = gasStart - gasleft();
        uint256 gasPrice = tx.gasprice;
        uint256 gasFee = gasUsed * gasPrice;

        outgoing.push(Transaction(msg.sender, _amount, block.timestamp, block.number, gasFee, 0));
    }

    function authenticateAdmin() public view onlyAdmin returns (bool) {
        return true;
    }

    function updateAdmin(address _newAdmin) public onlyAdmin {
        admin = payable(_newAdmin);
    }

    function toggleCauseState() public onlyAdmin {
        if (causeState == 1) {
            causeState = 2;
        }
        else if (causeState == 2){
            causeState= 1;
        }
    }

    function distributeFunds() public onlyAdmin {
        require(causeState == 2, "The cause has not ended yet");
        require(address(this).balance > 0, "The contract balance is zero");

        uint256 totalDonation = address(this).balance;

        // keep track of whether an address has already donated or not
        for (uint256 i = 0; i < incoming.length; i++) {
            address sender = incoming[i].sender;

            // check if the address has already donated
            if (!addressDonated[sender]) {
                uint256 proportion = donorTotals[sender] * 100 / totalDonation;
                uint256 donation = totalDonation * proportion / 100;
                if (donation > 0) {
                    (bool success, ) = sender.call{value: donation}("");
                    require(success, "Failed to distribute funds to donor");
                }

                // mark the address as having donated
                addressDonated[sender] = true;
            }
        }
    }

    //modifier to ensure only admin is able to call function
    modifier onlyAdmin() {
        require(admin == msg.sender, "You are not the admin of this contract");
        _;
    }
}