const { sequelize } = require('../config/db');
const Job = require('./Job');
const JobApplication = require('./JobApplication');
const SavedJob = require('./SavedJob');

// Define associations
Job.hasMany(JobApplication, { foreignKey: 'jobId' });
JobApplication.belongsTo(Job, { foreignKey: 'jobId' });

Job.hasMany(SavedJob, { foreignKey: 'jobId' });
SavedJob.belongsTo(Job, { foreignKey: 'jobId' });

// Initialize models
const models = {
  Job,
  JobApplication,
  SavedJob
};

// Test database connection
sequelize.authenticate()
  .then(() => {
    console.log('Database connection established successfully.');
  })
  .catch(err => {
    console.error('Unable to connect to the database:', err);
  });

module.exports = {
  sequelize,
  ...models
}; 