# Guide Trivy – Scanner de Sécurité

## Table des matières

1. [Introduction à Trivy](#introduction)
2. [Installation](#installation)
3. [Utilisation de base](#utilisation-de-base)
4. [Fonctionnalités avancées](#fonctionnalites-avancees)
5. [TP Pratique](#tp-pratique)

---

## 1. Introduction à Trivy

### Qu'est‑ce que Trivy ?

Trivy est un scanner de sécurité *open‑source* développé par **Aqua Security**. Il détecte les vulnérabilités dans :

- Images de conteneurs
- Systèmes de fichiers
- Dépôts Git
- Images de machines virtuelles
- Manifestes Kubernetes
- Fichiers *Infrastructure as Code* (Terraform, CloudFormation…)

**Principales caractéristiques**

- **Multi‑format :** Docker, OCI, Podman, containerd…
- **Multi‑langage :** détection de vulnérabilités dans de nombreux écosystèmes
- **Rapide :** analyse locale sans connexion réseau permanente
- **Précis :** base CVE mise à jour régulièrement
- **Simple :** CLI intuitive

---

## 2. Installation

```bash
# Méthode 1 : script d'installation
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | \
  sh -s -- -b /usr/local/bin

# Méthode 2 : via APT
sudo apt-get update
sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | \
  sudo tee /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy
```

```bash
# Homebrew
brew install trivy

# MacPorts
sudo port install trivy
```

```powershell
# Chocolatey
choco install trivy

# Scoop
scoop install trivy
```

```bash
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
           -v $HOME/Library/Caches:/root/.cache/ \
           aquasec/trivy:latest
```

```bash
wget https://github.com/aquasecurity/trivy/releases/download/v0.45.0/trivy_0.45.0_Linux-64bit.tar.gz
tar -xzf trivy_0.45.0_Linux-64bit.tar.gz
sudo mv trivy /usr/local/bin/
```

---

## 3. Utilisation de base

### Première utilisation

```bash
trivy --version     # vérifie l'installation
trivy db update     # met à jour la base CVE
```

### Scanner une image Docker

```bash
trivy image nginx:latest           # image publique
trivy image mon-app:v1.0           # image locale
trivy image --format json nginx:latest > scan.json
```

### Scanner un système de fichiers

```bash
trivy fs .                         # répertoire courant
trivy fs /path/to/project          # répertoire spécifique
trivy fs --skip-dirs node_modules,vendor .
```

### Scanner un dépôt Git

```bash
trivy repo https://github.com/user/repo  # distant
trivy repo .                              # local
```

---

## 4. Fonctionnalités avancées

### Filtrage par sévérité

```bash
trivy image --severity HIGH,CRITICAL nginx:latest
trivy image --ignore-unfixed nginx:latest
```

### Formats de sortie

```bash
trivy image --format json   nginx:latest  # JSON
trivy image --format table  nginx:latest  # Table (défaut)
trivy image --format sarif  nginx:latest  # SARIF (CI/CD)
trivy image --format template --template "@template.tpl" nginx:latest  # perso
```

### Fichier de configuration

`trivy.yaml` :

```yaml
format: json
output: results.json
severity: [HIGH, CRITICAL]
ignore-unfixed: true
skip-dirs: [node_modules, vendor]
```

Utilisation :

```bash
trivy --config trivy.yaml image nginx:latest
```

### Intégration CI/CD

```bash
trivy image --exit-code 1 --severity CRITICAL nginx:latest
```

---

## 5. TP Pratique

Chaque exercice suit le schéma **Étapes → Questions → Réponses** pour une meilleure lisibilité.

---

### Exercice 1 : Installation et premiers pas

**Objectif :** installer Trivy et réaliser un premier scan.

#### Étapes

1. Installer Trivy.
2. Vérifier : `trivy --version`.
3. Mettre à jour la DB : `trivy db update`.
4. Scanner l'image ``.

#### Questions

- Combien de vulnérabilités sont détectées ?
- Quelle est la vulnérabilité la plus critique ?
- Quels packages sont affectés ?

#### Réponses

| Question                           | Réponse                                       |
| ---------------------------------- | --------------------------------------------- |
| Nombre de vulnérabilités détectées | **482** (tableau ci‑dessous)                  |
| Vulnérabilité la plus critique     | `CVE-2022-1664` (buffer overflow dans `dpkg`) |
| Packages affectés                  | `dpkg`, `libc6`, `libssl1.1`, `zlib1g`, …     |

```
┌──────────────────────────┬────────┬─────────────────┬─────────┐
│          Target          │  Type  │ Vulnerabilities │ Secrets │
├──────────────────────────┼────────┼─────────────────┼─────────┤
│ nginx:1.20 (debian 11.3) │ debian │       482       │    -    │
└──────────────────────────┴────────┴─────────────────┴─────────┘
```

---

### Exercice 2 : Comparaison d'images

**Objectif :** comparer la sécurité de plusieurs tags **nginx**.

#### Étapes

1. Scanner `nginx:1.20`, `nginx:1.21`, `nginx:latest`.
2. Comparer les résultats.
3. Générer des rapports JSON.

#### Questions

- Quelle version a le moins de vulnérabilités ?
- Des vulnérabilités communes existent‑elles ?

#### Réponses

- `` a généralement le moins de vulnérabilités.
- Oui : CVEs communes dans `libc6`, `openssl`, `zlib`.

---

### Exercice 3 : Scanner un projet réel

**Objectif :** scanner un projet Node.js.

#### Étapes

1. Créer un projet de test et installer `express@4.17.1` & `lodash@4.17.20`.
2. `trivy fs .`.
3. Mettre à jour les packages vulnérables.
4. Re‑scanner.

#### Questions

- Quelles dépendances sont vulnérables ?
- Comment résoudre ces vulnérabilités ?

#### Réponses

| Dépendance                                | CVE              | Correction                    |
| ----------------------------------------- | ---------------- | ----------------------------- |
| `lodash@4.17.20`                          | `CVE-2021-23337` | `npm install lodash@latest`   |
| `express@4.17.1` (dépendances indirectes) | multiples        | `npm audit fix` + mise à jour |

---

### Exercice 4 : Configuration avancée

**Objectif :** utiliser `.trivyignore` & filtres.

#### Étapes

1. Créer `.trivyignore` contenant :
   ```
   CVE-2021-44228
   CVE-2021-45046
   ```
2. Scanner `nginx:latest` en ignorant ces CVE.
3. Scanner en ne montrant que `HIGH,CRITICAL`.
4. Générer un rapport via template.

*Aucune question spécifique → pas de réponse séparée.*

---

### Exercice 5 : Intégration dans un pipeline

**Objectif :** faire échouer le build si des vulnérabilités critiques sont présentes.

#### Étapes

1. Créer `security-check.sh` (voir script ci‑dessous).
2. `chmod +x security-check.sh`.
3. Tester avec `nginx:latest` et `alpine:latest`.

#### Script `security-check.sh`

```bash
#!/bin/bash
set -e
IMAGE_NAME=$1
SEVERITY="CRITICAL,HIGH"
REPORT_FILE="security-report.json"

echo "🔍 Scanning $IMAGE_NAME..."
trivy image --severity $SEVERITY --format json --output $REPORT_FILE --exit-code 1 $IMAGE_NAME
```

#### Réponses (observations)

- `nginx:latest` → **échec** (CRITICAL détectées).
- `alpine:latest` → **succès** (0 CRITICAL).

---

### Exercice 6 : Analyse IaC

**Objectif :** scanner un `docker-compose.yml`.

#### Étapes

1. Créer le fichier suivant :
   ```yaml
   version: '3.8'
   services:
     web:
       image: nginx:1.20
       ports: ["80:80"]
       environment:
         - DEBUG=true
         - API_KEY=hardcoded-secret-key
     db:
       image: postgres:13
       environment:
         - POSTGRES_PASSWORD=password123
       ports: ["5432:5432"]
   ```
2. `trivy config docker-compose.yml`.
3. Corriger et re‑scanner.

#### Questions

- Quels problèmes de sécurité sont détectés ?
- Comment sécuriser les secrets ?

#### Réponses

| Problème détecté                                  | Mitigation                                                              |
| ------------------------------------------------- | ----------------------------------------------------------------------- |
| Secrets en clair (`API_KEY`, `POSTGRES_PASSWORD`) | Utiliser variables d'environnement via `.env` ou Docker Secrets, Vault… |
| `DEBUG=true` actif                                | Désactiver en production                                                |

---

### Exercice 7 : Monitoring & alertes

**Objectif :** surveiller régulièrement plusieurs images.

#### Étapes

1. Créer `monitor.sh` (voir script).
2. Planifier via *cron* ou CI.

#### Questions de réflexion

- Comment automatiser le monitoring ?
- Quelles métriques surveiller ?
- Comment intégrer les alertes ?

#### Réponses (pistes)

- **Automatisation :** `cron`, GitHub Actions, GitLab CI, Jenkins.
- **Métriques clés :** nombre de vulnérabilités `HIGH/CRITICAL` par image & évolution temporelle.
- **Intégration :** Slack/PagerDuty via Webhook, Prometheus + Grafana.

