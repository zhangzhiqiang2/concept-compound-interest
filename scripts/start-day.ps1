# 每日概念 · 启动脚本
# 每天早上 8:30 运行这个脚本，开始今天的概念学习
# 用法：.\scripts\start-day.ps1

$projectRoot = "D:\learn\concept-compound-interest"
$date = Get-Date -Format "yyyy-MM-dd"
$conceptDir = Join-Path $projectRoot "concepts"
$templatePath = Join-Path $projectRoot "templates" "concept-template.md"

Write-Output ""
Write-Output "========================================"
Write-Output "  📖 每日概念 · $date"
Write-Output "========================================"
Write-Output ""

# 检查今天是否已经有笔记
$existingFiles = Get-ChildItem $conceptDir -Filter "$date-*.md"
if ($existingFiles.Count -gt 0) {
    Write-Output "⚠️  今天已经有一篇笔记了："
    $existingFiles | ForEach-Object { Write-Output "   - $($_.Name)" }
    Write-Output ""
    Write-Output "是否要（1）打开已有笔记  （2）创建新笔记 ？"
    $choice = Read-Host "输入 1 或 2（默认 1）"
    if ($choice -eq "2") {
        $conceptName = Read-Host "输入今天要学的概念名称"
        $newFile = Join-Path $conceptDir "$date-$conceptName.md"
        Copy-Item $templatePath $newFile
        Write-Output "✅ 已创建：$($newFile)"
    } else {
        $newFile = $existingFiles[0].FullName
    }
} else {
    Write-Output "今天还没学新概念。"
    $conceptName = Read-Host "输入今天要学的概念名称"
    $newFile = Join-Path $conceptDir "$date-$conceptName.md"
    Copy-Item $templatePath $newFile
    Write-Output "✅ 已创建：$($newFile)"
}

Write-Output ""
Write-Output "现在打开笔记，开始你的学习吧！"
Write-Output ""

# 用默认编辑器打开
Start-Process $newFile

Write-Output "写完后，运行以下命令上传到 GitHub："
Write-Output "  .\scripts\publish.ps1"
Write-Output ""
