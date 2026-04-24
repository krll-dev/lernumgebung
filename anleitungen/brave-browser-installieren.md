# Brave Browser unter Linux Mint installieren

Stand: 24. April 2026

Diese kurze Anleitung ist fuer Linux Mint Xfce gedacht. Brave wird hier ueber die offizielle APT-Paketquelle installiert, damit spaetere Updates normal ueber die Aktualisierungsverwaltung bzw. `apt` kommen.

## Vorher

Oeffne ein Terminal.

Aktualisiere zuerst die Paketlisten:

```bash
sudo apt update
```

## 1. Curl installieren

`curl` wird benoetigt, um den Brave-Schluessel und die Paketquelle herunterzuladen.

```bash
sudo apt install curl
```

## 2. Brave-Schluessel hinterlegen

```bash
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
```

## 3. Brave-Paketquelle einrichten

```bash
sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
```

Danach die Paketlisten erneut aktualisieren:

```bash
sudo apt update
```

## 4. Brave installieren

```bash
sudo apt install brave-browser
```

## 5. Brave starten

Du findest Brave danach im Startmenue. Alternativ kannst du Brave im Terminal starten:

```bash
brave-browser
```

## Installation pruefen

```bash
brave-browser --version
```

Wenn eine Versionsnummer erscheint, ist Brave installiert.

## Updates

Brave wird kuenftig zusammen mit den normalen Systemupdates aktualisiert:

```bash
sudo apt update
sudo apt upgrade
```

## Quelle

- Offizielle Brave-Anleitung fuer Debian, Ubuntu und Mint: <https://brave.com/linux/>
