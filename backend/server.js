const express = require('express');
const mysql = require('mysql');
const bodyParser = require('body-parser');

const app = express();
app.use(bodyParser.json());

const db = mysql.createConnection({
    host: 'mysql',
    user: 'root',
    password: 'password',
    database: 'testdb'
});

db.connect((err) => {
    if (err) throw err;
    console.log('Connected to database');
    const createTableQuery = `CREATE TABLE IF NOT EXISTS users (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255), age INT)`;
    db.query(createTableQuery, (err) => {
        if (err) throw err;
    });
});

app.post('/add', (req, res) => {
    const { name, age } = req.body;
    const query = 'INSERT INTO users (name, age) VALUES (?, ?)';
    db.query(query, [name, age], (err, results) => {
        if (err) throw err;
        res.json({ id: results.insertId, name, age });
    });
});

app.listen(3000, () => {
    console.log('Backend server running on port 3000');
});
