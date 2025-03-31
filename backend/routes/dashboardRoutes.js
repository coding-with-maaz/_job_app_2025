const express = require('express');
const router = express.Router();
const dashboardController = require('../controllers/dashboardController');

// Get dashboard statistics
router.get('/stats', dashboardController.getDashboardStats);

// Get recent jobs count
router.get('/recent-count', dashboardController.getRecentJobsCount);

// Get recent jobs
router.get('/recent', dashboardController.getRecentJobs);

// Get job trends
router.get('/trends', dashboardController.getJobTrends);

// Get jobs by salary range
router.get('/salary', dashboardController.getJobsBySalaryRange);

// Get jobs by deadline
router.get('/deadline', dashboardController.getJobsByDeadline);

module.exports = router; 