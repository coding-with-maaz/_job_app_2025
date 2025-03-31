const seedJobs = require('./seeders/jobSeeder');
const { seedApplications, seedSavedJobs, undoSeeding } = require('./seeders/applicationSeeder');
const { Job, sequelize } = require('./models');

const jobs = [
  {
    title: 'Data Analyst',
    company: 'Data Insights Co.',
    location: 'Remote',
    description: 'Join our data team to analyze and visualize business metrics...',
    requirements: 'SQL, Python, Data Visualization',
    salary: '$70,000-$90,000',
    type: 'Full-time',
    experience: 'Entry Level',
    postedDate: new Date(),
    deadline: new Date(Date.now() + 20 * 24 * 60 * 60 * 1000),
    category: 'Data Science',
    tags: 'data-analysis,sql,python,visualization',
    lovereactions: '0'
  },
  {
    title: 'UX Designer',
    company: 'Design Studio',
    location: 'Los Angeles, CA',
    description: 'Looking for a talented UX designer to create beautiful interfaces...',
    requirements: 'Figma, User Research, Prototyping',
    salary: '$90,000-$110,000',
    type: 'Full-time',
    experience: 'Mid Level',
    postedDate: new Date(),
    deadline: new Date(Date.now() + 15 * 24 * 60 * 60 * 1000),
    category: 'Design',
    tags: 'ux,ui,design,figma,prototyping',
    lovereactions: '0'
  },
  {
    title: 'Product Manager',
    company: 'Product Co.',
    location: 'Seattle, WA',
    description: 'Seeking a product manager to drive our product development...',
    requirements: 'Product Strategy, Agile, User Stories',
    salary: '$100,000-$130,000',
    type: 'Full-time',
    experience: 'Senior Level',
    postedDate: new Date(),
    deadline: new Date(Date.now() + 10 * 24 * 60 * 60 * 1000),
    category: 'Product',
    tags: 'product-management,agile,strategy,leadership',
    lovereactions: '0'
  },
  {
    title: 'DevOps Engineer',
    company: 'Cloud Solutions',
    location: 'Remote',
    description: 'Join our DevOps team to automate and optimize our infrastructure...',
    requirements: 'Docker, Kubernetes, CI/CD, AWS',
    salary: '$110,000-$140,000',
    type: 'Full-time',
    experience: 'Mid Level',
    postedDate: new Date(),
    deadline: new Date(Date.now() + 5 * 24 * 60 * 60 * 1000),
    category: 'Technology',
    tags: 'devops,cloud,kubernetes,docker,aws',
    lovereactions: '0'
  },
  {
    title: 'Content Writer',
    company: 'Content Hub',
    location: 'Remote',
    description: 'Looking for a creative content writer to create engaging content...',
    requirements: 'Writing, SEO, Content Strategy',
    salary: '$50,000-$70,000',
    type: 'Part-time',
    experience: 'Entry Level',
    postedDate: new Date(),
    deadline: new Date(Date.now() + 8 * 24 * 60 * 60 * 1000),
    category: 'Content',
    tags: 'writing,content,seo,marketing',
    lovereactions: '0'
  },
  {
    title: 'Sales Representative',
    company: 'Sales Pro',
    location: 'Chicago, IL',
    description: 'Join our sales team to drive revenue growth...',
    requirements: 'Sales, CRM, Negotiation',
    salary: '$60,000-$80,000 + Commission',
    type: 'Full-time',
    experience: 'Entry Level',
    postedDate: new Date(),
    deadline: new Date(Date.now() + 12 * 24 * 60 * 60 * 1000),
    category: 'Sales',
    tags: 'sales,negotiation,crm,business',
    lovereactions: '0'
  },
  {
    title: 'Mobile Developer',
    company: 'App Solutions',
    location: 'Austin, TX',
    description: 'Seeking a mobile developer to build cross-platform apps...',
    requirements: 'React Native, iOS, Android',
    salary: '$90,000-$120,000',
    type: 'Full-time',
    experience: 'Mid Level',
    postedDate: new Date(),
    deadline: new Date(Date.now() + 18 * 24 * 60 * 60 * 1000),
    category: 'Technology',
    tags: 'mobile,react-native,ios,android',
    lovereactions: '0'
  },
  {
    title: 'HR Manager',
    company: 'HR Solutions',
    location: 'Boston, MA',
    description: 'Looking for an HR manager to oversee our HR operations...',
    requirements: 'HR Management, Recruitment, Employee Relations',
    salary: '$85,000-$105,000',
    type: 'Full-time',
    experience: 'Senior Level',
    postedDate: new Date(),
    deadline: new Date(Date.now() + 22 * 24 * 60 * 60 * 1000),
    category: 'Human Resources',
    tags: 'hr,recruitment,management,employee-relations',
    lovereactions: '0'
  }
];

const seedDatabase = async () => {
  try {
    await sequelize.sync({ force: true });
    console.log('Database synced successfully');

    const createdJobs = await Job.bulkCreate(jobs);
    console.log(`${createdJobs.length} jobs created successfully`);

    for (const job of createdJobs) {
      const randomReactions = Math.floor(Math.random() * 100);
      await job.update({ lovereactions: randomReactions.toString() });
    }
    console.log('Love reactions added successfully');

    await seedApplications();
    await seedSavedJobs();
    
    console.log('Database seeding completed successfully');
  } catch (error) {
    console.error('Error seeding database:', error);
    process.exit(1);
  }
};

if (process.argv.includes('--undo')) {
  undoSeeding()
    .then(() => {
      console.log('Database seeding undone successfully');
      process.exit(0);
    })
    .catch((error) => {
      console.error('Error undoing database seeding:', error);
      process.exit(1);
    });
} else {
  seedDatabase();
}