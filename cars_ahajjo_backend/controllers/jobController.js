const JobPost = require('../models/jobPost');
const User = require('../models/user');

exports.createJobPost = async (req, res) => {
  try {
    const {
      title,
      description,
      carModel,
      location,
      salary,
      salaryType,
      jobType,
      experience,
      licenseType,
      workingHours,
      requirements,
      perks,
      expiryDate,
    } = req.body;
    const ownerId = req.user.id;

    // Normalize enums and lists so UI variations don't break validation
    const normalizedSalaryType = (salaryType || '').toString().trim().toLowerCase();
    const normalizedJobType = (jobType || '').toString().trim().toLowerCase().replace(/\s+/g, '_').replace(/-/g, '_');
    const finalSalaryType = ['monthly', 'daily', 'hourly'].includes(normalizedSalaryType)
      ? normalizedSalaryType
      : undefined;
    const finalJobType = ['full_time', 'part_time', 'contract'].includes(normalizedJobType)
      ? normalizedJobType
      : undefined;

    const workingHoursArray = Array.isArray(workingHours)
      ? workingHours
      : workingHours
          ? [workingHours.toString()]
          : [];

    const job = new JobPost({
      ownerId,
      title,
      description,
      carModel,
      location,
      salary,
      salaryType: finalSalaryType,
      jobType: finalJobType,
      experience,
      licenseType,
      workingHours: workingHoursArray,
      requirements,
      perks,
      postedAt: new Date(),
      expiryDate: expiryDate ? new Date(expiryDate) : new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
    });

    await job.save();

    req.io.emit('job_posted', {
      jobId: job._id,
      title,
      salary,
      location,
    });

    res.status(201).json({
      success: true,
      message: 'Job posted successfully',
      data: job,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error creating job post',
      error: error.message,
    });
  }
};

// Get all job posts
exports.getJobPosts = async (req, res) => {
  try {
    const { status = 'open' } = req.query;

    const jobs = await JobPost.find({ status })
      .populate('ownerId', 'name email phone')
      .sort({ postedAt: -1 });

    res.status(200).json({ success: true, data: jobs });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching jobs',
      error: error.message,
    });
  }
};

// Get job post details
exports.getJobPost = async (req, res) => {
  try {
    const { jobId } = req.params;

    const job = await JobPost.findById(jobId).populate('ownerId', 'name email phone');

    if (!job) {
      return res.status(404).json({ success: false, message: 'Job not found' });
    }

    res.status(200).json({ success: true, data: job });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching job',
      error: error.message,
    });
  }
};

// Apply for a job (driver)
exports.applyForJob = async (req, res) => {
  try {
    const { jobId } = req.params;
    const driverId = req.user.id;

    const job = await JobPost.findById(jobId);
    if (!job) {
      return res.status(404).json({ success: false, message: 'Job not found' });
    }

    // Check if already applied
    const alreadyApplied = job.applicants.some((a) => a.driverId.toString() === driverId);
    if (alreadyApplied) {
      return res.status(400).json({ success: false, message: 'Already applied for this job' });
    }

    job.applicants.push({
      driverId,
      appliedAt: new Date(),
      status: 'pending',
    });

    await job.save();

    req.io.emit('job_application', {
      jobId: job._id,
      driverId,
      ownerMessage: `New application for ${job.title}`,
    });

    res.status(200).json({
      success: true,
      message: 'Application submitted',
      data: job,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error applying for job',
      error: error.message,
    });
  }
};

// Get driver's applications
exports.getApplications = async (req, res) => {
  try {
    const driverId = req.user.id;

    const jobs = await JobPost.find({ 'applicants.driverId': driverId })
      .populate('ownerId', 'name email phone')
      .sort({ 'applicants.appliedAt': -1 });

    res.status(200).json({ success: true, data: jobs });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching applications',
      error: error.message,
    });
  }
};


exports.updateApplicationStatus = async (req, res) => {
  try {
    const { jobId, driverId } = req.params;
    const { status, notes } = req.body;
    const ownerId = req.user.id;

    const job = await JobPost.findById(jobId);
    if (!job || job.ownerId.toString() !== ownerId) {
      return res.status(403).json({ success: false, message: 'Unauthorized' });
    }

    const applicant = job.applicants.find((a) => a.driverId.toString() === driverId);
    if (!applicant) {
      return res.status(404).json({ success: false, message: 'Application not found' });
    }

    applicant.status = status;
    if (notes) applicant.notes = notes;

    if (status === 'accepted') {
      job.status = 'filled';
      job.selectedDriver = driverId;
    }

    await job.save();

    req.io.emit('application_status_updated', {
      jobId: job._id,
      driverId,
      status,
      message: `Your application status: ${status}`,
    });

    res.status(200).json({
      success: true,
      message: 'Application status updated',
      data: job,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error updating application',
      error: error.message,
    });
  }
};


exports.closeJobPost = async (req, res) => {
  try {
    const { jobId } = req.params;
    const ownerId = req.user.id;

    const job = await JobPost.findById(jobId);
    if (!job || job.ownerId.toString() !== ownerId) {
      return res.status(403).json({ success: false, message: 'Unauthorized' });
    }

    job.status = 'closed';
    await job.save();

    res.status(200).json({
      success: true,
      message: 'Job post closed',
      data: job,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error closing job',
      error: error.message,
    });
  }
};
