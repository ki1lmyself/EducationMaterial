<?php
include_once 'connection.php';

$connection = mysqli_connect($host, $user, $password, $database);
if (!$connection) {
    die("Ошибка подключения: " . mysqli_connect_error());
}

$sortBy = 'name';

$query = "SELECT * FROM games";
$conditions = [];

if (!empty($_GET['price']) && is_numeric($_GET['price'])) {
    $price = (float)$_GET['price'];
    $conditions[] = "price <= $price";
}

if (!empty($_GET['name'])) {
    $name = mysqli_real_escape_string($connection, $_GET['name']);
    $conditions[] = "name LIKE '%$name%'";
}

if (!empty($_GET['description'])) {
    $description = mysqli_real_escape_string($connection, $_GET['description']);
    $conditions[] = "description LIKE '%$description%'";
}

if (count($conditions) > 0) {
    $query .= " WHERE " . implode(' AND ', $conditions);
}

if (isset($_GET['sortBy']) && in_array($_GET['sortBy'], ['name', 'description', 'price'])) {
    $sortBy = $_GET['sortBy'];
    $query .= " ORDER BY $sortBy";
}

$result = mysqli_query($connection, $query);
?>

<form action="showTable.php" method="GET">
    <label><input type="radio" name="sortBy" value="name" checked="checked" <?php if ($sortBy == 'name') echo 'checked'; ?>> По названию</label>
    <label><input type="radio" name="sortBy" value="price" <?php if ($sortBy == 'price') echo 'checked'; ?>> По цене</label>
    <button type="submit">Сортировать</button>
</form>

<form action="showTable.php" method="GET">
    <label for="name">Название содержит:</label>
    <input type="text" id="name" name="name" value="<?php echo isset($_GET['name']) ? htmlspecialchars($_GET['name']) : ''; ?>">

    <label for="description">Описание содержит:</label>
    <input type="text" id="description" name="description" value="<?php echo isset($_GET['description']) ? htmlspecialchars($_GET['description']) : ''; ?>">

    <label for="price">Цена до:</label>
    <input type="text" id="price" name="price" value="<?php echo isset($_GET['price']) ? htmlspecialchars($_GET['price']) : ''; ?>">

    <input type="submit" value="Фильтровать">
</form>

<?php
if (mysqli_num_rows($result) > 0) {
    echo "<table border='1'>
    <thead>
    <th><a href='showTable.php?sortBy=name'>Название</a></th>
    <th><a href='showTable.php?sortBy=description'>Описание</a></th>
    <th style='width:80px;'><a href='showTable.php?sortBy=price'>Цена</a></th>
    </thead>
    <tbody>";

    while ($row = mysqli_fetch_assoc($result)) {
        echo "<tr>
        <td>" . ($row['name']) . "</td>
        <td>" . ($row['description']) . "</td>
        <td>" . number_format($row['price'], 2, ',', ' ') . " ₽</td>
        </tr>";
    }
    echo "</tbody>
    </table>";
} else {
    ?>
    Товары не найдены.
    <?
}

$connection->close();   
?>
