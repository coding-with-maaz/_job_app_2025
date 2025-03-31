const { JobApplication } = require('../models');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadDir = 'uploads/cvs';
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024 // 5MB limit
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type. Only PDF and Word documents are allowed.'));
    }
  }
}).single('cv');

const jobApplicationController = {
  // Submit a job application
  submitApplication: async (req, res) => {
    try {
      const { jobId, name, email, phone, resume, coverLetter } = req.body;

      // Check if already applied
      const existingApplication = await JobApplication.findOne({
        where: {
          jobId,
          email
        }
      });

      if (existingApplication) {
        return res.status(400).json({
          success: false,
          message: 'You have already applied for this job'
        });
      }

      // Create new application
      const application = await JobApplication.create({
        jobId,
        name,
        email,
        phone,
        resume,
        coverLetter
      });

      res.status(201).json({
        success: true,
        message: 'Application submitted successfully',
        data: application
      });
    } catch (error) {
      console.error('Error submitting application:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to submit application',
        error: error.message
      });
    }
  },

  // Get applications for a job
  getJobApplications: async (req, res) => {
    try {
      const { jobId } = req.params;
      const applications = await JobApplication.findAll({
        where: { jobId },
        order: [['appliedAt', 'DESC']]
      });

      res.json({
        success: true,
        data: applications
      });
    } catch (error) {
      console.error('Error fetching applications:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch applications',
        error: error.message
      });
    }
  },

  // Update application status
  updateApplicationStatus: async (req, res) => {
    try {
      const { id } = req.params;
      const { status } = req.body;

      const application = await JobApplication.findByPk(id);
      if (!application) {
        return res.status(404).json({
          success: false,
          message: 'Application not found'
        });
      }

      await application.update({ status });

      res.json({
        success: true,
        message: 'Application status updated successfully',
        data: application
      });
    } catch (error) {
      console.error('Error updating application status:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to update application status',
        error: error.message
      });
    }
  },

  downloadCV: async (req, res) => {
    try {
      const { id } = req.params;
      const application = await JobApplication.findByPk(id);

      if (!application) {
        return res.status(404).json({
          success: false,
          message: 'Application not found'
        });
      }

      if (!application.cvPath || !fs.existsSync(application.cvPath)) {
        return res.status(404).json({
          success: false,
          message: 'CV file not found'
        });
      }

      res.download(application.cvPath);
    } catch (error) {
      console.error('Error downloading CV:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to download CV',
        error: error.message
      });
    }
  }
};

module.exports = jobApplicationController; 