<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test stránka SLI0124</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f0f0f0;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 { color: #333; }
        .info {
            background: #e3f2fd;
            padding: 15px;
            border-radius: 5px;
            margin: 10px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🧪 Test stránka SLI0124</h1>

        <div class="info">
            <h2>Server Info:</h2>
            <p><strong>Aktuální čas:</strong> <?php echo date('d.m.Y H:i:s'); ?></p>
            <p><strong>Server IP:</strong> <?php echo $_SERVER['SERVER_ADDR']; ?></p>
            <p><strong>PHP verze:</strong> <?php echo phpversion(); ?></p>
            <p><strong>Vaše IP:</strong> <?php echo $_SERVER['REMOTE_ADDR']; ?></p>
        </div>

        <div class="info">
            <h2>PHP Test:</h2>
            <?php
            $cisla = [1, 2, 3, 4, 5];
            $soucet = array_sum($cisla);
            echo "<p>Součet čísel " . implode(", ", $cisla) . " = <strong>$soucet</strong></p>";
            ?>
        </div>
    </div>
</body>
</html>