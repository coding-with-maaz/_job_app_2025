const express = require('express');
const router = express.Router();
const jobApplicationController = require('../controllers/jobApplicationController');

// Submit a job application
router.post('/', jobApplicationController.submitApplication);

// Get applications for a job
router.get('/job/:jobId', jobApplicationController.getJobApplications);

// Update application status
router.patch('/:id/status', jobApplicationController.updateApplicationStatus);

// Download CV
router.get('/:id/cv', jobApplicationController.downloadCV);

module.exports = router; 