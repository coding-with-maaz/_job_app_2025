# HarPal Jobs API Documentation

## Base URL
```
http://localhost:3000/api
```

## Authentication
All endpoints are currently public (no authentication required)

## Endpoints

### Jobs

#### 1. Get All Jobs
```http
GET /jobs
```
**Query Parameters:**
- `search`: Search in title, description, requirements, and company
- `type`: Filter by job type (Full-time, Part-time, etc.)
- `location`: Filter by location
- `experience`: Filter by experience level
- `salary`: Filter by salary range (e.g., "50000-100000")
- `postedDate`: Filter by posted date
- `deadline`: Filter by application deadline
- `company`: Filter by company name
- `sortBy`: Sort field (default: "postedDate")
- `sortOrder`: Sort direction (default: "DESC")
- `page`: Page number (default: 1)
- `limit`: Items per page (default: 10)

**Response:**
```json
{
  "jobs": [...],
  "pagination": {
    "total": 100,
    "page": 1,
    "pages": 10,
    "limit": 10
  },
  "locationStats": [...]
}
```

#### 2. Get Today's Jobs
```http
GET /jobs/today
```
**Response:**
```json
{
  "success": true,
  "data": [...]
}
```

#### 3. Get Jobs by Category
```http
GET /jobs/category/:category
```
**Query Parameters:**
- `type`: Filter by job type
- `experience`: Filter by experience level
- `page`: Page number
- `limit`: Items per page

**Response:**
```json
{
  "success": true,
  "data": {
    "jobs": [...],
    "category": "Technology",
    "totalJobs": 50,
    "pagination": {...},
    "statistics": {
      "byType": [...],
      "byExperience": [...],
      "bySalary": [...]
    }
  }
}
```

#### 4. Get Jobs by Tags
```http
GET /jobs/tags
```
**Query Parameters:**
- `tags`: Comma-separated list of tags

**Response:**
```json
{
  "success": true,
  "data": [...]
}
```

#### 5. Get Jobs by Location
```http
GET /jobs/location/:location
```
**Query Parameters:**
- `type`: Filter by job type
- `experience`: Filter by experience level

**Response:**
```json
{
  "jobs": [...],
  "stats": [...]
}
```

#### 6. Get Job by ID
```http
GET /jobs/:id
```
**Response:**
```json
{
  "id": 1,
  "title": "...",
  "company": "...",
  "location": "...",
  "description": "...",
  "requirements": "...",
  "salary": "...",
  "type": "...",
  "experience": "...",
  "postedDate": "...",
  "deadline": "...",
  "category": "...",
  "tags": "...",
  "lovereactions": "..."
}
```

#### 7. Create Job
```http
POST /jobs
```
**Request Body:**
```json
{
  "title": "Job Title",
  "company": "Company Name",
  "location": "Location",
  "description": "Job Description",
  "requirements": "Job Requirements",
  "salary": "Salary Range",
  "type": "Job Type",
  "experience": "Experience Level",
  "category": "Job Category",
  "tags": "tag1,tag2,tag3"
}
```

#### 8. Update Job
```http
PUT /jobs/:id
```
**Request Body:** Same as Create Job

#### 9. Delete Job
```http
DELETE /jobs/:id
```

#### 10. Update Love Reactions
```http
PATCH /jobs/:id/love
```
**Request Body:**
```json
{
  "increment": true
}
```

### Job Applications

#### 1. Submit Application
```http
POST /applications
```
**Request Body:**
```json
{
  "jobId": 1,
  "name": "Applicant Name",
  "email": "email@example.com",
  "phone": "Phone Number",
  "resume": "Resume URL",
  "coverLetter": "Cover Letter Text"
}
```

#### 2. Get Applications for a Job
```http
GET /applications/job/:jobId
```
**Response:**
```json
{
  "success": true,
  "data": [...]
}
```

#### 3. Update Application Status
```http
PATCH /applications/:id/status
```
**Request Body:**
```json
{
  "status": "accepted"
}
```

### Saved Jobs

#### 1. Save Job
```http
POST /saved-jobs
```
**Request Body:**
```json
{
  "jobId": 1,
  "userId": 1
}
```

#### 2. Get Saved Jobs
```http
GET /saved-jobs
```
**Response:**
```json
{
  "success": true,
  "data": [...]
}
```

#### 3. Remove Saved Job
```http
DELETE /saved-jobs/:id
```

## Error Responses
All endpoints may return the following error responses:

```json
{
  "success": false,
  "message": "Error message",
  "error": "Detailed error information"
}
```

Common HTTP Status Codes:
- 200: Success
- 201: Created
- 400: Bad Request
- 404: Not Found
- 500: Internal Server Error

## Example Usage

### Search Jobs
```bash
curl "http://localhost:3000/api/jobs?search=developer&type=Full-time&location=Remote&page=1&limit=10"
```

### Get Jobs by Category
```bash
curl "http://localhost:3000/api/jobs/category/Technology?type=Full-time&experience=Senior%20Level"
```

### Submit Application
```bash
curl -X POST http://localhost:3000/api/applications \
  -H "Content-Type: application/json" \
  -d '{
    "jobId": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "1234567890",
    "resume": "https://example.com/resume.pdf",
    "coverLetter": "I am interested in this position..."
  }'
```

## Available Categories
- Technology
- Marketing
- Data Science
- Design
- Product
- Content
- Sales
- Human Resources

## Job Types
- Full-time
- Part-time
- Contract
- Internship

## Experience Levels
- Entry Level
- Mid Level
- Senior Level

## Tags
Common tags used across jobs:
- Technology: javascript, react, nodejs, aws, python, sql
- Design: ux, ui, figma, prototyping
- Marketing: seo, content, social-media
- Business: sales, negotiation, crm
- Development: mobile, react-native, ios, android
- DevOps: docker, kubernetes, cloud
- Management: leadership, strategy, agile 