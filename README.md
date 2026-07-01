# 🚀 Aider Workflow

**Station de développement IA conteneurisée, optimisée pour le coût et la précision.**

Ce projet fournit une architecture Docker robuste pour exécuter [Aider](https://aider.chat) (assistant de développement IA en ligne de commande), avec une intégration native de **RTK** (Replete Terminal Context) pour la gestion intelligente des tokens et de **Ruff** pour le linting automatique.

---

## Sommaire

- [Architecture](#-architecture)
- [Prérequis](#-prérequis)
- [Installation](#-installation)
- [Build et lancement](#️-build-et-lancement)
- [Utilisation quotidienne](#-utilisation-quotidienne)
- [Commandes utiles](#-commandes-utiles)
- [Dépannage](#-dépannage)
- [Sécurité](#️-sécurité)
- [Licence](#-licence)

---

## 🏗️ Architecture

| Composant | Rôle |
|---|---|
| **Architecte / Éditeur** | Approche dual-modèle : un modèle "architecte" conçoit la solution, un modèle "éditeur" moins coûteux applique les modifications, réduisant la facture API. |
| **RTK (Replete Terminal Context)** | Filtre les tracebacks et sorties de tests pour ne conserver que l'essentiel, divisant par ~10 la consommation de tokens lors du débogage. |
| **Ruff** | Linting Python automatique à chaque modification de code. |
| **Docker** | Isolation complète de l'environnement, sans impact sur le système hôte. |

```
┌─────────────────────────────────────────┐
│                Hôte                     │
│   ~/aider-workflow/  (config, env)      │
│         │                               │
│         ▼                               │
│   ┌───────────────────────────────┐     │
│   │      Conteneur aider-station  │     │
│   │  ┌─────────┐   ┌────────────┐ │     │
│   │  │  Aider  │──▶│  Éditeur  │ │     │
│   │  │(Archi.) │   │  (low-cost)│ │     │
│   │  └─────────┘   └────────────┘ │     │
│   │        │              │       │     │
│   │        ▼              ▼       │     │
│   │      RTK  ◀────────  Ruff    │     │
│   └───────────────────────────────┘     │
└─────────────────────────────────────────┘
```

---

## ✅ Prérequis

- Docker et Docker Compose v2 installés
- Une clé API [OpenRouter](https://openrouter.ai/) (ou tout autre fournisseur compatible)
- Un terminal Unix (bash/zsh)

---

## 📦 Installation

### 1. Préparation des répertoires

```bash
mkdir -p ~/aider-workflow
cd ~/aider-workflow
```

### 2. Configuration des fichiers

Créez les fichiers suivants à la racine de `~/aider-workflow/` :

| Fichier | Rôle |
|---|---|
| `Dockerfile` | Définit l'environnement (Python, Aider, RTK, Ruff). |
| `docker-compose.yaml` | Gère les volumes et les permissions utilisateur (UID/GID). |
| `.aider.conf.yml` | Configure le linting et les tests automatiques via RTK. |
| `aider-workflow.env` | Stocke les clés API et la configuration des modèles. |

### 3. Fichier d'environnement

Créez `aider-workflow.env` avec votre configuration :

```env
OPENROUTER_API_KEY="sk-or-v1-votre-cle-ici"
AIDER_MODEL=openrouter/poolside/laguna-m.1
AIDER_EDITOR_MODEL=openrouter/poolside/laguna-xs.2:free
```

> ⚠️ **Important** : ce fichier contient des secrets. Il ne doit jamais être commité — il est déjà exclu via `.gitignore` (voir [Sécurité](#️-sécurité)).

---

## 🛠️ Build et lancement

```bash
# 1. Construire l'image avec les bons UID/GID
USER_UID=$(id -u) USER_GID=$(id -g) docker compose build

# 2. Démarrer le conteneur en arrière-plan
USER_UID=$(id -u) USER_GID=$(id -g) docker compose up -d
```

Vérifier que le conteneur tourne :

```bash
docker ps --filter "name=aider-station"
```

---

## 🚀 Utilisation quotidienne

Ajoutez cet alias à votre `~/.bashrc` ou `~/.zshrc` :

```bash
alias aider-dev='docker exec -it -w "$(pwd)" aider-station aider --architect'
```

Rechargez votre shell :

```bash
source ~/.bashrc   # ou source ~/.zshrc
```

Puis, depuis n'importe quel dossier de projet :

```bash
aider-dev
```

---

## 💡 Commandes utiles

Depuis la session Aider, RTK peut être invoqué directement pour filtrer les sorties :

```bash
# Exécuter un script avec sortie filtrée
/run rtk python script.py

# Lancer la suite de tests avec tracebacks compressés
/run rtk python -m pytest
```

---

## 🐛 Dépannage

**`pytest: not found`**
L'installation des dépendances est automatique lors du build. Vérifiez que le `PATH` du conteneur est correctement configuré (déjà inclus dans le `Dockerfile` de ce repo). Si le problème persiste, reconstruisez l'image :

```bash
docker compose build --no-cache
```

**`Permission denied` sur les fichiers montés**
Le `Dockerfile` gère les droits via les variables `USER_UID`/`USER_GID`. Reconstruisez l'image en vous assurant que ces variables correspondent à votre utilisateur hôte :

```bash
USER_UID=$(id -u) USER_GID=$(id -g) docker compose build
```

---

## 🛡️ Sécurité

- Le fichier `aider-workflow.env` contient vos clés API et **ne doit jamais** être versionné.
- Un `.gitignore` est fourni pour exclure automatiquement ce fichier — ne modifiez pas cette règle.
- Pensez à faire une rotation régulière de vos clés API si vous soupçonnez une fuite.

---

## 📄 Licence

Ce projet est distribué sous licence [MIT](LICENSE) — libre d'utilisation, de modification et de distribution.
