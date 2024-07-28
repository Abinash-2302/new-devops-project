const express = require('express');
const mysql = require('mysql');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const port = 3000;

// Middleware
app.use(bodyParser.json());
app.use(cors({
    origin: 'http://localhost:84', // Replace '*' with your frontend URL in production
       methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
    credentials: true,
}));

// MySQL connection
const dbConfig = {
    host: 'db',
    user: 'root',
    password: 'password',
    database: 'testdb'
};

let db;

function connectWithRetry() {
     db = mysql.createConnection(dbConfig);
    
    db.connect(err => {
        if (err) {
            console.error('Error connecting to MySQL, retrying in 5 seconds...', err);
            setTimeout(connectWithRetry, 5000); // Retry after 5 seconds
        } else {
            console.log('Connected to MySQL');
            // Your existing code here
        }
    });

    db.on('error', (err) => {
        console.error('Database error', err);
        if(err.code === 'PROTOCOL_CONNECTION_LOST') {
            connectWithRetry(); // Reconnect on connection loss
        } else {
            throw err;
        }
    });
}

connectWithRetry();

// API endpoint
app.post('/api/data', (req, res) => {
    const data = req.body.data;
    db.query('INSERT INTO data_table (data) VALUES (?)', [data], (err, result) => {
       if(err){
            console.error('Error inserting data:', err);
            res.status(500).send('Error inserting data');
        } else {
            res.send('Data inserted successfully');
        }
    });
});

app.listen(port,'0.0.0.0', () => {
    console.log(`Server running at http://localhost:${port}`);
});


