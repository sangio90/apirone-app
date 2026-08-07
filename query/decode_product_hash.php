#!/usr/bin/env php
<?php
/**
 * Decodifica un JSON di product_hash leggendo i testi in lingua ITA dal DB.
 *
 * Uso:
 *   php decode_product_hash.php '<json>'
 *   echo '<json>' | php decode_product_hash.php
 *
 * Legge la connessione da .env nella directory padre (o nella stessa).
 */

// ---------- caricamento .env ----------
function loadEnv(string $startDir): array
{
    $dir = $startDir;
    for ($i = 0; $i < 4; $i++) {
        $candidate = $dir . '/.env';
        if (file_exists($candidate)) {
            $vars = [];
            foreach (file($candidate, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
                $line = trim($line);
                if ($line === '' || $line[0] === '#') continue;
                [$k, $v] = array_pad(explode('=', $line, 2), 2, '');
                $vars[trim($k)] = trim($v);
            }
            return $vars;
        }
        $dir = dirname($dir);
    }
    fwrite(STDERR, "Errore: file .env non trovato.\n");
    exit(1);
}

$env = loadEnv(__DIR__);

// Permetti di sovrascrivere l'host da CLI: --host 127.0.0.1
$cliHost = null;
foreach ($argv as $i => $arg) {
    if ($arg === '--host' && isset($argv[$i + 1])) {
        $cliHost = $argv[$i + 1];
        unset($argv[$i], $argv[$i + 1]);
        $argv = array_values($argv);
        break;
    }
}

$dbHost = $cliHost ?? $env['db.host'] ?? 'localhost';

$dsn  = sprintf(
    'pgsql:host=%s;port=%s;dbname=%s',
    $dbHost,
    $env['db.port'] ?? '5432',
    $env['db.name'] ?? ''
);
$user = $env['db.username'] ?? '';
$pass = $env['db.pwd']      ?? '';

try {
    $pdo = new PDO($dsn, $user, $pass, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
} catch (PDOException $e) {
    fwrite(STDERR, "Connessione DB fallita: " . $e->getMessage() . "\n");
    exit(1);
}

// ---------- lettura JSON da argv o stdin ----------
if (isset($argv[1]) && trim($argv[1]) !== '') {
    $raw = $argv[1];
} else {
    $raw = stream_get_contents(STDIN);
}

$data = json_decode(trim($raw), true);
if ($data === null) {
    fwrite(STDERR, "JSON non valido: " . json_last_error_msg() . "\n");
    exit(1);
}

// ---------- helper: testo ITA dal campo texts ----------
function text(PDO $pdo, string $field, $value, string $kind = null): string
{
    if (empty($value) && $value !== 0) return '(vuoto)';

    $kindClause = $kind ? "AND text_kind_id = :kind" : "";
    $sql = "SELECT text FROM texts
            WHERE {$field} = :val AND lang_id = 'IT' {$kindClause}
            ORDER BY text_id
            LIMIT 1";
    $st = $pdo->prepare($sql);
    $st->bindValue(':val', $value);
    if ($kind) $st->bindValue(':kind', $kind);
    $st->execute();
    $row = $st->fetch(PDO::FETCH_ASSOC);
    return $row ? $row['text'] : "(testo non trovato per {$field}={$value})";
}

function textCategory(PDO $pdo, int $id): string
{
    $st = $pdo->prepare("SELECT text FROM texts
                         WHERE product_category_id = :id AND lang_id = 'IT'
                         ORDER BY text_id LIMIT 1");
    $st->execute([':id' => $id]);
    $row = $st->fetch(PDO::FETCH_ASSOC);
    return $row ? $row['text'] : "(categoria non trovata id={$id})";
}

function textProductItem(PDO $pdo, int $productItemId): string
{
    // product_items → attributes_raw_values → raw_values → texts (ITA)
    $sql = "SELECT t.text
            FROM product_items pi
            JOIN attributes_raw_values arv USING (attribute_raw_value_id)
            JOIN texts t ON t.raw_value_id = arv.raw_value_id
            WHERE pi.product_item_id = :id
              AND t.lang_id = 'IT'
            ORDER BY t.text_id
            LIMIT 1";
    $st = $pdo->prepare($sql);
    $st->execute([':id' => $productItemId]);
    $row = $st->fetch(PDO::FETCH_ASSOC);
    return $row ? $row['text'] : "(testo non trovato per productItemId={$productItemId})";
}

// ---------- decodifica ----------
$out = [];

if (isset($data['categoryId'])) {
    $out['categoria'] = textCategory($pdo, (int)$data['categoryId']);
}

if (isset($data['lineId'])) {
    $out['linea'] = text($pdo, 'line_id', $data['lineId']);
}

if (isset($data['modelId'])) {
    $out['modello'] = text($pdo, 'model_id', $data['modelId']);
}

if (isset($data['finishId'])) {
    $out['finitura'] = text($pdo, 'finish_id', $data['finishId']);
}

if (isset($data['productId'])) {
    // I prodotti non hanno sempre un testo proprio in texts — fallback al serial
    $st = $pdo->prepare("SELECT text FROM texts WHERE product_id = :id AND lang_id = 'IT' ORDER BY text_id LIMIT 1");
    $st->execute([':id' => $data['productId']]);
    $row = $st->fetch(PDO::FETCH_ASSOC);
    if ($row) {
        $out['prodotto'] = $row['text'];
    } else {
        $st2 = $pdo->prepare("SELECT serial, code FROM products WHERE product_id = :id");
        $st2->execute([':id' => $data['productId']]);
        $p = $st2->fetch(PDO::FETCH_ASSOC);
        $out['prodotto'] = $p
            ? ($p['code'] ?: 'serial #' . $p['serial'])
            : '(non trovato)';
    }
}

if (!empty($data['productItems'])) {
    $items = [];
    foreach ($data['productItems'] as $pi) {
        $id   = (int)$pi['productItemId'];
        $note = $pi['note'] ?? '';
        $label = textProductItem($pdo, $id);
        $items[] = [
            'productItemId' => $id,
            'descrizione'   => $label,
            'note'          => $note,
        ];
    }
    $out['articoli'] = $items;
}

foreach (['special', 'note'] as $k) {
    if (array_key_exists($k, $data)) {
        $out[$k] = $data[$k];
    }
}

// ---------- output ----------
echo json_encode($out, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "\n";
