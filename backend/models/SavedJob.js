const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const SavedJob = sequelize.define('SavedJob', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  userId: {
    type: DataTypes.STRING,
    allowNull: false,
    comment: 'Firebase User ID'
  },
  jobId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'jobs',
      key: 'id'
    }
  },
  savedAt: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  }
}, {
  timestamps: true,
  tableName: 'saved_jobs',
  indexes: [
    {
      unique: true,
      fields: ['userId', 'jobId']
    }
  ]
});

module.exports = SavedJob; 