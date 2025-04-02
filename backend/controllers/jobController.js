const { Op } = require('sequelize');
const Job = require('../models/Job');
const sequelize = require('sequelize');
const JobParser = require('../utils/jobParser');
const path = require('path');

// Create a single job
exports.createJob = async (req, res) => {
  try {
    const jobData = {
      ...req.body,
      postedDate: new Date(),
      status: 'active',
      // Ensure occupation is properly formatted
      occupation: req.body.occupation ? req.body.occupation.trim() : 'Other',
      // Set appType based on occupation or provided value
      appType: req.body.appType || (req.body.occupation?.toLowerCase().includes('medical') ? 'medical' : 'general')
    };

    // Handle image upload if present
    if (req.file) {
      jobData.image = path.join('uploads/jobs', req.file.filename);
    }

    const job = await Job.create(jobData);
    res.status(201).json({
      success: true,
      message: 'Job created successfully',
      data: job
    });
  } catch (error) {
    console.error('Error creating job:', error);
    res.status(400).json({
      success: false,
      message: 'Failed to create job',
      error: error.message
    });
  }
};

// Get all jobs with enhanced search and filtering
exports.getAllJobs = async (req, res) => {
  try {
    const {
      search,
      type,
      location,
      experience,
      salary,
      postedDate,
      deadline,
      company,
      appType,
      sortBy = 'postedDate',
      sortOrder = 'DESC',
      page = 1,
      limit = 10
    } = req.query;

    const where = {};

    // Filter by app type if provided
    if (appType) {
      where.appType = appType;
    }

    // Enhanced search functionality
    if (search) {
      where[Op.or] = [
        { title: { [Op.like]: `%${search}%` } },
        { description: { [Op.like]: `%${search}%` } },
        { requirements: { [Op.like]: `%${search}%` } },
        { company: { [Op.like]: `%${search}%` } }
      ];
    }

    // Filter by job type
    if (type) {
      where.type = type;
    }

    // Enhanced location search with partial matching
    if (location) {
      where[Op.or] = [
        { location: { [Op.like]: `%${location}%` } },
        { location: { [Op.like]: `${location}%` } },
        { location: { [Op.like]: `%${location}` } }
      ];
    }

    // Filter by experience level
    if (experience) {
      where.experience = experience;
    }

    // Filter by salary range
    if (salary) {
      const [minSalary, maxSalary] = salary.split('-').map(s => s.replace(/[^0-9]/g, ''));
      if (minSalary && maxSalary) {
        where.salary = {
          [Op.between]: [`$${minSalary}`, `$${maxSalary}`]
        };
      } else if (minSalary) {
        where.salary = {
          [Op.gte]: `$${minSalary}`
        };
      }
    }

    // Filter by posted date
    if (postedDate) {
      where.postedDate = {
        [Op.gte]: new Date(postedDate)
      };
    }

    // Filter by deadline
    if (deadline) {
      where.deadline = {
        [Op.lte]: new Date(deadline)
      };
    }

    // Filter by company
    if (company) {
      where.company = {
        [Op.like]: `%${company}%`
      };
    }

    // Calculate pagination
    const offset = (page - 1) * limit;

    // Get total count for pagination
    const total = await Job.count({ where });

    // Get jobs with sorting and pagination
    const jobs = await Job.findAll({
      where,
      order: [[sortBy, sortOrder]],
      limit: parseInt(limit),
      offset: parseInt(offset)
    });

    // Get app-specific statistics
    const stats = await Job.findAll({
      attributes: [
        'type',
        [sequelize.fn('COUNT', sequelize.col('id')), 'count']
      ],
      where: appType ? { appType } : {},
      group: ['type']
    });

    // Get occupation statistics for the app
    const occupationStats = await Job.findAll({
      attributes: [
        'occupation',
        [sequelize.fn('COUNT', sequelize.col('id')), 'count']
      ],
      where: appType ? { appType } : {},
      group: ['occupation'],
      order: [[sequelize.fn('COUNT', sequelize.col('id')), 'DESC']],
      limit: 10
    });

    res.status(200).json({
      success: true,
      data: {
        jobs,
        pagination: {
          total,
          page: parseInt(page),
          pages: Math.ceil(total / limit),
          limit: parseInt(limit)
        },
        statistics: {
          byType: stats,
          byOccupation: occupationStats
        }
      }
    });
  } catch (error) {
    res.status(500).json({ 
      success: false,
      message: 'Failed to fetch jobs',
      error: error.message 
    });
  }
};

