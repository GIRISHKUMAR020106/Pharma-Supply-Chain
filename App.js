// This code goes in your app.js file

// 1. Define Contract Address and ABI
const contractAddress = "YOUR_DEPLOYED_CONTRACT_ADDRESS"; // <-- IMPORTANT: Replace with your contract's address
const contractABI = [ /* PASTE YOUR FULL ABI HERE */ ]; // <-- IMPORTANT: Paste your contract's ABI

let provider;
let signer;
let contract;

// DOM Elements
const connectButton = document.getElementById('connectButton');
const walletStatus = document.getElementById('walletStatus');
const checkStatusButton = document.getElementById('checkStatusButton');
const serialNoInput = document.getElementById('serialNoInput');
const medicineStatus = document.getElementById('medicineStatus');

// 2. Connect to Wallet Function
async function connectWallet() {
    if (typeof window.ethereum !== 'undefined') {
        try {
            // Request account access
            await window.ethereum.request({ method: 'eth_requestAccounts' });
            
            // Set up ethers
            provider = new ethers.providers.Web3Provider(window.ethereum);
            signer = provider.getSigner();
            contract = new ethers.Contract(contractAddress, contractABI, signer);
            
            const walletAddress = await signer.getAddress();
            walletStatus.textContent = `Connected: ${walletAddress.substring(0, 6)}...${walletAddress.substring(walletAddress.length - 4)}`;
            connectButton.textContent = 'Connected';
            console.log("Connected to contract:", contract);

        } catch (error) {
            console.error("User rejected connection:", error);
            walletStatus.textContent = "Connection failed. Please try again.";
        }
    } else {
        walletStatus.textContent = "MetaMask is not installed. Please install it to use this dApp.";
        connectButton.disabled = true;
    }
}

// 3. Interact with Contract Function
async function checkMedicineStatus() {
    if (!contract) {
        medicineStatus.textContent = "Please connect your wallet first.";
        return;
    }
    
    const serialNo = serialNoInput.value;
    if (!serialNo) {
        medicineStatus.textContent = "Please enter a serial number.";
        return;
    }

    try {
        medicineStatus.textContent = "Checking status...";
        // Call the 'checkMedicineStatus' view function from the smart contract
        const status = await contract.checkMedicineStatus(serialNo);
        
        let statusText = "Unknown";
        if (status === 0) statusText = "✅ Valid";
        if (status === 1) statusText = "❌ Expired";
        if (status === 2) statusText = "🚫 Rejected by patient";

        medicineStatus.textContent = `Status for serial no ${serialNo}: ${statusText}`;

    } catch (error) {
        console.error("Error checking status:", error);
        medicineStatus.textContent = `Error: ${error.message}`;
    }
}

// Event Listeners
connectButton.addEventListener('click', connectWallet);
checkStatusButton.addEventListener('click', checkMedicineStatus);