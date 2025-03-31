const axios = require('axios');
const cheerio = require('cheerio');
const { convert } = require('html-to-text');

class JobParser {
  static async parseJobFromURL(url) {
    try {
      const response = await axios.get(url);
      const $ = cheerio.load(response.data);
      
      // Common selectors for job posting websites
      const selectors = {
        title: [
          'h1[class*="job-title"]',
          'h1[class*="title"]',
          '.job-title',
          '.title',
          'h1'
        ],
        company: [
          '[class*="company-name"]',
          '[class*="employer"]',
          '.company',
          '.employer'
        ],
        location: [
          '[class*="location"]',
          '[class*="address"]',
          '.location',
          '.address'
        ],
        description: [
          '[class*="description"]',
          '[class*="details"]',
          '.description',
          '.details'
        ],
        requirements: [
          '[class*="requirements"]',
          '[class*="qualifications"]',
          '.requirements',
          '.qualifications'
        ],
        salary: [
          '[class*="salary"]',
          '[class*="compensation"]',
          '.salary',
          '.compensation'
        ]
      };

      const jobData = {
        title: this.findContent($, selectors.title),
        company: this.findContent($, selectors.company),
        location: this.findContent($, selectors.location),
        description: this.findContent($, selectors.description),
        requirements: this.findContent($, selectors.requirements),
        salary: this.findContent($, selectors.salary),
        type: this.detectJobType(this.findContent($, selectors.description)),
        experience: this.detectExperience(this.findContent($, selectors.requirements)),
        postedDate: new Date(),
        deadline: this.calculateDeadline(new Date())
      };

      return this.cleanJobData(jobData);
    } catch (error) {
      throw new Error(`Failed to parse job from URL: ${error.message}`);
    }
  }

  static findContent($, selectors) {
    for (const selector of selectors) {
      const element = $(selector).first();
      if (element.length) {
        return element.text().trim();
      }
    }
    return '';
  }

  static detectJobType(description) {
    const types = ['Full-time', 'Part-time', 'Contract', 'Internship'];
    const lowerDesc = description.toLowerCase();
    
    for (const type of types) {
      if (lowerDesc.includes(type.toLowerCase())) {
        return type;
      }
    }
    return 'Full-time'; // Default
  }

  static detectExperience(requirements) {
    const experiencePatterns = [
      { pattern: /(\d+)\+?\s*years?/i, value: '$1+ years' },
      { pattern: /(\d+)\s*-\s*(\d+)\s*years?/i, value: '$1-$2 years' },
      { pattern: /entry\s*level/i, value: 'Entry Level' },
      { pattern: /senior/i, value: '5+ years' },
      { pattern: /lead/i, value: '3+ years' }
    ];

    for (const { pattern, value } of experiencePatterns) {
      const match = requirements.match(pattern);
      if (match) {
        return match[0].replace(pattern, value);
      }
    }
    return 'Not specified';
  }

  static calculateDeadline(postedDate) {
    const deadline = new Date(postedDate);
    deadline.setDate(deadline.getDate() + 30); // Default 30 days deadline
    return deadline;
  }

  static cleanJobData(jobData) {
    // Remove HTML tags and clean text
    Object.keys(jobData).forEach(key => {
      if (typeof jobData[key] === 'string') {
        jobData[key] = convert(jobData[key], {
          wordwrap: false,
          selectors: [
            { selector: 'a', options: { hideLinkHrefIfSameAsText: true } }
          ]
        }).trim();
      }
    });

    // Set default values if missing
    if (!jobData.title) jobData.title = 'Untitled Position';
    if (!jobData.company) jobData.company = 'Company Not Specified';
    if (!jobData.location) jobData.location = 'Location Not Specified';
    if (!jobData.description) jobData.description = 'No description provided';
    if (!jobData.requirements) jobData.requirements = 'No specific requirements listed';
    if (!jobData.salary) jobData.salary = 'Salary not specified';

    return jobData;
  }

  static parseBulkJobs(jobsData) {
    return jobsData.map(job => {
      const parsedJob = {
        title: job.title || 'Untitled Position',
        company: job.company || 'Company Not Specified',
        location: job.location || 'Location Not Specified',
        description: job.description || 'No description provided',
        requirements: job.requirements || 'No specific requirements listed',
        salary: job.salary || 'Salary not specified',
        type: this.detectJobType(job.description || ''),
        experience: this.detectExperience(job.requirements || ''),
        postedDate: new Date(),
        deadline: this.calculateDeadline(new Date())
      };

      return this.cleanJobData(parsedJob);
    });
  }
}

module.exports = JobParser; 