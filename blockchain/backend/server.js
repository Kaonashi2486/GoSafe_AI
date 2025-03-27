require('dotenv').config();
const express = require('express');
const multer = require('multer');
const { uploadToPinata } = require('./pinataUpload');
const { addIncident, getIncident } = require('./web3Client'); // Import getIncident function

const app = express();
app.use(express.json());

const upload = multer({ dest: 'uploads/' });

// ✅ **POST: Store Incident**
app.post('/report', upload.single('photo'), async (req, res) => {
    if (!req.file) {
        return res.status(400).json({ error: 'No file uploaded' });
    }

    const { latitude, longitude, description } = req.body;
    
    try {
        const photoHash = await uploadToPinata(req.file.path, req.file.originalname);
        if (!photoHash) {
            return res.status(500).json({ error: 'Photo upload failed' });
        }

        // ✅ Store the incident and get its ID
        const incidentId = await addIncident(photoHash, latitude, longitude, description);
        if (incidentId === null) {
            return res.status(500).json({ error: 'Failed to store incident on blockchain' });
        }

        res.json({ 
            message: 'Incident reported successfully', 
            photoHash, 
            incidentId: Number(incidentId)  // Convert BigInt to Number before sending response
        });
        

    } catch (error) {
        console.error('Error reporting incident:', error);
        res.status(500).json({ error: 'Server error' });
    }
});


// ✅ **GET: Fetch Incident by ID**
app.get('/incident/:id', async (req, res) => {
    const incidentId = parseInt(req.params.id); // Convert ID to integer
    const incident = await getIncident(incidentId);

    if (!incident) {
        return res.status(404).json({ error: 'Incident not found' });
    }

    res.json(incident); // Now safe to serialize
});


// ✅ **Start Server**
const PORT = 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
