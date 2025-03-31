const { Job, JobApplication, SavedJob } = require('../models');

const jobTypes = ['Full-time', 'Part-time', 'Contract', 'Internship'];
const companies = [
  'Google', 'Microsoft', 'Amazon', 'Apple', 'Meta', 'Netflix', 
  'Airbnb', 'Uber', 'Spotify', 'Twitter', 'LinkedIn', 'Salesforce',
  'Adobe', 'Oracle', 'IBM', 'Intel', 'NVIDIA', 'AMD', 'Cisco', 'Dell'
];
const locations = [
  'New York, NY', 'San Francisco, CA', 'Seattle, WA', 'Austin, TX',
  'Boston, MA', 'Chicago, IL', 'Los Angeles, CA', 'Denver, CO',
  'Atlanta, GA', 'Miami, FL', 'Remote', 'Hybrid'
];
const experiences = [
  'Entry Level', 'Mid Level', 'Senior', 'Lead', 'Manager',
  'Director', 'VP', 'C-Level', '3+ years', '5+ years', '10+ years'
];
const jobTitles = [
  'Software Engineer', 'Product Manager', 'UX Designer', 'Data Scientist',
  'DevOps Engineer', 'Marketing Manager', 'Business Analyst', 'Project Manager',
  'Frontend Developer', 'Backend Developer', 'Full Stack Developer',
  'Mobile Developer', 'Cloud Architect', 'Security Engineer', 'QA Engineer'
];

const generateRandomSalary = () => {
  const base = Math.floor(Math.random() * 50) + 80; // 80k to 130k base
  const range = Math.floor(Math.random() * 30) + 20; // 20k to 50k range
  return `$${base},000 - $${base + range},000`;
};

const generateRandomDate = (days) => {
  const date = new Date();
  date.setDate(date.getDate() + days);
  return date.toISOString();
};

const generateMockJobs = (count) => {
  const jobs = [];
  
  for (let i = 0; i < count; i++) {
    const postedDate = generateRandomDate(-Math.floor(Math.random() * 30));
    const deadline = generateRandomDate(Math.floor(Math.random() * 60) + 30);
    
    jobs.push({
      title: jobTitles[Math.floor(Math.random() * jobTitles.length)],
      company: companies[Math.floor(Math.random() * companies.length)],
      location: locations[Math.floor(Math.random() * locations.length)],
      description: `We are looking for a talented professional to join our team. This role requires strong technical skills and a passion for innovation. The ideal candidate will have experience in modern development practices and a track record of delivering high-quality solutions.`,
      requirements: `- Bachelor's degree in Computer Science or related field\n- ${experiences[Math.floor(Math.random() * experiences.length)]} experience\n- Strong problem-solving skills\n- Excellent communication abilities\n- Team player with a collaborative mindset`,
      salary: generateRandomSalary(),
      type: jobTypes[Math.floor(Math.random() * jobTypes.length)],
      experience: experiences[Math.floor(Math.random() * experiences.length)],
      postedDate,
      deadline,
      status: 'active',
      createdAt: new Date(),
      updatedAt: new Date()
    });
  }
  
  return jobs;
};

const seedJobs = async () => {
  try {
    // First, delete related records
    await JobApplication.destroy({ where: {} });
    await SavedJob.destroy({ where: {} });
    
    // Then clear existing jobs
    await Job.destroy({ where: {} });
    
    // Generate and insert new jobs
    const jobs = generateMockJobs(100);
    await Job.bulkCreate(jobs);
    
    console.log('Successfully seeded jobs database');
  } catch (error) {
    console.error('Error seeding jobs:', error);
    throw error;
  }
};

module.exports = seedJobs; 