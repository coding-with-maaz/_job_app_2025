const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  {
    host: process.env.DB_HOST,
    dialect: 'mysql',
    logging: false,
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000
    },
    dialectOptions: {
      connectTimeout: 60000
    },
    retry: {
      max: 3,
      backoffBase: 1000,
      backoffExponent: 1.5
    }
  }
);

const connectDB = async () => {
  let retries = 3;
  while (retries > 0) {
    try {
      await sequelize.authenticate();
      console.log('Database connection has been established successfully.');
      
      await sequelize.sync({ alter: true });
      console.log('Database models synchronized.');
      return;
    } catch (error) {
      retries--;
      console.error(`Database connection attempt ${4 - retries} failed:`, error.message);
      
      if (retries === 0) {
        console.error('Unable to connect to the database after multiple attempts:', error);
        process.exit(1);
      }
      
      await new Promise(resolve => setTimeout(resolve, 5000));
    }
  }
};

connectDB().catch(err => {
  console.error('Failed to connect to database:', err);
  process.exit(1);
});

module.exports = { sequelize, connectDB }; 