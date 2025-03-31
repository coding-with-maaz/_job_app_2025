const { Op } = require('sequelize');
const { Job, sequelize } = require('../models');

// Get overall dashboard statistics
exports.getDashboardStats = async (req, res) => {
  try {
    // Get total jobs count
    const totalJobs = await Job.count();

    // Get recent jobs count (last 30 days)
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    const recentJobs = await Job.count({
      where: {
        postedDate: {
          [Op.gte]: thirtyDaysAgo
        }
      }
    });

    // Get unique companies count
    const companies = await Job.count({
      distinct: true,
      col: 'company'
    });

    // Calculate average salary
    const jobs = await Job.findAll({
      attributes: [
        [sequelize.literal(`
          AVG(CAST(
            REPLACE(
              REPLACE(salary, '$', ''),
              ',',
              ''
            ) AS DECIMAL(10,2))
          )
        `), 'averageSalary']
      ]
    });
    const averageSalary = Math.round(jobs[0].getDataValue('averageSalary') || 0);

    // Get job type distribution
    const jobTypeDistribution = await Job.findAll({
      attributes: [
        'type',
        [sequelize.fn('COUNT', sequelize.col('id')), 'value']
      ],
      group: ['type']
    });

    // Get location distribution
    const locationDistribution = await Job.findAll({
      attributes: [
        'location',
        [sequelize.fn('COUNT', sequelize.col('id')), 'value']
      ],
      where: {
        location: {
          [Op.not]: null
        }
      },
      group: ['location'],
      order: [[sequelize.fn('COUNT', sequelize.col('id')), 'DESC']],
      limit: 5
    });

    // Format location distribution
    const formattedLocationDistribution = locationDistribution.map(item => ({
      location: item.getDataValue('location'),
      value: parseInt(item.getDataValue('value'))
    }));

    // Get salary distribution
    const salaryDistribution = await Job.findAll({
      attributes: [
        [sequelize.literal(`
          CASE
            WHEN CAST(REPLACE(REPLACE(salary, '$', ''), ',', '') AS DECIMAL(10,2)) < 50000 THEN 'Under $50k'
            WHEN CAST(REPLACE(REPLACE(salary, '$', ''), ',', '') AS DECIMAL(10,2)) < 100000 THEN '$50k - $100k'
            WHEN CAST(REPLACE(REPLACE(salary, '$', ''), ',', '') AS DECIMAL(10,2)) < 150000 THEN '$100k - $150k'
            WHEN CAST(REPLACE(REPLACE(salary, '$', ''), ',', '') AS DECIMAL(10,2)) < 200000 THEN '$150k - $200k'
            ELSE 'Over $200k'
          END
        `), 'name'],
        [sequelize.fn('COUNT', sequelize.col('id')), 'value']
      ],
      group: [sequelize.literal('name')]
    });

    res.json({
      data: {
        totalJobs,
        companies,
        averageSalary,
        jobTypeDistribution,
        locationDistribution: formattedLocationDistribution,
        salaryDistribution,
        recentJobs
      }
    });
  } catch (error) {
    console.error('Error fetching dashboard stats:', error);
    res.status(500).json({ error: 'Failed to fetch dashboard statistics' });
  }
};

// Get recent jobs count
exports.getRecentJobsCount = async (req, res) => {
  try {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    
    const count = await Job.count({
      where: {
        postedDate: {
          [Op.gte]: thirtyDaysAgo
        }
      }
    });

    res.json({ count });
  } catch (error) {
    console.error('Error fetching recent jobs count:', error);
    res.status(500).json({ error: 'Failed to fetch recent jobs count' });
  }
};

// Get recent jobs
exports.getRecentJobs = async (req, res) => {
  try {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    
    const recentJobs = await Job.findAll({
      where: {
        postedDate: {
          [Op.gte]: thirtyDaysAgo
        }
      },
      order: [['postedDate', 'DESC']],
      limit: 5
    });

    res.json({
      data: recentJobs
    });
  } catch (error) {
    console.error('Error fetching recent jobs:', error);
    res.status(500).json({ error: 'Failed to fetch recent jobs' });
  }
};

// Get job trends
exports.getJobTrends = async (req, res) => {
  try {
    // Get job posting trends for the last 6 months
    const sixMonthsAgo = new Date();
    sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6);

    const trends = await Job.findAll({
      attributes: [
        [sequelize.fn('DATE_TRUNC', 'month', sequelize.col('postedDate')), 'month'],
        [sequelize.fn('COUNT', sequelize.col('id')), 'count']
      ],
      where: {
        postedDate: {
          [Op.gte]: sixMonthsAgo
        }
      },
      group: [sequelize.fn('DATE_TRUNC', 'month', sequelize.col('postedDate'))],
      order: [[sequelize.fn('DATE_TRUNC', 'month', sequelize.col('postedDate')), 'ASC']]
    });

    res.json(trends);
  } catch (error) {
    console.error('Error fetching job trends:', error);
    res.status(500).json({ error: 'Failed to fetch job trends' });
  }
};

// Get jobs trend over time
exports.getJobsTrend = async (req, res) => {
  try {
    const { days = 30 } = req.query;
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - parseInt(days));

    const jobsTrend = await Job.findAll({
      attributes: [
        [sequelize.fn('DATE', sequelize.col('postedDate')), 'date'],
        [sequelize.fn('COUNT', sequelize.col('id')), 'count']
      ],
      where: {
        postedDate: {
          [Op.gte]: startDate
        }
      },
      group: [sequelize.fn('DATE', sequelize.col('postedDate'))],
      order: [[sequelize.fn('DATE', sequelize.col('postedDate')), 'ASC']]
    });

    res.status(200).json(jobsTrend);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Get jobs by salary range
exports.getJobsBySalaryRange = async (req, res) => {
  try {
    const salaryRanges = [
      { min: 0, max: 50000, label: 'Under $50k' },
      { min: 50000, max: 100000, label: '$50k - $100k' },
      { min: 100000, max: 150000, label: '$100k - $150k' },
      { min: 150000, max: 200000, label: '$150k - $200k' },
      { min: 200000, max: Infinity, label: 'Over $200k' }
    ];

    const salaryDistribution = await Promise.all(
      salaryRanges.map(async (range) => {
        const count = await Job.count({
          where: {
            salary: {
              [Op.between]: [`$${range.min}`, `$${range.max}`]
            }
          }
        });
        return {
          range: range.label,
          count
        };
      })
    );

    res.status(200).json(salaryDistribution);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Get jobs by deadline
exports.getJobsByDeadline = async (req, res) => {
  try {
    const upcomingDeadlines = await Job.findAll({
      where: {
        deadline: {
          [Op.gte]: new Date()
        }
      },
      order: [['deadline', 'ASC']],
      limit: 10
    });

    res.status(200).json(upcomingDeadlines);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
}; 