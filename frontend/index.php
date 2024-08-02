<?php
$servername = getenv('DB_HOST');
$username = "root";
$password = "rootpassword";
$dbname = "testdb";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
$success = false;

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $name = $_POST['name'];
    $email = $_POST['email'];
    $age = $_POST['age'];
    $description = $_POST['description'];
     echo "Received data: Name - $name, Email - $email, Age - $age, Description - $description<br>";
    $sql = "INSERT INTO users (name, email, age, description) VALUES ('$name', '$email', '$age', '$description')";

    if ($conn->query($sql) === TRUE) {
         $success = true;
    } else {
        echo "Error: " . $sql . "<br>" . $conn->error;
    }
}

$conn->close();
?>

<!DOCTYPE html>
<html>
<body>
<style>
body {
    font-family: Arial, sans-serif;
    background-color: #f2f2f2;
    margin: 0;
    padding: 0;
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
}

.container {
    background-color: #fff;
    padding: 20px;
    border-radius: 5px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    width: 50%;
    max-width: 600px;
    box-sizing: border-box;
    text-align: center;
}

h1, h2 {
    text-align: center;
}

input[type=text], input[type=email], input[type=number], textarea {
    width: 100%;
    padding: 12px;
    margin: 8px 0;
    display: inline-block;
    border: 1px solid #ccc;
    border-radius: 4px;
    box-sizing: border-box;
}

input[type=submit] {
    width: 100%;
    background-color: #4CAF50;
    color: white;
    padding: 14px 20px;
    margin: 8px 0;
    border: none;
    border-radius: 4px;
    cursor: pointer;
}

input[type=submit]:hover {
    background-color: #45a049;
}
</style>
<script>
function showAlert(success) {
    if (success) {
        alert(" record submitted successfully!");
    }
}
</script>
</head>
<body>

<div class="container">
    <h1>Contact us form</h1>
    <h2>Enter Details</h2>
<form method="post" action="<?php echo $_SERVER['PHP_SELF'];?>">
  Name: <input type="text" name="name" required>
  <br><br>
  E-mail: <input type="email" name="email" required>
  <br><br>
  Age: <input type="number" name="age" required>
  <br><br>
  Description: <textarea name="description" required></textarea>
  <br><br>
  <input type="submit">
</form>
</div>
</body>
</html>
