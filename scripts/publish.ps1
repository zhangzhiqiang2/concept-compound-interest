# 每日概念 · 发布脚本
# 将本地新增/修改的概念笔记上传到 GitHub
# 用法：.\scripts\publish.ps1

$projectRoot = "D:\learn\concept-compound-interest"
$configPath = Join-Path $projectRoot "scripts" ".env"

# 读取 token
if (Test-Path $configPath) {
    $token = (Get-Content $configPath | Where-Object { $_ -match "^GITHUB_TOKEN=" }) -replace "^GITHUB_TOKEN=", ""
} else {
    Write-Output "⚠️  未找到 token 配置文件"
    Write-Output "请先创建 scripts/.env 文件，内容为："
    Write-Output "  GITHUB_TOKEN=你的token"
    exit 1
}

$repo = "zhangzhiqiang2/concept-compound-interest"
$headers = @{
    Authorization = "token $token"
    "Content-Type" = "application/json"
}

# 获取今天的笔记文件（新文件）
$conceptDir = Join-Path $projectRoot "concepts"
$date = Get-Date -Format "yyyy-MM-dd"
$todayFiles = Get-ChildItem $conceptDir -Filter "$date-*.md"

if ($todayFiles.Count -eq 0) {
    Write-Output "今天还没有新笔记，请先运行 start-day.ps1"
    exit 0
}

# 上传文件到 GitHub
Write-Output "正在上传到 GitHub ..."
Write-Output ""

foreach ($file in $todayFiles) {
    $relativePath = "concepts/$($file.Name)"
    $content = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((Get-Content $file.FullName -Raw)))

    # 先检查文件是否已存在
    try {
        $existing = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/contents/$relativePath" -Headers $headers -Method Get -ErrorAction Stop
        $sha = $existing.sha
        $body = @{
            message = "更新笔记：$($file.BaseName)"
            content = $content
            sha = $sha
            branch = "main"
        } | ConvertTo-Json
    } catch {
        $body = @{
            message = "添加笔记：$($file.BaseName)"
            content = $content
            branch = "main"
        } | ConvertTo-Json
    }

    try {
        Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/contents/$relativePath" -Headers $headers -Body $body -Method Put -ErrorAction Stop | Out-Null
        Write-Output "  ✅ 上传成功：$relativePath"
    } catch {
        Write-Output "  ❌ 上传失败：$relativePath"
        Write-Output "     错误：$($_.Exception.Message)"
    }
}

# 更新 index.md（重新读取本地 index 并上传）
Write-Output ""
Write-Output "正在更新索引 ..."
$indexContent = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((Get-Content (Join-Path $projectRoot "index.md") -Raw)))
try {
    $existingIndex = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/contents/index.md" -Headers $headers -Method Get -ErrorAction Stop
    $body = @{
        message = "更新概念索引"
        content = $indexContent
        sha = $existingIndex.sha
        branch = "main"
    } | ConvertTo-Json
} catch {
    $body = @{
        message = "添加概念索引"
        content = $indexContent
        branch = "main"
    } | ConvertTo-Json
}
try {
    Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/contents/index.md" -Headers $headers -Body $body -Method Put -ErrorAction Stop | Out-Null
    Write-Output "  ✅ 索引已更新"
} catch {
    Write-Output "  ❌ 索引更新失败：$($_.Exception.Message)"
}

Write-Output ""
Write-Output "========================================"
Write-Output "  ✨ 全部完成！"
Write-Output "  查看仓库：https://github.com/$repo"
Write-Output "========================================"
