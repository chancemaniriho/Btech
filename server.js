const express = require('express');
const path = require('path');

const app = express();
const PORT = 3000;

// Serve static files from 'pages' directory
app.use(express.static(path.join(__dirname, 'pages')));

// Routes for each page
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'pages', 'home.html'));
});

app.get('/about', (req, res) => {
    res.sendFile(path.join(__dirname, 'pages', 'about.html'));
});

app.get('/contactus', (req, res) => {
    res.sendFile(path.join(__dirname, 'pages', 'contactus.html'));
});

app.get('/student', (req, res) => {
    res.sendFile(path.join(__dirname, 'pages', 'student.html'));
});

app.get('/dashboard', (req, res) => {
    res.sendFile(path.join(__dirname, 'pages', 'dashboard.html'));
});

app.get('/courses', (req, res) => {
    res.sendFile(path.join(__dirname, 'pages', 'courses.html'));
});

app.get('/grades', (req, res) => {
    res.sendFile(path.join(__dirname, 'pages', 'grades.html'));
});

app.get('/attendance', (req, res) => {
    res.sendFile(path.join(__dirname, 'pages', 'attendance.html'));
});

app.get('/lectures', (req, res) => {
    res.sendFile(path.join(__dirname, 'pages', 'lectures.html'));
});

app.get('/projects', (req, res) => {
    res.sendFile(path.join(__dirname, 'pages', 'projects.html'));
});

// Start server
app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});
