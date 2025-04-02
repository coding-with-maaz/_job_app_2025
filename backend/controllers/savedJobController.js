const SavedJob = require('../models/SavedJob');
const Job = require('../models/Job');

// Save a job
exports.saveJob = async (req, res) => {
  try {
    const { jobId } = req.params;
    const userId = req.user.uid;

    // Check if job exists
    const job = await Job.findByPk(jobId);
    if (!job) {
      return res.status(404).json({
        success: false,
        message: 'Job not found'
      });
    }

    // Check if job is already saved
    const existingSave = await SavedJob.findOne({
      where: { userId, jobId }
    });

    if (existingSave) {
      return res.status(400).json({
        success: false,
        message: 'Job already saved'
      });
    }

    // Save the job
    const savedJob = await SavedJob.create({
      userId,
      jobId
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
};

// Unsave a job
exports.unsaveJob = async (req, res) => {
  try {
    const { jobId } = req.params;
    const userId = req.user.uid;

    const result = await SavedJob.destroy({
      where: { userId, jobId }
    });

    if (!result) {
      return res.status(404).json({
        success: false,
        message: 'Saved job not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Job unsaved successfully'
    });
  } catch (error) {
    console.error('Error unsaving job:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to unsave job',
      error: error.message
    });
  }
};

// Get user's saved jobs
exports.getSavedJobs = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { page = 1, limit = 10 } = req.query;

    // Calculate pagination
    const offset = (page - 1) * limit;

    // Get total count
    const total = await SavedJob.count({
      where: { userId }
    });

    // Get saved jobs with job details
    const savedJobs = await SavedJob.findAll({
      where: { userId },
      include: [{
        model: Job,
        attributes: ['title', 'company', 'location', 'salary', 'type', 'experience', 'postedDate', 'deadline', 'image']
      }],
      order: [['savedAt', 'DESC']],
      limit: parseInt(limit),
      offset: parseInt(offset)
    });

    res.status(200).json({
      success: true,
      data: {
        savedJobs,
        pagination: {
          total,
          page: parseInt(page),
          pages: Math.ceil(total / limit),
          limit: parseInt(limit)
        }
      }
    });
  } catch (error) {
    console.error('Error fetching saved jobs:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch saved jobs',
      error: error.message
    });
  }
};

// Check if a job is saved
exports.checkIfJobSaved = async (req, res) => {
  try {
    const { jobId } = req.params;
    const userId = req.user.uid;

    const savedJob = await SavedJob.findOne({
      where: { userId, jobId }
    });

    res.status(200).json({
      success: true,
      data: {
        isSaved: !!savedJob
      }
    });
  } catch (error) {
    console.error('Error checking saved status:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to check saved status',
      error: error.message
    });
  }
}; 