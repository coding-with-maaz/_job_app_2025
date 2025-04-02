const express = require('express');
const router = express.Router();
const savedJobController = require('../controllers/savedJobController');
const verifyFirebaseToken = require('../middleware/firebaseAuth');

// All routes require Firebase authentication
router.use(verifyFirebaseToken);

// Save a job
router.post('/:jobId', savedJobController.saveJob);

// Unsave a job
router.delete('/:jobId', savedJobController.unsaveJob);

// Get user's saved jobs
router.get('/', savedJobController.getSavedJobs);

// Check if a job is saved
router.get('/check/:jobId', savedJobController.checkIfJobSaved);

module.exports = router; 