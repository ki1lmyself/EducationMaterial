<?php
include_once 'connection.php';

$connection = mysqli_connect($host, $user, $password, $database);

if (!$connection) {
    die("Ошибка подключения: " . mysqli_connect_error());
}

$N = 3;

$sqlCount = "SELECT COUNT(*) as totalNumerRow FROM games";
$resultCount = $connection->query($sqlCount);
$rowCount = $resultCount->fetch_assoc();
$totalItems = (int)$rowCount['totalNumerRow'];

$totalPages = ceil($totalItems / $N);

$page = isset($_GET['page']) && is_numeric($_GET['page']) ? (int)$_GET['page'] : 1;

if ($page < 1) $page = 1;
if ($page > $totalPages) $page = $totalPages;

$offset = ($page - 1) * $N;

$query = "SELECT name, description, price FROM games LIMIT $offset, $N";
$result = mysqli_query($connection, $query);
?>

<?php
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        echo "<h3>" . ($row['name']) . "</h3>
        <p>" . ($row['description']) . "</p>
        <p>Цена: " . number_format($row['price'], 2, ',', ' ') . " ₽</p>";
    }
} else {
    ?>
    Товары не найдены.
    <?
}

for ($i = 1; $i <= $totalPages; $i++) {
    if ($i == $page) {
        echo "<strong>$i</strong> ";
    } else {
        echo "<a href='showList.php?page=$i'>$i</a> ";
    }
}

$connection->close();
?>
