# har_pal_jobs

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


- Flutter SDK
- Dart SDK
- Node.js (for backend)
- MySQL Database

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/har_pal_jobs.git
```

2. Install Flutter dependencies:
```bash
cd har_pal_jobs
flutter pub get
```

3. Install backend dependencies:
```bash
cd backend
npm install
```

4. Set up environment variables:
Create a `.env` file in the backend directory with:
```
DB_HOST=localhost
DB_USER=your_username
DB_PASSWORD=your_password
DB_NAME=harpal_jobs
PORT=3000
```

5. Run the backend server:
```bash
cd backend
npm start
```

6. Run the Flutter app:
```bash
cd har_pal_jobs
flutter run
```

## API Documentation

### Base URL
```
http://localhost:3000/api
```

### Authentication
All endpoints are currently public (no authentication required)

### Endpoints

#### Jobs

##### 1. Get All Jobs
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

##### 2. Get Today's Jobs
```http
GET /jobs/today
```

##### 3. Get Jobs by Category
```http
GET /jobs/category/:category
```

##### 4. Get Jobs by Tags
```http
GET /jobs/tags
```

##### 5. Get Jobs by Location
```http
GET /jobs/location/:location
```

##### 6. Get Job by ID
```http
GET /jobs/:id
```

##### 7. Create Job
```http
POST /jobs
```

##### 8. Update Job
```http
PUT /jobs/:id
```

##### 9. Delete Job
```http
DELETE /jobs/:id
```

##### 10. Update Love Reactions
```http
PATCH /jobs/:id/love
```

#### Job Applications

##### 1. Submit Application
```http
POST /applications
```

##### 2. Get Applications for a Job
```http
GET /applications/job/:jobId
```

##### 3. Update Application Status
```http
PATCH /applications/:id/status
```

#### Saved Jobs

##### 1. Save Job
```http
POST /saved-jobs
```

##### 2. Get Saved Jobs
```http
GET /saved-jobs
```

##### 3. Remove Saved Job
```http
DELETE /saved-jobs/:id
```

### Available Categories
- Technology
- Marketing
- Data Science
- Design
- Product
- Content
- Sales
- Human Resources

### Job Types
- Full-time
- Part-time
- Contract
- Internship

### Experience Levels
- Entry Level
- Mid Level
- Senior Level

### Tags
Common tags used across jobs:
- Technology: javascript, react, nodejs, aws, python, sql
- Design: ux, ui, figma, prototyping
- Marketing: seo, content, social-media
- Business: sales, negotiation, crm
- Development: mobile, react-native, ios, android
- DevOps: docker, kubernetes, cloud
- Management: leadership, strategy, agile

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.