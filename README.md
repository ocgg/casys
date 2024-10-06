# Casys (Carla System Rack)

<!--[English version](./README.en.md)-->

## Sommaire

- [À propos](#about)
- [Premiers pas](#getting_started)
- [Configuration](#config)
- [Utilisation](#usage)
- [Notes](#notes)

## À propos <a name="about"></a>

Le but est de pouvoir appliquer n'importe quel effet audio VST/LV2/... sur la sortie audio principale du système, et de pouvoir contrôler ces effets avec un contrôleur MIDI.

En d'autres termes : Casys permet d'utiliser un contrôleur MIDI pour régler l'audio de l'ordinateur, de la même manière que les réglages basse/aigus/volume d'une chaîne hifi par exemple, ou d'un bus de console de mixage.

C'est un projet personnel sans aucune prétention : ça fonctionne pour moi à ce stade et ça me suffit.
Testé uniquement sous Linux Fedora 40.

## Premiers pas <a name="getting_started"></a>

Casys consiste en seulement 2 éléments :

- Un fichier de session [Carla](https://github.com/falkTX/Carla) `carla-session.carxp`,
- Un script bash executable `casys.sh`.

### Prérequis

Note: Les dépendances à Pulseaudio et Jack ne sont pas vraiment utiles dans le cadre de Casys : elles sont là par facilité et parce que je n'y connaissais pas grand chose avant d'écrire ce script. Je travaillerais dans le futur à n'utiliser que Pipewire.

1. PulseAudio avec PipeWire

Actuellement, le script utilise les commandes `pactl` et `pw-link`. Cela signifie qu'il ne peut fonctionner qu'avec [Pipewire](https://www.pipewire.org/) et un serveur de son [PulseAudio](https://www.freedesktop.org/wiki/Software/PulseAudio/) (pipewire-pulse), ce qui est le cas de nombreuses distributions Linux en 2024. Pour vérifier si c'est votre cas :

```bash
pactl info | grep -i pipe
```

Si cette commande retourne `Server Name: PulseAudio (on PipeWire 1.x.x)`, c'est bon.

2. [Carla](https://github.com/falkTX/Carla)

Casys utilise [Carla](https://github.com/falkTX/Carla) en tant qu'hôte pour les plugins audio.

Vous devez donc l'avoir installé sur votre système, ainsi que des plugins compatibles que Carla peut prendre en charge (VST, VST3, LV2...).

3. [Jack](https://jackaudio.org/)

Carla utilise [Jack](https://jackaudio.org/) par défaut, dans l'état actuel du script il faut l'avoir installé.

## Configuration <a name="config"></a>

Avant d'exécuter le script, il faut configurer le fichier de session de Carla pour reconnaître les messages MIDI provenant du contrôleur et mettre en place les plugins audio.

**Ceci est important**, car Casys exécute Carla en mode no-GUI (sans interface graphique), par souci de transparence et pour économiser les ressources système. Vous pouvez annuler ce comportement en enlevant l'option `-n` de la variable `carla_command`.

Voici la marche à suivre :

- Lancer Carla manuellement et charger le fichier `carla-session.carxp`,
- Dans l'onglet `patchbay`, connecter votre contrôleur MIDI à l'entrée MIDI `events-in` de Carla,
- Dans l'onglet `rack`, ajouter les plugins audio de votre choix,
- Mapper les paramètres des plugins avec votre contrôleur MIDI.

## Utilisation <a name="usage"></a>

Pour lancer Casys, exécutez le fichier `casys.sh`.

```bash
./casys.sh
```

Pour quitter Casys, ajouter la commande `stop` (ou `quit` ou `exit` ou `kill`)

```bash
./casys.sh stop
```

## Notes <a name="notes"></a>

- Le MIDI learn de Carla ne prend en charge que les messages MIDI de type control change. Il est actuellement impossible de mapper un message de type note nativement.
- **Utiliser des plugins stéréo** et de bonne qualité : rappelez-vous que tous les sons du système sont affectés.
- Pour une utilisation basique de type "aigu/basse de chaîne hifi", je vous conseille le plugin gratuit [baxandall](https://www.airwindows.com/baxandall/) de l'excellent [airwindows](https://www.airwindows.com/).
