#!/usr/bin/env php
<?php
/**
 * Estrae, per le categorie prodotto PLACCHE e FRUTTI, tutti gli attributi
 * configurabili con l'elenco completo dei loro possibili valori (testi IT).
 *
 * Uso:
 *   php estrai_attributi_placche_frutti.php [--json out.json] [--csv out.csv] [--host 127.0.0.1]
 *
 * Se non vengono passati --json/--csv, scrive entrambi i file di default
 * (attributi_placche_frutti.json / .csv) nella stessa cartella dello script.
 *
 * Legge la connessione da .env nella directory padre (o nella stessa),
 * stesso meccanismo di decode_product_hash.php.
 */

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

// ---------- parsing argomenti ----------
$options = [
    'json' => null,
    'csv'  => null,
    'host' => null,
];
$args = $argv;
array_shift($args);
for ($i = 0; $i < count($args); $i++) {
    $arg = $args[$i];
    if (in_array($arg, ['--json', '--csv', '--host'], true) && isset($args[$i + 1])) {
        $options[substr($arg, 2)] = $args[$i + 1];
        $i++;
    }
}
if ($options['json'] === null && $options['csv'] === null) {
    $options['json'] = __DIR__ . '/attributi_placche_frutti.json';
    $options['csv']  = __DIR__ . '/attributi_placche_frutti.csv';
}

$dbHost = $options['host'] ?? $env['db.host'] ?? 'localhost';

$dsn = sprintf(
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

// PLACCHE = product_category_id 22, FRUTTI = product_category_id 167
$categoryIds = [22, 167];

$sql = "
    SELECT
        pc_t.text            AS categoria,
        a.code                AS attributo_code,
        a_t.text              AS attributo_nome,
        arv.attribute_raw_value_id,
        rv.code                AS valore_code,
        rv_t.text              AS valore_nome,
        arv.orderby
    FROM attributes a
    JOIN texts a_t
        ON a_t.attribute_id = a.attribute_id AND a_t.lang_id = 'IT' AND a_t.text_kind_id = 'NAME'
    JOIN attributes_raw_values arv
        ON arv.attribute_id = a.attribute_id AND arv.status_id = 'ACT'
    JOIN raw_values rv
        ON rv.raw_value_id = arv.raw_value_id
    JOIN texts rv_t
        ON rv_t.raw_value_id = rv.raw_value_id AND rv_t.lang_id = 'IT' AND rv_t.text_kind_id = 'NAME'
    CROSS JOIN LATERAL jsonb_array_elements_text(a.categories) cat(id)
    JOIN product_categories pc
        ON pc.product_category_id = cat.id::int
    JOIN texts pc_t
        ON pc_t.product_category_id = pc.product_category_id AND pc_t.lang_id = 'IT' AND pc_t.text_kind_id = 'NAME'
    WHERE a.status_id = 'ACT'
        AND jsonb_typeof(a.categories) = 'array'
        AND pc.product_category_id = ANY(:categoryIds)
    ORDER BY pc_t.text, a.code, arv.orderby
";

$st = $pdo->prepare($sql);
$st->bindValue(':categoryIds', '{' . implode(',', $categoryIds) . '}');
$st->execute();
$rows = $st->fetchAll(PDO::FETCH_ASSOC);

if (!$rows) {
    fwrite(STDERR, "Nessun dato trovato.\n");
    exit(1);
}

// ---------- struttura raggruppata: categoria > attributo > valori[] ----------
$grouped = [];
foreach ($rows as $r) {
    $cat = $r['categoria'];
    $attrCode = $r['attributo_code'];

    if (!isset($grouped[$cat])) {
        $grouped[$cat] = [];
    }
    if (!isset($grouped[$cat][$attrCode])) {
        $grouped[$cat][$attrCode] = [
            'attributo_code' => $attrCode,
            'attributo_nome' => $r['attributo_nome'],
            'valori'         => [],
        ];
    }
    $grouped[$cat][$attrCode]['valori'][] = [
        'valore_code' => $r['valore_code'],
        'valore_nome' => $r['valore_nome'],
    ];
}

$output = [];
foreach ($grouped as $cat => $attrs) {
    $output[] = [
        'categoria' => $cat,
        'attributi' => array_values($attrs),
    ];
}

// ---------- JSON ----------
if ($options['json'] !== null) {
    file_put_contents(
        $options['json'],
        json_encode($output, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES)
    );
    fwrite(STDOUT, "Scritto: {$options['json']}\n");
}

// ---------- CSV (una riga per ogni coppia attributo/valore) ----------
if ($options['csv'] !== null) {
    $fh = fopen($options['csv'], 'w');
    fputcsv($fh, ['categoria', 'attributo_code', 'attributo_nome', 'valore_code', 'valore_nome'], ';');
    foreach ($rows as $r) {
        fputcsv($fh, [
            $r['categoria'],
            $r['attributo_code'],
            $r['attributo_nome'],
            $r['valore_code'],
            $r['valore_nome'],
        ], ';');
    }
    fclose($fh);
    fwrite(STDOUT, "Scritto: {$options['csv']}\n");
}
