const express = require('express');
const router = express.Router();
const savedJobController = require('../controllers/savedJobController');

// Save a job
router.post('/', savedJobController.saveJob);

// Get saved jobs for a user
router.get('/user/:userId', savedJobController.getSavedJobs);

// Remove saved job
router.delete('/:id', savedJobController.removeSavedJob);

module.exports = router; 