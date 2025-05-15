<?php
$host = "127.0.0.1";
$port = "3306";
$database = "pharmacy_portal_db";
$user = "root";
$password = "Chga8941.";

$connection = new mysqli($host, $user, $password, $database, $port);
if ($connection->connect_error) {
    die("Connection failed: " . $connection->connect_error);
}