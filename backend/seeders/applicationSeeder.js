const { Job, JobApplication, SavedJob } = require('../models');

const generateMockApplications = async () => {
  const jobs = await Job.findAll();
  const applications = [];
  
  // Generate 50 random applications
  for (let i = 0; i < 50; i++) {
    const randomJob = jobs[Math.floor(Math.random() * jobs.length)];
    const applicationDate = new Date();
    applicationDate.setDate(applicationDate.getDate() - Math.floor(Math.random() * 30));
    
    applications.push({
      jobId: randomJob.id,
      name: `Applicant ${i + 1}`,
      email: `applicant${i + 1}@example.com`,
      phone: `+1${Math.floor(Math.random() * 9000000000) + 1000000000}`,
      resume: `https://example.com/resumes/applicant${i + 1}.pdf`,
      coverLetter: `I am writing to express my strong interest in the ${randomJob.title} position at ${randomJob.company}. With my experience and skills, I believe I would be a valuable addition to your team.`,
      status: ['pending', 'reviewed', 'shortlisted', 'rejected'][Math.floor(Math.random() * 4)],
      appliedAt: applicationDate,
      createdAt: applicationDate,
      updatedAt: applicationDate
    });
  }
  
  return applications;
};

const generateMockSavedJobs = async () => {
  const jobs = await Job.findAll();
  const savedJobs = [];
  
  // Generate 30 random saved jobs
  for (let i = 0; i < 30; i++) {
    const randomJob = jobs[Math.floor(Math.random() * jobs.length)];
    const savedDate = new Date();
    savedDate.setDate(savedDate.getDate() - Math.floor(Math.random() * 30));
    
    savedJobs.push({
      jobId: randomJob.id,
      userId: Math.floor(Math.random() * 10) + 1, // Simulating 10 different users
      savedAt: savedDate,
      createdAt: savedDate,
      updatedAt: savedDate
    });
  }
  
  return savedJobs;
};

const seedApplications = async () => {
  try {
    // Clear existing applications
    await JobApplication.destroy({ where: {} });
    
    // Generate and insert new applications
    const applications = await generateMockApplications();
    await JobApplication.bulkCreate(applications);
    
    console.log('Successfully seeded job applications');
  } catch (error) {
    console.error('Error seeding job applications:', error);
    throw error;
  }
};

const seedSavedJobs = async () => {
  try {
    // Clear existing saved jobs
    await SavedJob.destroy({ where: {} });
    
    // Generate and insert new saved jobs
    const savedJobs = await generateMockSavedJobs();
    await SavedJob.bulkCreate(savedJobs);
    
    console.log('Successfully seeded saved jobs');
  } catch (error) {
    console.error('Error seeding saved jobs:', error);
    throw error;
  }
};

const undoSeeding = async () => {
  try {
    // Delete all seeded data
    await JobApplication.destroy({ where: {} });
    await SavedJob.destroy({ where: {} });
    await Job.destroy({ where: {} });
    
    console.log('Successfully removed all seeded data');
  } catch (error) {
    console.error('Error removing seeded data:', error);
    throw error;
  }
};

module.exports = {
  seedApplications,
  seedSavedJobs,
  undoSeeding
}; 