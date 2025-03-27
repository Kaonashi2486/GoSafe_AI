const { Web3 } = require('web3');
const contractABI = require('C:/Users/admin/Documents/TravelSafety/build/contracts/IncidentRegistry.json');
const web3 = new Web3('http://127.0.0.1:7545'); // Ensure Ganache is running

const contractAddress = '0x88837d555Ac6B11805b5637Bf8619B1422ffDD95'; // Replace with your contract address
const contract = new web3.eth.Contract(contractABI.abi, contractAddress);

// Get accounts from Ganache
async function getAccount() {
    const accounts = await web3.eth.getAccounts();
    return accounts[0]; // Use the first account
}

// ✅ **Updated Function: Store Incident & Return ID**
async function addIncident(photoHash, latitude, longitude, description) {
    try {
        const fromAddress = await getAccount();

        // ✅ Convert BigInt to Number
        const incidentCount = await contract.methods.incidentCount().call();
        const incidentId = Number(incidentCount); // Convert BigInt to Number

        await contract.methods
            .addIncident(photoHash, latitude, longitude, description)
            .send({ from: fromAddress, gas: 500000 });

        console.log(`Incident stored successfully with ID: ${incidentId}`);
        return incidentId;

    } catch (error) {
        console.error('Error storing incident:', error);
        return null;
    }
}


// ✅ **Function to Fetch Incident by ID**
async function getIncident(incidentId) {
    try {
        const incident = await contract.methods.getIncident(incidentId).call();

        // ✅ Convert BigInt values to Numbers before returning
        return {
            photoHash: incident.photoHash,
            latitude: incident.latitude,
            longitude: incident.longitude,
            description: incident.description,
            timestamp: Number(incident.timestamp) // Convert BigInt to Number
        };

    } catch (error) {
        console.error('Error fetching incident:', error);
        return null;
    }
}

module.exports = { addIncident, getIncident };
