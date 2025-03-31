const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const { connectDB, sequelize } = require('./config/db');
const jobRoutes = require('./routes/jobRoutes');
const dashboardRoutes = require('./routes/dashboardRoutes');
const jobApplicationRoutes = require('./routes/jobApplicationRoutes');
const savedJobRoutes = require('./routes/savedJobRoutes');

// Load environment variables
dotenv.config();

// Connect to MySQL database
connectDB();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/jobs', jobRoutes);
app.use('/api/applications', jobApplicationRoutes);
app.use('/api/saved-jobs', savedJobRoutes);
app.use('/api/dashboard', dashboardRoutes);

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

const PORT = process.env.PORT || 5000;

// Test database connection and start server
sequelize.authenticate()
  .then(() => {
    console.log('Database connection established successfully.');
    app.listen(PORT, () => {
      console.log(`Server is running on port ${PORT}`);
    });
  })
  .catch(err => {
    console.error('Unable to connect to the database:', err);
  }); 