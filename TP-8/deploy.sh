#!/bin/bash
# Script de déploiement complet

echo "=== Démarrage du déploiement DApp ==="
echo ""
echo "1. Lancement de Ganache..."

# Lancer Ganache en arrière-plan
npx ganache --host 127.0.0.1 --port 8545 > ganache.log 2>&1 &
GANACHE_PID=$!
echo "✓ Ganache lancé (PID: $GANACHE_PID)"

# Attendre que Ganache soit prêt
echo "2. Attente du démarrage de Ganache (5 secondes)..."
sleep 5

# Compiler les contrats
echo "3. Compilation des contrats..."
truffle compile

# Déployer les contrats
echo "4. Déploiement des contrats..."
truffle migrate --network development --reset

# Afficher les logs Ganache
echo ""
echo "=== Logs Ganache ==="
cat ganache.log

echo ""
echo "✓ Déploiement terminé!"
echo ""
echo "=== Comptes Ganache disponibles ==="
truffle console --network development << EOF
web3.eth.getAccounts().then(accounts => {
  accounts.forEach((account, index) => {
    console.log((index) + ": " + account);
  });
});
EOF
