require('dotenv').config();
const fs = require('fs');
const pinataSDK = require('@pinata/sdk');

const pinata = new pinataSDK(process.env.PINATA_API_KEY, process.env.PINATA_SECRET_API_KEY);

async function uploadToPinata(filePath, originalName) {
    const readableStreamForFile = fs.createReadStream(filePath);
    try {
        const options = {
            pinataMetadata: {
                name: originalName || 'incident-photo'
            },
            pinataOptions: {
                cidVersion: 1
            }
        };

        const result = await pinata.pinFileToIPFS(readableStreamForFile, options);
        console.log('Uploaded to IPFS:', result.IpfsHash);
        return result.IpfsHash;
    } catch (error) {
        console.error('Error uploading file:', error);
        return null;
    }
}

module.exports = { uploadToPinata };
