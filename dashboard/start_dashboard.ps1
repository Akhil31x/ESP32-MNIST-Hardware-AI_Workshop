Set-Location $PSScriptRoot

Write-Host "======================================"
Write-Host " ESP32 MNIST Hardware AI Dashboard"
Write-Host "======================================"
Write-Host ""

python -m pip install -r requirements.txt

Write-Host ""
Write-Host "Starting dashboard..."
Write-Host ""

python -m streamlit run app.py
