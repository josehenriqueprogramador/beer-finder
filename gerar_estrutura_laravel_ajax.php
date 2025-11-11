<?php
ini_set('memory_limit', '-1'); // sem limite de memória
$baseDir = __DIR__; // raiz do projeto Laravel

// Se receber um arquivo via GET, retorna o conteúdo
if (isset($_GET['file'])) {
    $file = $_GET['file'];
    if (file_exists($file)) {
        $ext = strtolower(pathinfo($file, PATHINFO_EXTENSION));
        $textExt = ['php','js','css','blade.php','env','json','html','txt'];
        if (in_array($ext, $textExt)) {
            header('Content-Type: text/plain; charset=UTF-8');
            echo file_get_contents($file);
        } else {
            echo "[conteúdo não exibido]";
        }
    } else {
        echo "[arquivo não encontrado]";
    }
    exit;
}

// Função para gerar árvore de diretórios
function listFilesAllLevels($dir) {
    $result = [];
    $items = scandir($dir);
    foreach ($items as $item) {
        if ($item === '.' || $item === '..') continue;
        $path = $dir . DIRECTORY_SEPARATOR . $item;
        if (is_dir($path)) {
            $result[$item] = listFilesAllLevels($path);
        } else {
            $result[] = $path;
        }
    }
    return $result;
}

// Função para gerar HTML da árvore
function generateHTMLTree($files, $level = 0) {
    $html = "<ul style='list-style:none;padding-left:" . ($level*20) . "px;'>";
    foreach ($files as $key => $value) {
        if (is_array($value)) {
            $html .= "<li><span class='folder' onclick='toggleFolder(this)'>📁 " . htmlspecialchars($key) . "</span>";
            $html .= generateHTMLTree($value, $level+1);
            $html .= "</li>";
        } else {
            $filename = basename($value);
            $html .= "<li><span class='file' onclick='loadFile(this,\"$value\")'>📄 $filename</span>";
            $html .= "<pre class='file-content' style='display:none; margin-top:5px;'></pre>";
            $html .= "</li>";
        }
    }
    $html .= "</ul>";
    return $html;
}

$structure = listFilesAllLevels($baseDir);
$html = "<!DOCTYPE html>
<html lang='pt-br'>
<head>
<meta charset='UTF-8'>
<title>Estrutura Interativa Laravel</title>
<style>
body { font-family: Arial, sans-serif; padding: 20px; background: #fefefe; color: #333; }
ul { margin:0; padding:0; }
li { margin:2px 0; }
.folder { cursor: pointer; font-weight: bold; color: #007bff; }
.file { cursor: pointer; color: #555; }
pre { background:#f4f4f4; padding:10px; border:1px solid #ccc; overflow:auto; border-radius:4px; white-space: pre-wrap; word-break: break-word; }
</style>
</head>
<body>
<h1>📂 Estrutura Interativa do Projeto Laravel</h1>
<p>Clique nas pastas para expandir/contrair. Clique nos arquivos para carregar o conteúdo dinamicamente.</p>
" . generateHTMLTree($structure) . "
<script>
function toggleFolder(el) {
    let next = el.nextElementSibling;
    if (!next) return;
    next.style.display = (next.style.display==='none'||next.style.display==='')?'block':'none';
}

function loadFile(el, path) {
    let pre = el.nextElementSibling;
    if (!pre) return;
    if (pre.innerHTML) { // se já carregado, alterna visibilidade
        pre.style.display = (pre.style.display==='none'||pre.style.display==='')?'block':'none';
        return;
    }
    pre.innerHTML = 'Carregando...';
    pre.style.display = 'block';
    fetch('?file='+encodeURIComponent(path))
    .then(resp=>resp.text())
    .then(data=>{
        pre.textContent = data;
    })
    .catch(err=>{
        pre.textContent = '[erro ao carregar arquivo]';
    });
}
</script>
</body>
</html>";

file_put_contents('estrutura_interativa_laravel.html', $html);
echo "✅ HTML interativo gerado em 'estrutura_interativa_laravel.html'!\n";
