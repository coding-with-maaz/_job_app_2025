const multer = require('multer');
const path = require('path');
const sharp = require('sharp');
const fs = require('fs').promises;

// Configure storage
const storage = multer.memoryStorage();

// File filter
const fileFilter = (req, file, cb) => {
  // Accept images only
  if (file.mimetype.startsWith('image/')) {
    cb(null, true);
  } else {
    cb(new Error('Not an image! Please upload an image.'), false);
  }
};

// Create multer upload instance
const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB limit for original file
  }
});

// Function to compress image
const compressImage = async (buffer, filename) => {
  try {
    // Create uploads directory if it doesn't exist
    const uploadDir = path.join(__dirname, '..', 'uploads', 'jobs');
    await fs.mkdir(uploadDir, { recursive: true });

    const outputPath = path.join(uploadDir, filename);
    
    // Compress image to 50KB
    await sharp(buffer)
      .resize(800, 800, { // Resize to reasonable dimensions
        fit: 'inside',
        withoutEnlargement: true
      })
      .jpeg({ // Convert to JPEG format
        quality: 60,
        progressive: true
      })
      .toFile(outputPath);

    return filename;
  } catch (error) {
    console.error('Error compressing image:', error);
    throw error;
  }
};

// Middleware to handle image compression
const compressImageMiddleware = async (req, res, next) => {
  if (!req.file) {
    return next();
  }

  try {
    const filename = `image-${Date.now()}-${Math.round(Math.random() * 1E9)}.jpg`;
    const compressedFilename = await compressImage(req.file.buffer, filename);
    req.file.filename = compressedFilename;
    next();
  } catch (error) {
    next(error);
  }
};

module.exports = {
  upload,
  compressImageMiddleware
}; 