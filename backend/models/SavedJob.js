const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const SavedJob = sequelize.define('SavedJob', {
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
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  savedAt: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  }
}, {
  timestamps: true,
  tableName: 'saved_jobs'
});

module.exports = SavedJob; 