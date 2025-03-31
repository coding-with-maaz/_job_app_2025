const { SavedJob, Job } = require('../models');

const savedJobController = {
  // Save a job
  saveJob: async (req, res) => {
    try {
      const { jobId, userId } = req.body;

      // Check if job exists
      const job = await Job.findByPk(jobId);
      if (!job) {
        return res.status(404).json({
          success: false,
          message: 'Job not found'
        });
      }

      // Check if already saved
      const existingSavedJob = await SavedJob.findOne({
        where: {
          jobId,
          userId
        }
      });

      if (existingSavedJob) {
        return res.status(400).json({
          success: false,
          message: 'Job is already saved'
        });
      }

      // Create new saved job
      const savedJob = await SavedJob.create({
        jobId,
        userId
      });

      res.status(201).json({
        success: true,
        message: 'Job saved successfully',
        data: savedJob
      });
    } catch (error) {
      console.error('Error saving job:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to save job',
        error: error.message
      });
    }
  },

  // Get saved jobs for a user
  getSavedJobs: async (req, res) => {
    try {
      const { userId } = req.params;
      const savedJobs = await SavedJob.findAll({
        where: { userId },
        include: [{
          model: Job,
          required: true
        }]
      });

      res.status(200).json({
        success: true,
        data: savedJobs.map(sj => sj.Job)
      });
    } catch (error) {
      console.error('Error fetching saved jobs:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch saved jobs',
        error: error.message
      });
    }
  },

  // Remove saved job
  removeSavedJob: async (req, res) => {
    try {
      const { id } = req.params;
      const savedJob = await SavedJob.findByPk(id);

      if (!savedJob) {
        return res.status(404).json({
          success: false,
          message: 'Saved job not found'
        });
      }

      await savedJob.destroy();

      res.status(200).json({
        success: true,
        message: 'Job removed from saved jobs'
      });
    } catch (error) {
      console.error('Error removing saved job:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to remove saved job',
        error: error.message
      });
    }
  }
};

module.exports = savedJobController; 