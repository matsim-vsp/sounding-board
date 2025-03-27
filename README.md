# Sounding Board Documentation

This [GITHUB repository](https://github.com/matsim-vsp/sounding-board) provides a [Sounding Board](https://vsp.berlin/sounding-board), provided by the Transport Systems Planning and Transport Telematics group of TU Berlin. It displays a dashboard where a set of measures can be selected and the results of the chosen selection are displayed below. The VSP team used simulations and calculations to estimate how much CO2 emissions can be saved by different measures. This dashboard can be used to show the results of the selected set of different measures and to collect votes of people choosing a set of different transport related measures.

Sounding Board dashboard is live here:

- https://vsp.berlin/sounding-board

Github repository can be found here:

- https://github.com/matsim-vsp/sounding-board

The needed corresponding files are stored here:

- https://svn.vsp.tu-berlin.de/repos/public-svn/shared/sounding-board

## How to create your own

Add new boards on the VSP public-svn at

- https://svn.vsp.tu-berlin.de/repos/public-svn/shared/sounding-board/*new_folder*

Create a new dashboard by adding a **config.yaml** file and a **csv file** to an additional folder to https://svn.vsp.tu-berlin.de/repos/public-svn/shared/sounding-board. While the _yaml file_ is providing the formatting and content (incl. descriptions) of the website, the _csv file_ is needed for the numbers and specifications of the measures. You find your new dashboard live at `https://vsp.berlin/sounding-board/*your-new-folder*`.

Currently, there are multiple versions of the Sounding Board. Every folder is one version:

- berlin-2035: [pathway options](https://vsp.berlin/sounding-board/berlin-2035)
- berlin-2045: [final](https://vsp.berlin/sounding-board/berlin-2045)
- ccc: created for ECCC workshop in 2023
- current: this one is the [current](https://vsp.berlin/sounding-board) version [^1]

[^1]: this is also the landing page if you enter https://vsp.berlin/sounding-board

### YAML file format

Each sounding board has a **YAML file** with text descriptions and a corresponding **CSV file** with the actual scenario options and values.

In the yaml file, title and descriptions (of certain measures as well as the outcomes (e.g. costs)) can be set. The yaml file provides also the opportunity to set _presets_ e.g. "2045 - ZeroEmissionsZone". For this to work, one specification of each category must be chosen.

It's important to note that the presence of options and buttons in the UI is determined by **what is found in the CSV file** -- so, to add or remove buttons from the UI, you need to edit the CSV file to include or remove rows with the options you want. The YAML provides nice text labels for those options.

In other words, removing the text labels from the YAML is not the way to remove buttons from the UI! It will just make your buttons ugly.

As usual, YAML is extremely picky about indentation and white space. If you have trouble loading your YAML file, double check all of your indentation!!!

#### YAML top-level options are as follows

**data:** the filename of the CSV file. It will look for this file in the same folder as the yaml file.

**title, title_en, title_de:** Title of the site in English and German. Chosen based on the user's browser language setting. Should be one short line.

**description, description_en, description_de:** Description of the site in English and German. This can be a full paragraph of text and can include HTML tags such as &lt;b> and &lt&lt;i>.

**descriptionOutput:** Descriptions of each of the output measures. These are displayed in blocks at the top of the page. Each measure has a title and a description. The icons seem to be in the code itself (could be updated in the future)

For each measure, include a subsection with title and description. Example given:

```yaml
descriptionOutput:
  CO2:
    title: 'CO2'
    description: 'CO2 Emissionen sollen bis zum Jahr 2045 auf 0% reduziert werden....'
  traffic:
    title: 'Fahrender Autoverkehr'
    description: 'Für die jeweilige Maßnahmen wurde analysiert, welchen Einfluss diese auf den fahrenden Verkehr haben [etc]...'
  parking:
    title: 'Parkende Autos'
    description: 'Für die jeweilige Maßnahmen wurde analysiert, welchen Einfluss diese auf den parkenden Verkehr haben.  etc...'
```

**presets:** These are the "Typical Scenario" buttons which set the various measures to interesting values all at once. Each preset has a title, order number, and a key/value for each measure. **EVERY measure** must have a key/value specified! Example given:

```yaml
presets:
  base:
    order: 1
    title_en: '2025 - Base'
    title_de: '2025 - Base'
    OePNV: 'base'
    kiezblocks: 'base'
    Fahrrad: 'base'
    DRT: 'base'
    fahrenderVerkehr: 'base'
    Parkraum: 'base'
  '2035 - Trend':
    order: 2
    title_en: '2035 - Zwischenziel'
    title_de: '2035 - Zwischenziel'
    OePNV: 'dekarbonisiert'
    kiezblocks: 'base'
    Fahhrad: 'base'
    DRT: 'base'
    fahrenderVerkehr: 'mautFossil'
    Parkraum: 'Besucher_teuer_Anwohner_preiswert'
```

**descriptionInput:** These are the text labels for all of the "Experiment Conditions" measures and their options. Every measure must have a `title`, `description`, and a set of `subdescriptions` that identify the various scenarios. See the example here:

```yaml
descriptionInput:
  OePNV:
    title: 'ÖPNV'
    description: 'Öffentlicher Personennahverkehr: hierzu gehören S-Bahn, U-Bahn, Tram und Bus'
    subdescriptions:
      scenario1: 'Base: Stand heute'
      scenario2: 'Dekarbonisiert: S-Bahn, U-Bahn, Tram und Bus sollen emissionsfrei fahren'
      scenario3: 'Stark: S-Bahn, U-Bahn, Tram und Bus sollen emissionsfrei fahren und zusätzlich Strecken ausgebaut und Tickets verbilligt werden'
  kiezblocks:
    title: 'Kiezblöcke'
    description: 'Tempo 10km/h innerhalb der Kieze, keine Durchfahrt möglich, Modalfilter'
    subdescriptions:
      scenario1: 'Base: es werden keine Kiezblöcke eingeführt'
      scenario2: 'Ganze Stadt: Kiezblöcke werden flächendeckend eingeführt - kein Durchgangsverkehr, Modalfilter'
  [...]

```

**outputColumns:** Titles and configuration options for each of the output measures. Each measure has a subsection with title and configuration (barplot or not). Example:

Note that `barplot` is true/false. True will produce a bar graph; if false the values in the CSV are displayed directly.

```yaml
  parking:
    title_en: "Parkende Autos"
    title_de: "Parkende Autos"
    barplot: "true"
  Kosten:
   title_en: "Staatl. Einnahmen pro Jahr"
   title_de: "Staatl. Einnahmen pro Jahr"
   barplot: "false"
  [...]
```

**inputColumns:** Configuration for each measure is here. This sets the type to `buttons` for most measures but the code could be modified for other types of inputs as well. Example:

```yaml
inputColumns:
  OePNV:
    type: 'buttons'
    title_en: 'ÖPNV'
    title_de: 'ÖPNV'

  kiezblocks:
    type: 'buttons'
    title_en: 'Kiezblöcke'
    title_de: 'Kiezblöcke'

  Fahrrad:
    type: 'buttons'
```

**buttonLabels:** The labels on the buttons themselves are here. The values in the CSV come directly from model variable names and are not always human-friendly. This lookup converts those IDs to nice text for the buttons. Example:

```yaml
buttonLabels:
  base: 'Base'
  dekarbonisiert: 'Dekarbonisiert'
  stark: 'Stark'
  ganzeStadt: 'Ganze Stadt'
  'ganze Stadt': 'Ganze Stadt'
  BesucherFossilTeuer_alleAnderenPreiswert: 'Teuer für Besucher (fossil)'
  Besucher_teuer_Anwohner_preiswert: 'Teuer für Besucher'
  Besucher_teuer_Anwohner_teuer: 'Teuer für Alle'
  mautFossil: 'Maut für fossile Fahrzeuge'
  MautFuerAlle: 'Maut für Alle'
  nurAussenbezirke: 'nur Aussenbezirke'
```

### CSV data file content

In the CSV file, the column headers are the different measures and the intended outcomes (e.g. costs, CO2 emission). The specifications of the individual measures must then be added to the respective columns. Then, the respective results should be calculated for the outputs.

Therefore, the CSV file consists of the specifications of the individual measures and the numerical result of the outcomes (e.g. costs in Euro, CO2 emission: percentage for reduction) for _every possible combinations_. You can use e.g. R to create the table with every combination you need (see these R-files as an [example](https://github.com/matsim-vsp/sounding-board/tree/master/sounding-board/src/R)).

The yaml file points to the CSV file and ideally these files are stored in the same folder as shown [here](https://svn.vsp.tu-berlin.de/repos/public-svn/shared/sounding-board/).

## Site build instructions

Requires NodeJS **16.x** and yarn: Install Node for your platform, and then npm install -g yarn

If you have newer versions of Node installed, we suggest using the `nvm` [node version manager](https://github.com/nvm-sh/nvm?tab=readme-ov-file#installing-and-updating) tool to install Node 16.x for this project.

- Install nvm per instructions at the link above
- `nvm install 16`
- `nvm use 16`

Now you are ready to build the site.

- Clone this repo
- `yarn install`
- `yarn serve` to run a local dev server
- Make your changes and test locally
- Pushing to the master branch automatically builds and deploys on URL above using GitHub Actions. The code assumes the site prefix is set to `/sounding-board` and this is added to every URL. To move the site to a different prefix, edit two files:
- `public/404.html`and `vite.config.js`

## Voting

A voting server is also available but is usually disabled except for public meetings. The code for the server is in the root `api-server` folder of this repository.

The voting server is a Python Flask App. The provided Dockerfile builds the app behind an NGINX and Gunicorn web server (as Flask is not supposed to be directly accessible from the internet and is generally run behind Gunicorn).

We used [fly.io](https://fly.io/) as) as the server infrastructure because they provide a generous free tier and it was super easy to spin up the server for this task.

Explaining Flask is beyond the scope of this README, but the code is all in `RunServer.py` and is extremely brief; it simply records the chosen measure decisions for each user into a local SQLite database file.

That sqlite file should be copied/extracted for analysis after public meetings.
