# Script pour lancer Ganache et déployer les contrats
Write-Host "Démarrage de Ganache..." -ForegroundColor Green

$ganacheProcess = Start-Process -FilePath "npx" -ArgumentList "ganache", "--host", "127.0.0.1", "--port", "8545" -PassThru -NoNewWindow

Write-Host "Ganache démarré (PID: $($ganacheProcess.Id))" -ForegroundColor Green
Write-Host "Attente de 5 secondes pour que Ganache soit prêt..." -ForegroundColor Yellow

Start-Sleep -Seconds 5

Write-Host "Déploiement des contrats..." -ForegroundColor Green

# Exécuter la migration
truffle migrate --network development --reset

Write-Host "Déploiement terminé!" -ForegroundColor Green
