const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const JobApplication = sequelize.define('JobApplication', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  jobId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'jobs',
      key: 'id'
    }
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false
  },
  email: {
    type: DataTypes.STRING,
    allowNull: false,
    validate: {
      isEmail: true
    }
  },
  phone: {
    type: DataTypes.STRING,
    allowNull: false
  },
  resume: {
    type: DataTypes.STRING,
    allowNull: false
  },
  coverLetter: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  status: {
    type: DataTypes.ENUM('pending', 'reviewed', 'shortlisted', 'rejected'),
    defaultValue: 'pending'
  },
  appliedAt: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  },
  cvPath: {
    type: DataTypes.STRING,
    allowNull: true
  }
}, {
  timestamps: true,
  tableName: 'job_applications'
});

module.exports = JobApplication; 