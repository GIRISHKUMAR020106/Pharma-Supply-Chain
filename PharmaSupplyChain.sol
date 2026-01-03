// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract PharmaSupplyChain {
    address public owner;

    enum Role {
        None, //0
        Manufacturer,//1
        Distributor,//2
        Pharmacy,//3
        Patient//4
    }

    mapping(address => Role) public roles;
    mapping(address => bool) private roleAssigned;

    struct Medicine {
        string productID;
        uint256 serialNo;
        uint256 manufactureDate; // Unix timestamp
        uint256 expiryDate;      // Unix timestamp
        address currentOwner;
        uint256 lastTransferTime;
        address[] transferHistory;
    }

    mapping(uint256 => Medicine) public medicines;
    mapping(string => bool) private existingProductIDs;
    mapping(uint256 => bool) public rejected;

    event TransferRecorded(uint256 indexed serialNo, address indexed from, address indexed to, uint256 time);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner allowed");
        _;
    }

    modifier onlyRole(Role _role) {
        require(roles[msg.sender] == _role, "Incorrect role");
        _;
    }

    modifier onlyCurrentOwner(uint256 _serialNo) {
        require(medicines[_serialNo].currentOwner == msg.sender, "Not current owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        roles[owner] = Role.Manufacturer;
        roleAssigned[owner] = true;
    }

    function assignRole(address _account, Role _role) external onlyOwner {
        require(!roleAssigned[_account], "Address already has a role");
        roles[_account] = _role;
        roleAssigned[_account] = true;
    }

    function createMedicine(
        string calldata productID,
        uint256 serialNo,
        uint256 manufactureDate,
        uint256 expiryDate,
        address to
    ) external onlyRole(Role.Manufacturer) {
        require(roles[to] == Role.Distributor, "Recipient must be Distributor");
        require(medicines[serialNo].serialNo == 0, "Medicine serialNo exists");
        require(!existingProductIDs[productID], "ProductID already exists");
        require(expiryDate > manufactureDate, "Expiry must be after manufacture date");
        require(expiryDate > block.timestamp, "Expiry date must be in future");

        medicines[serialNo].productID = productID;
        medicines[serialNo].serialNo = serialNo;
        medicines[serialNo].manufactureDate = manufactureDate;
        medicines[serialNo].expiryDate = expiryDate;
        medicines[serialNo].currentOwner = to;
        medicines[serialNo].lastTransferTime = block.timestamp;
        medicines[serialNo].transferHistory.push(msg.sender);
        medicines[serialNo].transferHistory.push(to);

        existingProductIDs[productID] = true;

        emit TransferRecorded(serialNo, msg.sender, to, block.timestamp);
    }

    function transferToPharmacy(uint256 serialNo, address to) external onlyRole(Role.Distributor) onlyCurrentOwner(serialNo) {
        require(roles[to] == Role.Pharmacy, "Recipient must be Pharmacy");

        Medicine storage med = medicines[serialNo];
        med.currentOwner = to;
        med.lastTransferTime = block.timestamp;
        med.transferHistory.push(to);

        emit TransferRecorded(serialNo, msg.sender, to, block.timestamp);
    }

    function transferToPatient(uint256 serialNo, address to) external onlyRole(Role.Pharmacy) onlyCurrentOwner(serialNo) {
        require(roles[to] == Role.Patient, "Recipient must be Patient");

        Medicine storage med = medicines[serialNo];
        med.currentOwner = to;
        med.lastTransferTime = block.timestamp;
        med.transferHistory.push(to);

        emit TransferRecorded(serialNo, msg.sender, to, block.timestamp);
    }

    function getTransferHistory(uint256 serialNo) external view returns(address[] memory) {
        require(roles[msg.sender] == Role.Patient, "Only patient can view");
        require(medicines[serialNo].currentOwner == msg.sender, "Not medicine owner");
        return medicines[serialNo].transferHistory;
    }

    // 0: valid, 1: expired, 2: rejected by patient
    function checkMedicineStatus(uint256 serialNo) external view returns (uint8) {
        require(roles[msg.sender] == Role.Patient, "Only patient can check");
        require(medicines[serialNo].currentOwner == msg.sender, "Not medicine owner");

        if (rejected[serialNo]) {
            return 2;
        }
        if (block.timestamp > medicines[serialNo].expiryDate) {
            return 1;
        }
        return 0;
    }

    function rejectMedicine(uint256 serialNo) external {
        require(roles[msg.sender] == Role.Patient, "Only patient can reject");
        require(medicines[serialNo].currentOwner == msg.sender, "Not medicine owner");
        rejected[serialNo] = true;
    }
}