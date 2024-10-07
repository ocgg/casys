# Casys (Carla System Rack)

<!--[English version](./README.en.md)-->

## Sommaire

- [À propos](#about)
- [Premiers pas](#getting_started)
- [Configuration](#config)
- [Utilisation](#usage)
- [Notes](#notes)

## À propos <a name="about"></a>

Casys permet d'utiliser un contrôleur MIDI pour régler le son de l'ordinateur, en utilisant des plugins audio VST ou LV2.

Le but est d'avoir une expérience similaire aux réglages basse/aigus/... d'une chaîne hifi par exemple, ou d'un bus de console de mixage, mais avec les effets de son choix.

C'est un projet personnel sans prétention, testé seulement sous Linux Fedora 40.

## Premiers pas <a name="getting_started"></a>

Casys consiste en seulement 2 éléments :

- Un fichier de session [Carla](https://github.com/falkTX/Carla) `carla-session.carxp`,
- Un script bash executable `casys.sh`.

### Prérequis

- Avoir installé [Carla](https://github.com/falkTX/Carla), hôte pour plugin VST/VST3/LV2/LADSPA
- Avoir installé [Jack](https://jackaudio.org/), serveur de son
- Utiiser un serveur de son [Pipewire](https://www.pipewire.org/) avec [PulseAudio](https://www.freedesktop.org/wiki/Software/PulseAudio/) (pipewire-pulse)

Pour vérifier le dernier point:

```bash
pactl info | grep -i pipe

# Devrait afficher: Server Name: PulseAudio (on PipeWire 1.x.x)
```

## Configuration <a name="config"></a>

Carla doit être configuré pour utiliser le serveur de son Jack.

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

Pour arrêter Casys, ajouter la commande `stop` (ou `quit` ou `exit` ou `kill`)

```bash
./casys.sh stop
```

## Notes <a name="notes"></a>

- Le MIDI learn de Carla ne prend en charge que les messages MIDI de type control change. Il est actuellement impossible de mapper un message de type note nativement.
- **Utiliser des plugins stéréo** et de bonne qualité : rappelez-vous que tous les sons du système sont affectés.
- Pour une utilisation basique de type "aigu/basse de chaîne hifi", je vous conseille le plugin gratuit [baxandall](https://www.airwindows.com/baxandall/) de l'excellent [airwindows](https://www.airwindows.com/).
- Les dépendances à Jack et PulseAudio sont à priori inutiles et ne sont là que par facilité parce que je n'y connaissais pas grand chose en écrivant ce script. Un jour peut-être, je travaillerais à m'en passer.
