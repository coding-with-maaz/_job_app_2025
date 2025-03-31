const express = require('express');
const router = express.Router();
const jobController = require('../controllers/jobController');

// Get all jobs with enhanced search and filtering
router.get('/', jobController.getAllJobs);

// Get today's jobs
router.get('/today', jobController.getTodayJobs);

// Create a single job
router.post('/', jobController.createJob);

// Get jobs by location with statistics
router.get('/location/:location', jobController.getJobsByLocation);

// Get jobs by category with statistics
router.get('/category/:category', jobController.getJobsByCategory);

// Get jobs by tags
router.get('/tags', jobController.getJobsByTags);

// Get job by ID
router.get('/:id', jobController.getJobById);

// Create job from URL
router.post('/from-url', jobController.createJobFromURL);

// Create multiple jobs from URLs
router.post('/from-urls', jobController.createJobsFromURLs);

// Create multiple jobs from bulk data
router.post('/bulk', jobController.createBulkJobs);

// Create job with template
router.post('/template', jobController.createJobWithTemplate);

// Update job
router.put('/:id', jobController.updateJob);

// Delete job
router.delete('/:id', jobController.deleteJob);

// Update job's love reactions
router.patch('/:id/love', jobController.updateLoveReactions);

module.exports = router;