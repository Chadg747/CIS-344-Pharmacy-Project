<?php
session_start();


$host = "127.0.0.1";
$port = "3306";
$database = "pharmacy_portal_db";
$user = "root";
$password = "Chga8941.";
$connection = new mysqli($host, $user, $password, $database, $port);

if ($connection->connect_error) {
    die("Connection failed: " . $connection->connect_error);
}


if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $userName = $_POST["userName"];
    $password = $_POST["password"];

    
    $stmt = $connection->prepare("SELECT userId, userType, password FROM Users WHERE userName = ?");
    $stmt->bind_param("s", $userName);
    $stmt->execute();
    $stmt->store_result();
    
    if ($stmt->num_rows > 0) {
        $stmt->bind_result($userId, $userType, $hashedPassword);
        $stmt->fetch();

        
        if (password_verify($password, $hashedPassword)) {
          
            $_SESSION["userId"] = $userId;
            $_SESSION["userType"] = $userType;
            $_SESSION["userName"] = $userName;

           
            if ($userType == "pharmacist") {
                header("Location: pharmacist_dashboard.php");
            } else {
                header("Location: patient_dashboard.php");
            }
            exit;
        } else {
            echo "Invalid username or password.";
        }
    } else {
        echo "User not found.";
    }
    
    $stmt->close();
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Login</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="login-container">
        <h2>Login to Pharmacy Portal</h2>
        
        <?php if (isset($errorMessage)) { echo "<p class='error'>$errorMessage</p>"; } ?>
        
        <form method="POST" action="login.php">
            <label for="userName">Username:</label>
            <input type="text" name="userName" required>
            
            <label for="password">Password:</label>
            <input type="password" name="password" required>
            
            <button type="submit">Login</button>
        </form>

        <p>Don't have an account? <a href="register.php">Register Here</a></p>
    </div>
</body>
</html>