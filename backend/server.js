const express = require('express');
const mysql = require('mysql');
const bodyParser = require('body-parser');
const app = express();
const port = 3000;

// Database connection
const db = mysql.createConnection({
    host: 'db',
    user: 'root',
    password: 'example',
    database: 'testdb'
});

db.connect(err => {
    if (err) {
        throw err;
    }
    console.log('MySQL connected...');
});

app.use(bodyParser.json());

// Add user route
app.post('/addUser', (req, res) => {
    const user = { name: req.body.name, email: req.body.email };
    const sql = 'INSERT INTO users SET ?';
    db.query(sql, user, (err, result) => {
        if (err) throw err;
        res.send('User added...');
    });
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