// Get jobs by location with statistics
exports.getJobsByLocation = async (req, res) => {
  try {
    const { location } = req.params;
    const { type, experience } = req.query;

    const where = {
      location: { [Op.like]: `%${location}%` }
    };

    if (type) {
      where.type = type;
    }

    if (experience) {
      where.experience = experience;
    }

    const jobs = await Job.findAll({
      where,
      order: [['postedDate', 'DESC']]
    });

    // Get location-specific statistics
    const stats = await Job.findAll({
      attributes: [
        'type',
        [sequelize.fn('COUNT', sequelize.col('id')), 'count']
      ],
      where: { location: { [Op.like]: `%${location}%` } },
      group: ['type']
    });

    res.status(200).json({
      jobs,
      stats
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Get job by ID
exports.getJobById = async (req, res) => {
  try {
    const job = await Job.findByPk(req.params.id);
    if (!job) {
      return res.status(404).json({ message: 'Job not found' });
    }
    res.status(200).json(job);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Create new job from URL
exports.createJobFromURL = async (req, res) => {
  try {
    const { url } = req.body;
    if (!url) {
      return res.status(400).json({ message: 'URL is required' });
    }

    const jobData = await JobParser.parseJobFromURL(url);
    const job = await Job.create(jobData);
    res.status(201).json(job);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Create multiple jobs from URLs
exports.createJobsFromURLs = async (req, res) => {
  try {
    const { urls } = req.body;
    if (!Array.isArray(urls) || urls.length === 0) {
      return res.status(400).json({ message: 'Array of URLs is required' });
    }

    const jobs = await Promise.all(
      urls.map(async (url) => {
        try {
          const jobData = await JobParser.parseJobFromURL(url);
          return await Job.create(jobData);
        } catch (error) {
          console.error(`Failed to create job from URL ${url}:`, error.message);
          return null;
        }
      })
    );

    const successfulJobs = jobs.filter(job => job !== null);
    res.status(201).json({
      message: `Successfully created ${successfulJobs.length} jobs`,
      jobs: successfulJobs
    });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Create multiple jobs from bulk data
exports.createBulkJobs = async (req, res) => {
  try {
    const { jobs } = req.body;
    if (!Array.isArray(jobs) || jobs.length === 0) {
      return res.status(400).json({ message: 'Array of jobs is required' });
    }

    const parsedJobs = JobParser.parseBulkJobs(jobs);
    const createdJobs = await Promise.all(
      parsedJobs.map(jobData => Job.create(jobData))
    );

    res.status(201).json({
      message: `Successfully created ${createdJobs.length} jobs`,
      jobs: createdJobs
    });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Get jobs by category
exports.getJobsByCategory = async (req, res) => {
  try {
    const { category } = req.params;
    const { type, experience, page = 1, limit = 10 } = req.query;

    const where = {
      category: { [Op.like]: `%${category}%` }
    };

    if (type) {
      where.type = type;
    }

    if (experience) {
      where.experience = experience;
    }

    // Calculate pagination
    const offset = (page - 1) * limit;

    // Get total count for pagination
    const total = await Job.count({ where });

    // Get jobs with pagination
    const jobs = await Job.findAll({
      where,
      order: [['postedDate', 'DESC']],
      limit: parseInt(limit),
      offset: parseInt(offset)
    });

    // Get category-specific statistics
    const stats = await Job.findAll({
      attributes: [
        'type',
        [sequelize.fn('COUNT', sequelize.col('id')), 'count']
      ],
      where: { category: { [Op.like]: `%${category}%` } },
      group: ['type']
    });

    // Get experience level distribution
    const experienceStats = await Job.findAll({
      attributes: [
        'experience',
        [sequelize.fn('COUNT', sequelize.col('id')), 'count']
      ],
      where: { category: { [Op.like]: `%${category}%` } },
      group: ['experience']
    });

    // Get salary range distribution
    const salaryStats = await Job.findAll({
      attributes: [
        'salary',
        [sequelize.fn('COUNT', sequelize.col('id')), 'count']
      ],
      where: { category: { [Op.like]: `%${category}%` } },
      group: ['salary']
    });

    res.status(200).json({
      success: true,
      data: {
        jobs,
        category,
        totalJobs: total,
        pagination: {
          total,
          page: parseInt(page),
          pages: Math.ceil(total / limit),
          limit: parseInt(limit)
        },
        statistics: {
          byType: stats,
          byExperience: experienceStats,
          bySalary: salaryStats
        }
      }
    });
  } catch (error) {
    console.error('Error fetching jobs by category:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch jobs by category',
      error: error.message
    });
  }
};

// Update job's love reactions
exports.updateLoveReactions = async (req, res) => {
  try {
    const { id } = req.params;
    const { increment } = req.body;

    const job = await Job.findByPk(id);
    if (!job) {
      return res.status(404).json({ message: 'Job not found' });
    }

    const currentReactions = parseInt(job.lovereactions) || 0;
    const newReactions = increment ? currentReactions + 1 : currentReactions - 1;

    await job.update({ lovereactions: newReactions.toString() });
    
    res.status(200).json({
      success: true,
      message: 'Love reactions updated successfully',
      data: { lovereactions: newReactions }
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Get jobs by tags
exports.getJobsByTags = async (req, res) => {
  try {
    const { tags } = req.query;
    if (!tags) {
      return res.status(400).json({ message: 'Tags parameter is required' });
    }

    const tagArray = tags.split(',').map(tag => tag.trim());
    const where = {
      [Op.or]: tagArray.map(tag => ({
        tags: { [Op.like]: `%${tag}%` }
      }))
    };

    const jobs = await Job.findAll({
      where,
      order: [['postedDate', 'DESC']]
    });

    res.status(200).json({
      success: true,
      data: jobs
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Create new job with template
exports.createJobWithTemplate = async (req, res) => {
  try {
    const {
      title,
      company,
      location,
      description,
      requirements,
      salary,
      type,
      experience,
      deadline
    } = req.body;

    // Create a template-based job
    const jobData = {
      title: title || 'Untitled Position',
      company: company || 'Company Not Specified',
      location: location || 'Location Not Specified',
      description: description || 'No description provided',
      requirements: requirements || 'No specific requirements listed',
      salary: salary || 'Salary not specified',
      type: type || 'Full-time',
      experience: experience || 'Not specified',
      postedDate: new Date(),
      deadline: deadline ? new Date(deadline) : JobParser.calculateDeadline(new Date())
    };

    const job = await Job.create(jobData);
    res.status(201).json(job);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Update job
exports.updateJob = async (req, res) => {
  try {
    const job = await Job.findByPk(req.params.id);
    if (!job) {
      return res.status(404).json({ message: 'Job not found' });
    }

    await job.update(req.body);
    res.status(200).json(job);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Delete job
exports.deleteJob = async (req, res) => {
  try {
    const job = await Job.findByPk(req.params.id);
    if (!job) {
      return res.status(404).json({ message: 'Job not found' });
    }

    await job.destroy();
    res.status(200).json({ message: 'Job deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Get today's jobs
exports.getTodayJobs = async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const jobs = await Job.findAll({
      where: {
        postedDate: {
          [Op.between]: [today, tomorrow]
        }
      },
      order: [['postedDate', 'DESC']]
    });

    res.status(200).json({
      success: true,
      data: jobs
    });
  } catch (error) {
    console.error('Error fetching today\'s jobs:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch today\'s jobs',
      error: error.message
    });
  }
};

// Get jobs by occupation with statistics
exports.getJobsByOccupation = async (req, res) => {
  try {
    const { occupation } = req.params;
    const { type, experience, location, appType, page = 1, limit = 10 } = req.query;

    const where = {
      occupation: { [Op.like]: `%${occupation}%` }
    };

    // Add app type filter if provided
    if (appType) {
      where.appType = appType;
    }

    // Apply additional filters if provided
    if (type) {
      where.type = type;
    }

    if (experience) {
      where.experience = experience;
    }

    if (location) {
      where.location = { [Op.like]: `%${location}%` };
    }

    // Calculate pagination
    const offset = (page - 1) * limit;

    // Get total count for pagination
    const total = await Job.count({ where });

    // Get jobs with pagination
    const jobs = await Job.findAll({
      where,
      order: [['postedDate', 'DESC']],
      limit: parseInt(limit),
      offset: parseInt(offset)
    });

    // Get occupation-specific statistics
    const stats = await Job.findAll({
      attributes: [
        'type',
        [sequelize.fn('COUNT', sequelize.col('id')), 'count']
      ],
      where: { 
        occupation: { [Op.like]: `%${occupation}%` },
        ...(appType ? { appType } : {})
      },
      group: ['type']
    });

    // Get experience level distribution
    const experienceStats = await Job.findAll({
      attributes: [
        'experience',
        [sequelize.fn('COUNT', sequelize.col('id')), 'count']
      ],
      where: { 
        occupation: { [Op.like]: `%${occupation}%` },
        ...(appType ? { appType } : {})
      },
      group: ['experience']
    });

    // Get salary range distribution
    const salaryStats = await Job.findAll({
      attributes: [
        'salary',
        [sequelize.fn('COUNT', sequelize.col('id')), 'count']
      ],
      where: { 
        occupation: { [Op.like]: `%${occupation}%` },
        ...(appType ? { appType } : {})
      },
      group: ['salary']
    });

    res.status(200).json({
      success: true,
      data: {
        jobs,
        occupation,
        totalJobs: total,
        pagination: {
          total,
          page: parseInt(page),
          pages: Math.ceil(total / limit),
          limit: parseInt(limit)
        },
        statistics: {
          byType: stats,
          byExperience: experienceStats,
          bySalary: salaryStats
        }
      }
    });
  } catch (error) {
    res.status(500).json({ 
      success: false,
      message: 'Failed to fetch jobs by occupation',
      error: error.message 
    });
  }
};

// Get all available occupations with job counts
exports.getAllOccupations = async (req, res) => {
  try {
    const occupations = await Job.findAll({
      attributes: [
        'occupation',
        [sequelize.fn('COUNT', sequelize.col('id')), 'count']
      ],
      group: ['occupation'],
      order: [[sequelize.fn('COUNT', sequelize.col('id')), 'DESC']]
    });

    res.status(200).json({
      success: true,
      data: occupations
    });
  } catch (error) {
    res.status(500).json({ 
      success: false,
      message: 'Failed to fetch occupations',
      error: error.message 
    });
  }
}; 