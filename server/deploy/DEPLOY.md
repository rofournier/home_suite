# Déploiement VPS (OVH, nginx déjà en place)

URL publique : `https://vps-3edc37a3.vps.ovh.net:8443` — vivavoce (443) n'est pas touché.

## 1. Cloner et lancer le serveur

```bash
git clone git@github.com:rofournier/home_suite.git
cd home_suite/server
echo "HSH_JWT_SECRET=$(openssl rand -hex 32)" > .env
docker compose up -d --build
curl http://127.0.0.1:8090/health   # → {"ok":true}
```

Le compose n'expose que `127.0.0.1:8090` : seul nginx est joignable de l'extérieur.
La DB et les fichiers vivent dans le volume Docker `hsh-data` (survit aux rebuilds).

## 2. Brancher nginx

```bash
sudo cp deploy/nginx-hsh.conf /etc/nginx/sites-available/hsh
sudo ln -s /etc/nginx/sites-available/hsh /etc/nginx/sites-enabled/hsh
sudo nginx -t && sudo systemctl reload nginx
```

## 3. Ouvrir le port 8443

```bash
sudo ufw allow 8443/tcp   # si ufw actif
```

Si le firewall réseau OVH est activé (panel OVH → IP → firewall), y ouvrir 8443 aussi.

## 4. Vérifier de l'extérieur

```bash
curl https://vps-3edc37a3.vps.ovh.net:8443/health
```

## Mise à jour

```bash
cd home_suite && git pull
cd server && docker compose up -d --build
```

## (Optionnel) Migrer les données locales existantes

Depuis la machine de dev, copier la DB et les fichiers dans le volume :

```bash
scp server/home_sweet_home.db  <vps>:/tmp/
scp -r server/files            <vps>:/tmp/hsh-files
# sur le VPS :
docker compose stop
docker run --rm -v server_hsh-data:/data -v /tmp:/src debian:bookworm-slim \
  bash -c "cp /src/home_sweet_home.db /data/ && cp -r /src/hsh-files/. /data/files/"
docker compose start
```

## Build de l'APK côté client

```bash
flutter build apk --release \
  --dart-define=HSH_SERVER=https://vps-3edc37a3.vps.ovh.net:8443
```

(`AppConfig.realtimeUri` passe automatiquement en `wss://` quand le base URL est en https.)
