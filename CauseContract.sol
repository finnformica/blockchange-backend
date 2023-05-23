// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract CauseContract {

    // admin address
    address payable admin;

    // blockChange wallet address
    address payable blockChange = payable(0xB860dDDA6F1506607bf42E2c9E871488216aE04D);

    // contract factory address
    address contractFactory;

    // donation total tracker
    uint256 causeTotal;

    // cause withdrawal total tracker
    uint256 causeWithdrawalTotal;

    // Flag for whether funds have been redistributed -> 1= False, 2=True
    uint256 fundsDistributedFlag = 1;

    // Transaction fee of 50bps (by default)
    uint256 constant BASIS_POINTS = 50;

    // Add transactionFeeBasisPoints variable for gas optimization
    uint256 transactionFeeBasisPoints;

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

    // mapping used for unique address identification in redistribute funds function
    mapping(address => bool) public addressDonated;

    // causeState flag -> 1 = active, 2 = inactive
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
        uint256 causeWithdrawalTotal;
        uint256 causeState;
        string email;
        string description;
        string website;
        string thumbnail;
        uint256 fundsDistributedFlag;
    }

    // transaction struct
    struct Transaction {
        address sender;
        uint256 amount;
        uint256 timestamp;
        uint256 blockNumber;
    }

    constructor(string memory _id, string memory _name, address payable _admin, string memory _description, string memory _websiteURL, string memory _thumbnailURL, string memory _email) {
        admin = _admin;

        contractFactory = msg.sender;

        // Calculate transactionFeeBasisPoints only once during contract creation
        transactionFeeBasisPoints = BASIS_POINTS / 1000;
       
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
            address(this),
            causeTotal, 
            causeWithdrawalTotal,
            causeState, 
            email, 
            description, 
            websiteURL, 
            thumbnailURL,
            fundsDistributedFlag);
    }

    function donate() public payable{
        require(msg.value > 0, "You must send some Ether");
        require(causeState == 1, "This cause has ended, your funds have been returned");

        // Use transactionFeeBasisPoints to calculate transactionFee
        uint256 transactionFee = msg.value * transactionFeeBasisPoints;

        // `msg.value - transactionFee` was used twice -> store it in a variable to save gas
        // Calculate netDonation and use it later for gas optimization
        uint256 netDonation = msg.value - transactionFee;

        // update donor proportion
        donorTotals[msg.sender] += msg.value;

        // update causeTotal
        causeTotal += netDonation;


        incoming.push(Transaction(msg.sender, netDonation, block.timestamp, block.number)); 

        // Transfer the transactionFee as last stage of function execution
        (bool success, ) = blockChange.call{value: transactionFee}("");
        require(success, "Transfer failed.");
    }

    function withdraw(uint256 _amount) public payable onlyAdmin {
        require(address(this).balance >= _amount, "Insufficient funds for withdrawal");
       
        causeWithdrawalTotal += _amount;

        outgoing.push(Transaction(msg.sender, _amount, block.timestamp, block.number));

        (bool success, ) = admin.call{value: _amount}("");
        require(success, "Withdrawal failed");
    }

    function authenticateAdmin() public view onlyAdmin returns (bool) {
        return true;
    }

    function updateAdmin(address _newAdmin) public onlyAdmin {
        admin = payable(_newAdmin);
    }

    function getAdmin() public view returns (address){
        return admin;
    }

    function toggleCauseState() public onlyAdmin {
        require(fundsDistributedFlag == 1, "Funds have been redistributed, please delete the cause");
        if (causeState == 1) {
            causeState = 2;
        }
        else if (causeState == 2){
            causeState= 1;
        }
    }

    function distributeFunds() public onlyAdmin {
        require(causeState == 2, "The cause has not ended yet");
        require(fundsDistributedFlag == 1, "Funds have already been redistributed, please delete the cause");
        require(address(this).balance > 0, "The contract balance is zero");

        uint256 balance = address(this).balance;

        // keep track of whether an address has already donated or not
        for (uint256 i = 0; i < incoming.length; i++) {
            address sender = incoming[i].sender;

            // check if the address has already donated
            if (!addressDonated[sender]) {
                uint256 proportion = donorTotals[sender] * 100 / causeTotal;
                uint256 donation = balance * proportion / 100;
                if (donation > 0) {
                    outgoing.push(Transaction(sender, donation, block.timestamp, block.number));
                    (bool success, ) = sender.call{value: donation}("");
                    require(success, "Failed to distribute funds to donor");
                }

                // mark the address as having donated
                addressDonated[sender] = true;
            }
        }
        fundsDistributedFlag = 2;
    }

    receive() external payable {
        donate();
    }

    function setCauseStateInactive() public onlyAdmin {
        causeState = 2;
    }

    // modifier to ensure only admin or contract factory is able to call function
    modifier onlyAdmin() {
        require(admin == msg.sender || contractFactory == msg.sender, "You are not the admin of this contract");
        _;
    }
}

