# Docker unter Linux Mint Xfce einrichten

Stand: 24. April 2026

Diese Anleitung ist fuer den Lenovo-Laptop mit Linux Mint Xfce gedacht. Fuer den Einstieg reicht **Docker Engine** aus. Docker Desktop ist fuer diesen Lernkontext nicht noetig und bringt mehr Oberflaeche, mehr Abhaengigkeiten und eigene Lizenz-/Account-Themen mit.

Wichtig: Linux Mint basiert auf Ubuntu, wird von Docker aber nicht als eigene Zielplattform offiziell getestet. Der uebliche und pragmatische Weg ist deshalb: Docker Engine nach der offiziellen Ubuntu-Anleitung installieren und dabei die Ubuntu-Basisversion von Linux Mint verwenden.

## Vorher

Oeffne ein Terminal.

Optional, aber sinnvoll: Erstelle vorher einen Timeshift-Schnappschuss, falls du dein System gerade erst neu eingerichtet hast.

Aktualisiere zuerst die Paketlisten:

```bash
sudo apt update
```

## 1. Alte Docker-Pakete entfernen

Falls noch keine Docker-Version installiert ist, meldet `apt` einfach, dass nichts zu entfernen ist. Das ist in Ordnung.

```bash
sudo apt remove docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc
```

## 2. Benoetigte Grundpakete installieren

```bash
sudo apt install ca-certificates curl
```

## 3. Docker-Schluessel hinterlegen

```bash
sudo install -m 0755 -d /etc/apt/keyrings
```

```bash
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
```

```bash
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

## 4. Docker-Paketquelle einrichten

Dieser Befehl nutzt die Ubuntu-Basisversion deiner Linux-Mint-Installation. Bei Linux Mint 22.x ist das normalerweise `noble`, also Ubuntu 24.04 LTS.

```bash
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
```

Danach Paketlisten erneut aktualisieren:

```bash
sudo apt update
```

## 5. Docker installieren

```bash
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## 6. Installation testen

```bash
sudo docker run hello-world
```

Wenn alles funktioniert, laedt Docker ein kleines Test-Image herunter und gibt eine Erfolgsmeldung aus.

Pruefe danach die installierten Versionen:

```bash
docker --version
```

```bash
docker compose version
```

Hinweis: Die moderne Schreibweise ist `docker compose` mit Leerzeichen. Das alte Kommando `docker-compose` ist fuer neue Setups nicht mehr der bevorzugte Weg.

## 7. Docker ohne sudo nutzen

Damit du nicht vor jeden Docker-Befehl `sudo` schreiben musst:

```bash
sudo usermod -aG docker $USER
```

Danach einmal komplett abmelden und wieder anmelden. Alternativ kannst du neu starten.

Teste danach ohne `sudo`:

```bash
docker run hello-world
```

## 8. Docker-Dienst pruefen

Falls Docker nicht laeuft:

```bash
sudo systemctl status docker
```

Starten kannst du Docker mit:

```bash
sudo systemctl start docker
```

Damit Docker beim Systemstart automatisch startet:

```bash
sudo systemctl enable docker
```

## Kleine Aufraeum-Befehle

Alle gestoppten Container, ungenutzten Netzwerke und ungenutzten Images entfernen:

```bash
docker system prune
```

Vorsichtiger Hinweis: Dieser Befehl entfernt nicht aktiv laufende Container, aber ungenutzte Docker-Ressourcen. Am Anfang nur ausfuehren, wenn du bewusst aufraeumen willst.

## Typische Fehler

### `permission denied` bei Docker ohne sudo

Wahrscheinlich wurde die Gruppenmitgliedschaft noch nicht neu geladen.

Loesung:

```bash
sudo usermod -aG docker $USER
```

Danach abmelden und wieder anmelden.

### Paketquelle funktioniert nicht

Pruefe, welche Ubuntu-Basis dein Linux Mint verwendet:

```bash
grep UBUNTU_CODENAME /etc/os-release
```

Bei Linux Mint 22.x sollte dort normalerweise `UBUNTU_CODENAME=noble` stehen.

Wenn dort nichts steht, pruefe:

```bash
cat /etc/os-release
```

Dann muss die passende Ubuntu-Basisversion manuell in `/etc/apt/sources.list.d/docker.sources` eingetragen werden.

## Erste sinnvolle Uebung

Starte einen kleinen Webserver in einem Container:

```bash
docker run --name test-nginx -p 8080:80 nginx
```

Oeffne danach im Browser:

```text
http://localhost:8080
```

Zum Stoppen in einem zweiten Terminal:

```bash
docker stop test-nginx
```

Zum Entfernen:

```bash
docker rm test-nginx
```

Das ist ein guter erster Aha-Moment: Du hast einen isolierten Webserver gestartet, ohne nginx direkt auf deinem Linux Mint installieren zu muessen.

## Quellen

- Offizielle Docker-Anleitung fuer Ubuntu: <https://docs.docker.com/engine/install/ubuntu/>
- Docker-Hinweise fuer Linux-Post-Installation: <https://docs.docker.com/engine/install/linux-postinstall/>
- Docker-Hinweis zu Ubuntu-Derivaten: <https://docs.docker.com/en/latest/installation/>
