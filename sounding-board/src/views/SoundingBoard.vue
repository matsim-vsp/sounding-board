<template lang="pug">
#sounding-board

  top-nav-bar(:title="title || 'Sounding Board — Berlin'")

  .heading
    .sounding-board-description(v-if="yaml.description" v-html="yaml.description")

  .header-description
    .header-description-subtitle(v-for="item in yaml.descriptionOutput")
      p.header-description-text(v-html="`<b>${item.title}</b>`")
      .header-sub-items
        .header-images
          img(:src="getImagePath(item.title)")
        .header-mobile-text {{item.description}}

  .presets(v-if="Object.keys(presets).length")
    h2.section-title {{ $t('scenarios')  }}
    b-button.is-huge.factor-option.preset-buttons.preset-option(
      v-for="preset in orderedPresets"
      :key="preset.key"
      :class="preset.key == currentPreset ? 'is-success' : ''"
      @click="setPreset(preset.key)"
    ) {{ preset.title }}

  .configurator
    h2.section-title {{ $t('settings') }}

    .factors
      .factor(v-for="[key, value] in Object.entries(yaml.inputColumns)")
        .right-block
          h4.metric-title.metric-title-factor {{ factorTitle[key]  }}
            .tooltip
              .top
                h4.metric-title-factor(:style="{'margin-left' : '0'}") {{ factorTitle[key]  }}
                p.factor-description {{getDescriptionForTooltip(factorTitle[key])}}
          .buttons-div
            b-button.is-small.factor-option.expand(
              v-for="option of factors[key]"
              v-if="yaml.buttonLabels && option in yaml.buttonLabels"
              :key="option"
              :class="option == currentConfiguration[key] ? 'is-danger' : ''"
              @click="setFactor(key, option)"
            ) {{ yaml.buttonLabels && yaml.buttonLabels[option] || option }}
        .left-block(v-if="textBlocks[key]")
          .conditionTitle {{ textBlocks[key].description}}
          .conditionDescriptionTitle Information:
          .conditionDescription {{ textBlocks[key].subdescriptions[currentConfiguration[key]]}}


  .results(:class="!title.startsWith('Güter') ? 'calc-margin' : ''")
    .left-results
      h2.section-title {{ $t('results')  }}
      .charts
        .metrics
          .metric(v-for="metric,i in metrics" v-if="!metric.title.startsWith('Staat')")
            h4.metric-title {{ metric.title }}
            //- The percentage sign is not displayed when it comes to costs
            .metric-value {{ formattedValue(displayedValues[i] + 1, false) }} %
            bar-chart.temp-box(v-if="metric.title.startsWith('CO')" :data="[{x: [' '], y: [displayedValues[i]], type: 'bar', base: '0', marker: {color:'rgb(221,75,98)'}}]" :plotWidth="plotWidth" :plotHeight="plotHeight")
            bar-chart.temp-box(v-else :data="[{x: [' '], y: [displayedValues[i]], type: 'bar', base: '0'}]" :plotWidth="plotWidth" :plotHeight="plotHeight")
            //- .temp-box
          .metric(v-if="metrics.length")
            h4.metric-title {{ metrics[3].title }}
            .metric-value.metric-value-costs(:class="[displayedValues[3] < -0.5 ? 'red-number' : '',displayedValues[3] >= 0.5 ? 'green-number' : '']") {{ formattedValue(displayedValues[3], true)}} €
            h4.metric-title(:style="{ 'margin-top': '1.5rem' }") {{ metrics[4].title }}
            .metric-value.metric-value-costs(:class="[displayedValues[4] < -0.5 ? 'red-number' : '', ,displayedValues[4] >= 0.5 ? 'green-number' : '']") {{ formattedValue(displayedValues[4], true) }} €
            h4.metric-title(:style="{ 'margin-top': '1.5rem' }") {{ metrics[5].title }}
            .metric-value.metric-value-costs(:class="[displayedValues[5] < -0.5 ? 'red-number' : '', ,displayedValues[5] >= 0.5 ? 'green-number' : '']") {{ formattedValue(displayedValues[5], true) }} €
          .metric
            car-viz.car-viz-styles(v-if="!title.startsWith('Güter')" :style="{scale: 2}" :numberOfParkingCars="numberOfParkingCars" :numberOfDrivingCars="numberOfDrivingCars"  :plotWidth="plotWidth" :plotHeight="plotHeight")

  .submit-vote-div
    .button.submit-button(@click="saveConditions") &#x2705; Stimme abgeben
    .voted-text(v-if="showVotedText") <span style="color:#77b255">Sie haben abgestimmt.</span> Wenn Sie nochmal abstimmen möchten, wird Ihre erste Stimme ersetzt.
  .vote-disclaimer *Wenn die Seite aktualisiert wird, bevor Sie Ihre Stimme abgeben, wählen Sie bitte Ihre Bedingungen erneut aus (auch wenn sie bereits gewählt sind)


</template>

<i18n>
  en:
    results: 'Results'
    settings: 'Experiment conditions'
    title: 'Emissions Scenario Calculator'
    risk-calculator: 'Personal Risk Calculator'
    badpage: 'That page not found, sorry!'
    released: 'Released'
    estimated-risk: 'Estimated Infection Risk'
    explore-scenarios: 'Explore typical scenarios'
    try-combos: '...or try different combinations below.'
    remarks: 'Remarks'
    scenarios: 'Typical Scenarios'
    description: 'Description'
    descriptionOutput: 'Description'
  de:
    results: 'Ergebnis'
    settings: 'Versuchsbedingungen'
    risk-calculator: 'Personalrisiko Rechner'
    badpage: 'Seite wurde nicht gefunden.'
    released: 'Veröffentlicht'
    explore-scenarios: 'Typische Szenarien erforschen'
    try-combos: '...oder versuchen Sie verschiedene Kombinationen unten.'
    estimated-risk: 'Geschätztes Infektionsrisiko'
    remarks: 'Bemerkungen'
    scenarios: 'Typische Szenarien'
    description: 'Beschreibung'
    descriptionOutput: 'Beschreibung'
  </i18n>

<script lang="ts">
import { Vue, Component, Watch, Prop } from 'vue-property-decorator'
import MarkdownIt from 'markdown-it'
import Papaparse from 'papaparse'
import { Route } from 'vue-router'
import VueSlider from 'vue-slider-component'
import { debounce } from 'debounce'
import YAML from 'yaml'
import 'vue-slider-component/theme/default.css'
import BarChart from '@/components/BarChart.vue'
import CarViz from '@/components/CarViz.vue'
import TopNavBar from '@/components/TopNavBar.vue'
import { PUBLIC_SVN } from '@/Globals'

type ScenarioYaml = {
  data: string
  title?: string
  title_en?: string
  title_de?: string
  description?: string
  description_en?: string
  description_de?: string
  descriptionOutput?: {}
  descriptionInput: {
    [column: string]: {
      title: string
      description?: string
      subdescriptions?: {}
    }
  }
  inputColumns: {
    [column: string]: {
      type?: string
      title?: string
      title_en?: string
      title_de?: string
      description?: string
      showDescription?: boolean
    }
  }
  outputColumns: {
    [column: string]: {
      title?: string
      title_en?: string
      title_de?: string
    }
  }
  presets: any
}

@Component({ components: { BarChart, VueSlider, CarViz, TopNavBar }, props: {} })
export default class VueComponent extends Vue {
  private runId = ''
  private config = ''
  private selectedScenario = ''

  private yaml: ScenarioYaml = {
    data: '',
    title: '',
    descriptionInput: {},
    inputColumns: {},
    outputColumns: {},
    presets: {},
  }

  private serverURL = 'https://vsp-lndw-sounding-board.fly.dev/'
  // private serverURL = "http://127.0.0.1:4999/"

  private badPage = false
  private lang = 'en'
  private mdParser = new MarkdownIt()

  private presets: { [id: string]: { title: string; items: any; order: number } } = {}
  private currentPreset = ''

  private factors: { [measure: string]: any } = {}
  private factorTitle: any = {}

  private currentConfiguration: { [measure: string]: { title: string; value: any } } = {}
  private displayedValues: any[] = []

  private title = ''
  private description = ''
  private descriptionOutput = ''

  private metrics: { column: string; title: string; value: any }[] = []
  private data: any[] = []

  private numberOfDrivingCars = 10
  private numberOfParkingCars = 10

  private voteConditions = {
    oepnv: 'base',
    kiezBloecke: 'base',
    fahrrad: 'base',
    parkraum: 'base',
    fahrenderAutoVerkehr: 'base',
    drt: 'base',
    cookie: '',
    timeStamp: null,
  }

  private voted = false
  private showVotedText = false

  private resultsRequested = false

  private textBlocks = {}

  private apiKey = ''

  @Watch('$route') routeChanged(to: Route, from: Route) {
    if (to.path === from.path) {
    } else {
      this.buildPageForURL()
    }
  }

  private handleResize = debounce(this.realHandleResize, 250)

  private plotHeight = 1
  private plotWidth = 1

  private async realHandleResize(c: Event) {
    this.updateWidth()
  }

  private updateWidth() {
    const firstPlot = document.getElementsByClassName('metric')[0] as HTMLElement
    if (firstPlot) {
      if (!(Math.abs(firstPlot.clientHeight - this.plotHeight) < 20))
        this.plotHeight = firstPlot.clientHeight
      if (!(Math.abs(firstPlot.clientWidth - this.plotWidth) < 20))
        this.plotWidth = firstPlot.clientWidth
      // const leftSide = document.getElementsByClassName('left-results')[0] as HTMLElement
      // if (leftSide) {
      //   leftSide.style.width = 'calc(100% - ' + (this.plotWidth - 0) + 'px)'
      // }
    }
  }

  private updateSize() {
    window.setInterval(() => {
      this.updateWidth()
    }, 1000)
  }

  private getImagePath(title) {
    try {
      return require(`../assets/images/${title}.png`)
    } catch (e) {
      console.error(`Image not found: ../assets/images/${title}.png`)
      return ''
    }
  }

  private formattedValue(v: number, isCosts: boolean) {
    const nf = new Intl.NumberFormat('de-DE', {
      minimumFractionDigits: 0,
      maximumFractionDigits: 0,
    })

    let percent = 100 * (v - 1)
    if (isCosts) percent = v

    let fixedPercent = Math.round(percent)

    if (fixedPercent === -0) {
      fixedPercent = 0
    }

    const sign = fixedPercent <= 0 ? '' : ''

    if (isCosts) return sign + nf.format(fixedPercent)
    else return sign + nf.format(fixedPercent)
  }

  private setPreset(preset: string) {
    const factors = this.presets[preset].items
    for (const factor of Object.keys(factors)) {
      this.currentConfiguration[factor] = factors[factor]
    }

    this.currentConfiguration = Object.assign({}, this.currentConfiguration)
    console.log(this.currentConfiguration.DRT)
    console.log(this.currentConfiguration.OePNV)
    this.updateVoteConditions('OePNV', this.currentConfiguration.OePNV)
    this.updateVoteConditions('kiezblocks', this.currentConfiguration.kiezblocks)
    this.updateVoteConditions('Fahrrad', this.currentConfiguration.Fahrrad)
    this.updateVoteConditions('Parkraum', this.currentConfiguration.Parkraum)
    this.updateVoteConditions('fahrenderVerkehr', this.currentConfiguration.fahrenderVerkehr)
    this.updateVoteConditions('DRT', this.currentConfiguration.DRT)

    this.updateValues()

    this.currentPreset = preset

    this.setURLQuery()
  }

  private setFactor(factor: string, option: any) {
    this.currentConfiguration[factor] = option
    this.currentConfiguration = Object.assign({}, this.currentConfiguration)
    this.updateValues()
    this.updateVoteConditions(factor, option)
    this.currentConfiguration
    // disable the preset if user mucks with the settings
    this.currentPreset = ''
    this.setURLQuery()
  }

  // getApiAuthorization() {
  //   let auth = localStorage.getItem('brendan-api-key')
  //   if (!auth) auth = prompt('API access key required:')

  //   if (auth) {
  //     this.apiKey = auth
  //     localStorage.setItem('brendan-api-key', auth)
  //   }
  // }

  private mounted() {
    // brendan - why are you clearing these on every page load? Defeats the purpose.
    // localStorage.setItem('LSvoted', 'false')
    // localStorage.setItem('voter-cookie', '')

    console.log(localStorage.getItem('voter-cookie'))
    console.log({ locale: this.$i18n.locale })
    this.lang = this.$i18n.locale.indexOf('de') > -1 ? 'de' : 'en'
    console.log({ lang: this.lang })

    if (localStorage.getItem('LSvoted') == 'true') {
      this.showVotedText = true
    }

    this.buildPageForURL()
    window.addEventListener('resize', this.handleResize)
    this.updateSize()
    // this.getApiAuthorization()

    // this.setText()
  }

  private async buildPageForURL() {
    this.yaml = await this.getYAML()
    console.log(this.yaml.descriptionInput['fahrenderVerkehr'].title)
    this.data = await this.loadDataset()
    this.addDescriptionToggle()
    this.buildUI()
    this.buildOptions()
    this.buildPresets()
    this.setInitialValues()
    this.updateValues()
    this.textBlocks = {
      OePNV: {
        description: 'S-Bahn, U-Bahn, Tram, und Bus',
        subdescriptions: {
          base: this.yaml.descriptionInput.OePNV.subdescriptions['scenario1'],
          dekarbonisiert: this.yaml.descriptionInput.OePNV.subdescriptions['scenario2'],
          stark: this.yaml.descriptionInput.OePNV.subdescriptions['scenario3'],
        },
      },
      kiezblocks: {
        description: '10 km/h Tempolimit',
        subdescriptions: {
          base: this.yaml.descriptionInput.kiezblocks.subdescriptions['scenario1'],
          'ganze Stadt': this.yaml.descriptionInput.kiezblocks.subdescriptions['scenario2'],
        },
      },
      Fahrrad: {
        description: 'Radinfrastruktur',
        subdescriptions: {
          base: this.yaml.descriptionInput.Fahrrad.subdescriptions['scenario1'],
          stark: this.yaml.descriptionInput.Fahrrad.subdescriptions['scenario2'],
        },
      },
      Parkraum: {
        description: 'Parkende Fahrzeuge',
        subdescriptions: {
          base: this.yaml.descriptionInput.Parkraum.subdescriptions['scenario1'],
          BesucherFossilTeuer_alleAnderenPreiswert: this.yaml.descriptionInput.Parkraum
            .subdescriptions['scenario2'],
          Besucher_teuer_Anwohner_preiswert: this.yaml.descriptionInput.Parkraum.subdescriptions[
            'scenario3'
          ],
          Besucher_teuer_Anwohner_teuer: this.yaml.descriptionInput.Parkraum.subdescriptions[
            'scenario4'
          ],
        },
      },
      fahrenderVerkehr: {
        description: 'Fahrende Fahrzeuge',
        subdescriptions: {
          base: this.yaml.descriptionInput.kiezblocks.subdescriptions['scenario1'],
          mautFossil: this.yaml.descriptionInput.fahrenderVerkehr.subdescriptions['scenario2'],
          MautFuerAlle: this.yaml.descriptionInput.fahrenderVerkehr.subdescriptions['scenario3'],
          zeroEmissionsZone: this.yaml.descriptionInput.fahrenderVerkehr.subdescriptions[
            'scenario4'
          ],
          zeroEmissionsZonePlusMaut: this.yaml.descriptionInput.fahrenderVerkehr.subdescriptions[
            'scenario5'
          ],
          autofrei: this.yaml.descriptionInput.fahrenderVerkehr.subdescriptions['scenario6'],
        },
      },
      DRT: {
        description: 'Digitales Rufbussystem',
        subdescriptions: {
          base: this.yaml.descriptionInput.DRT.subdescriptions['scenario1'],
          nurAussenbezirke: this.yaml.descriptionInput.DRT.subdescriptions['scenario2'],
          ganzeStadt: this.yaml.descriptionInput.DRT.subdescriptions['scenario3'],
        },
      },
    }
  }

  // private parseMarkdown(text: string) {
  //   return this.mdParser.render(text)
  // }

  private async getYAML() {
    this.badPage = false
    this.runId = this.$route.params.runId
    this.config = this.$route.params.config

    if (!this.config) this.config = 'config'

    const url = `${PUBLIC_SVN}/${this.runId}/${this.config}.yaml`
    console.log({ url })

    try {
      let configText = await fetch(url).then(response => response.text())
      return YAML.parse(configText)
    } catch (e) {
      console.error('' + e)
      this.badPage = true
      return {}
    }
  }

  private buildUI() {
    this.title =
      this.lang == 'de'
        ? this.yaml.title_de || this.yaml.title || this.yaml.title_en || this.runId
        : this.yaml.title_en || this.yaml.title || this.yaml.title_de || this.runId

    // metrics
    this.metrics = []
    for (const column of Object.keys(this.yaml.outputColumns)) {
      const config = this.yaml.outputColumns[column]
      const metric = {
        column,
        title:
          this.lang === 'de'
            ? config.title_de || config.title || config.title_en || column
            : config.title_en || config.title || config.title_de || column,
        value: '...',
      }
      this.metrics.push(metric)
    }
  }

  private async loadDataset() {
    const datasetFilename = `${PUBLIC_SVN}/${this.runId}/${this.yaml.data}`

    try {
      const rawData = (await fetch(datasetFilename).then(response => response.text())) as any
      const csv = Papaparse.parse(rawData, {
        header: true,
        dynamicTyping: true,
        skipEmptyLines: true,
        delimitersToGuess: ['\t', ';', ','],
      })
      return csv.data
    } catch (e) {
      console.log('' + e)
      return []
    }
  }

  /**
   * Discover all factor values that are in the inputColumns of the dataset
   */
  private buildOptions() {
    this.factors = {}
    const inputColumns = Object.keys(this.yaml.inputColumns)

    const f = {} as any
    for (const column of inputColumns) {
      f[column] = new Set()
    }

    for (const row of this.data) {
      for (const column of inputColumns) {
        f[column].add(row[column])
      }
    }

    // convert set to array
    for (const factor of Object.keys(f)) {
      this.factors[factor] = Array.from(f[factor])
      const definition = this.yaml.inputColumns[factor]
      this.factorTitle[factor] =
        this.lang == 'de'
          ? definition.title_de || definition.title || definition.title_en || factor
          : definition.title_en || definition.title || definition.title_de || factor
    }
  }

  private buildPresets() {
    const presets: any = {}

    for (const key of Object.keys(this.yaml.presets || {})) {
      const preset = this.yaml.presets[key]
      // extract titles
      const { title, title_en, title_de, order, ...items } = preset
      const finalTitle =
        this.lang == 'de'
          ? title_de || title || title_en || key
          : title_en || title || title_de || key

      presets[key] = { title: finalTitle, items, order, key }
    }
    this.presets = presets
  }

  get orderedPresets() {
    return Object.values(this.presets).sort((a, b) => {
      if (a.order >= b.order) return 1
      else return -1
    })
  }

  private setInitialValues() {
    const presets = Object.keys(this.presets)
    const preset = this.$route.query.preset as string
    // preset given? use it
    if (preset) {
      this.setPreset(preset)
    } else {
      // go thru query settings
      let hasQuery = false
      for (const factor of Object.keys(this.factors)) {
        let query = this.$route.query[factor] as any
        if (query) {
          hasQuery = true
          this.factors[factor].forEach((f: string, i: number) => {
            if (query === f) query = f
          })
        }
        this.currentConfiguration[factor] = query || this.factors[factor][0]
      }
      // if NO queries were given, use the first preset
      if (!hasQuery) {
        for (let i = 0; i < presets.length; i++) {
          if (presets[i] == 'base') {
            this.setPreset(presets[i])
            return
          }
        }
        this.setPreset(presets[0])
      }
    }
  }

  private setURLQuery() {
    // preset is easy
    if (this.currentPreset) {
      this.$router.replace({ query: { preset: this.currentPreset } })
      return
    }

    // individual factors if no preset
    const query = {} as any
    for (const factor of Object.keys(this.factors)) {
      query[factor] = this.currentConfiguration[factor]
    }
    this.$router.replace({ query })
  }

  private updateValues() {
    let answerRow = this.data
    for (const factor of Object.keys(this.factors)) {
      answerRow = answerRow.filter(row => row[factor] === this.currentConfiguration[factor])
    }
    if (answerRow.length !== 1) {
      throw Error('Should have exactly one row:' + answerRow)
    }

    const row = answerRow[0]

    for (const metric of this.metrics) {
      metric.value = row[metric.column]
    }

    for (const metric of this.metrics) {
      if (metric.title == 'Parkende Autos') {
        this.numberOfParkingCars = this.calculateNumberOfCars(metric.value)
      }
      if (metric.title == 'Fahrender Autoverkehr') {
        this.numberOfDrivingCars = this.calculateNumberOfCars(metric.value)
      }
    }

    this.animateTowardNewValues()
  }

  private calculateNumberOfCars(n: number) {
    var tempNumber = Math.ceil(n * 10) / 10
    return tempNumber * 10
  }

  private animateTowardNewValues() {
    // first time, just set them
    if (!this.displayedValues.length) {
      this.metrics.forEach(metric => {
        this.displayedValues.push(metric.value)
      })
      this.displayedValues = [...this.displayedValues]
      return
    }

    // otherwise, animate the change in values
    let maxDiff = 0
    this.metrics.forEach((metric, i) => {
      const diff = metric.value - this.displayedValues[i]
      const step = this.displayedValues[i] + diff * 0.2
      this.displayedValues[i] = step

      const pctDiff = Math.abs((this.displayedValues[i] - metric.value) / metric.value)
      maxDiff = Math.max(maxDiff, pctDiff)
    })
    this.displayedValues = [...this.displayedValues]

    if (maxDiff < 0.001) {
      this.metrics.forEach((metric, i) => {
        this.displayedValues[i] = metric.value
      })
    } else {
      setTimeout(this.animateTowardNewValues, 8.333)
    }
  }

  private getDescriptionForTooltip(key: string) {
    // console.log(key)
    for (const value of Object.values(this.yaml.descriptionInput)) {
      if (value.title == key) return value.description
    }
    return ''
  }

  // private showResults() {
  //   this.resultsRequested = true
  //   if (localStorage.getItem('LSvoted') == 'true' && this.resultsRequested == true) {
  //     this.voted = true;
  //     let results = Array.from(
  //       document.getElementsByClassName('results') as HTMLCollectionOf<HTMLElement>
  //     )
  //     results[0].style.display = 'flex'
  //     if (window.innerWidth < 621) {
  //     window.scrollTo({
  //       top: 2300,
  //       behavior: 'smooth',
  //     })
  //   } else if (window.innerWidth < 1200 && window.innerWidth > 620) {
  //     window.scrollTo({
  //       top: 1300,
  //       behavior: 'smooth',
  //     })
  //   } else {
  //     window.scrollTo({
  //       top: 1000,
  //       behavior: 'smooth',
  //     })
  //   }
  //   }
  // }

  // private hideResults() {
  //   let results = Array.from(
  //     document.getElementsByClassName('results') as HTMLCollectionOf<HTMLElement>
  //   )
  //   results[0].style.display = 'none'
  //   this.setPreset('base')
  //   if (window.innerWidth < 621) {
  //     window.scrollTo({
  //       top: 1800,
  //       behavior: 'smooth',
  //     })
  //   } else{
  //     window.scrollTo({
  //       top: 600,
  //       behavior: 'smooth',
  //     })
  //   }

  // }

  private updateVoteConditions(factor: string, option: any) {
    if (factor == 'OePNV') this.voteConditions.oepnv = option
    if (factor == 'kiezblocks') this.voteConditions.kiezBloecke = option
    if (factor == 'Fahrrad') this.voteConditions.fahrrad = option
    if (factor == 'Parkraum') this.voteConditions.parkraum = option
    if (factor == 'fahrenderVerkehr') this.voteConditions.fahrenderAutoVerkehr = option
    if (factor == 'DRT') this.voteConditions.drt = option
  }

  private async saveConditions() {
    // localStorage.setItem('LSvoted', 'true')

    this.voted = true
    this.showVotedText = true
    this.updateVoteConditions

    for (const metric of this.metrics) {
      console.log(metric.title + ': ' + metric.value)
    }

    if (!localStorage.getItem('voter-cookie')) {
      this.voteConditions.cookie = this.setCookie('vote_id', 60)
      localStorage.setItem('voter-cookie', this.voteConditions.cookie)
      console.log(localStorage.getItem('voter-cookie'))
    } else {
      this.voteConditions.cookie = localStorage.getItem('voter-cookie')
    }

    // fetch('https://api.ipify.org?format=json')
    //   .then(x => x.json())
    //   .then(({ ip }) => {
    //     this.voteConditions.ipAddr = ip
    //   })
    //   .then(() => {
    //     const vote = JSON.stringify(this.voteConditions)
    //   })

    this.voteConditions.timeStamp = new Date().toLocaleString('de-DE')

    // POST vote to api-server
    let tries = 0
    while (tries < 3) {
      try {
        console.log(JSON.stringify(this.voteConditions))

        const url = this.serverURL + 'votes'
        console.log('POSTing', url)

        let response = await fetch(url, {
          headers: {
            'Content-type': 'application/json; charset=UTF-8',
            'Access-Control-Allow-Origin': '*',
            // Authorization: this.apiKey, // no auth needed for voting
          },
          method: 'POST',
          body: JSON.stringify(this.voteConditions),
        })

        if (!response.ok) throw new Error(`HTTP error! Status: ${response.status}`)

        let json = await response.json()
        console.log(this.metrics)
        console.log(json)
        break // success; break out of loop
      } catch (e) {
        // this.myState.statusMessage = 'Error fetching paths :-('
        // this.isFiltering = false
        console.log(`Try ${tries}: Error ` + e)
        tries += 1
        // wait 2 secs, try again
        await new Promise(resolve => setTimeout(resolve, 2000))
      }
    }
  }

  private setCookie(name, days) {
    let date = new Date()
    date.setTime(date.getTime() + days * 24 * 60 * 60 * 1000)
    let expires = 'expires=' + date.toUTCString()
    document.cookie = name + '=' + this.generateUUID() + ';' + expires + ';path=/;SameSite=Strict'
    return document.cookie
  }

  private generateUUID() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      let r = (Math.random() * 16) | 0,
        v = c == 'x' ? r : (r & 0x3) | 0x8
      return v.toString(16)
    })
  }
  private addDescriptionToggle() {
    for (const value of Object.values(this.yaml.inputColumns)) {
      value.showDescription = true
    }
  }
}
</script>

<style scoped lang="scss">
@import '@/styles.scss';

#sounding-board {
  background-color: white;
  color: #224;
}

.center-area {
  max-width: 70rem;
  padding: 1rem 3rem 1rem 3rem;
}

h2 {
  font-size: 2rem;
  text-transform: uppercase;
}

h3 {
  font-weight: normal;
  font-size: 1.3rem;
  margin-bottom: -0.5rem;
}

h4 {
  //color: #596;
  color: rgb(58, 118, 175);
  font-size: 1.2rem;
  font-weight: bold;
  margin: 0 0 0 0;
  padding: 0 0;
}

p {
  margin-bottom: 1rem;
}

p.factor {
  margin: auto 0 auto 1rem;
  color: #ccc;
}

.banner {
  display: flex;
  flex-direction: column;
  padding: 4rem 3rem 1rem 3rem;
  color: white;
  background: url(../assets/images/banner.jpg);
  background-repeat: no-repeat;
  background-size: cover;
}

.banner h2 {
  margin-bottom: 0rem;
  font-size: 1.6rem;
  line-height: 1.6rem;
  margin-right: auto;
}

.banner h3 {
  font-size: 1.3rem;
  font-weight: normal;
  margin-bottom: 0;
  line-height: 1.4rem;
  padding-bottom: 0.25rem;
  background-color: #1e1f2c;
  width: max-content;
}

.reveal-button {
  color: white;
  font-size: 16px;
  margin: 10px;
  background-color: #3a76af;
  font-weight: bold;
}

.reveal-button:hover {
  background-color: white;
  color: #3a76af;
  border: 1px solid #3a76af;
}

.hide-button {
  color: white;
  font-size: 16px;
  margin: 10px;
  background-color: #3a76af;
  font-weight: bold;
}

.hide-button:hover {
  background-color: white;
  color: #3a76af;
  border: 1px solid #3a76af;
}

.submit-button {
  color: white;
  font-size: 1.2rem;
  // margin: 10px;
  background-color: #77b255;
  font-weight: bold;
}

.submit-button:hover {
  background-color: white;
  color: #77b255;
  border: 1px solid #77b255;
}

.header-nav {
  list-style-type: none;
  margin: 0;
  padding: 0;
}

.notes-item {
  list-style-type: square;
  margin-left: 1rem;
  margin-top: 0.5rem;
  color: #222;
}

li.notes-item {
  line-height: 1.3rem;
}

.header-description {
  font-size: 0.85rem;
  margin-top: 20px;
  margin-bottom: 0.25rem;
  display: flex;
  flex: 1;
  width: 98%;
  padding-bottom: 25px;
  flex-wrap: wrap;
  padding-left: 2em;
}

.header-description-subtitle {
  flex: 1 1 auto;
  margin: 0.5rem;
  margin-left: 0.5rem;
  margin-left: 0.25rem;
  font-size: 1.2rem;
  position: relative;
  width: -webkit-min-content;
  width: -moz-min-content;
  width: min-content;
  height: -webkit-min-content;
  height: -moz-min-content;
  height: min-content;
  min-height: 105px;
  white-space: nowrap;
  width: 48%;
}

.header-images {
  max-width: 50px;
  height: 100%;
  flex: 50%;
  margin-right: 20px;
  -webkit-box-pack: left;
  -ms-flex-pack: left;
}

.header-description-text {
  border-bottom: 1px solid #888;
  margin-bottom: 10;
  text-align: center;
}

.header-factor-description {
  font-size: 12px;
  padding-right: 20px;
}

.header-mobile-text {
  flex: 50%;
  text-wrap: wrap;
  overflow-wrap: break-word;
  word-break: break-word;
  width: auto;
  padding-right: 20px;
  font-size: 1rem;
  text-align: left;
  top: 42px;
  max-width: fit-content;
  word-wrap: break-word;
  overflow-wrap: break-word;
  word-break: break-word;
  hyphens: auto;
  white-space: normal;
}

.header-sub-items {
  display: flex;
  flex-wrap: wrap;
}

.description {
  font-size: 0.85rem;
  margin-top: 0;
  margin-bottom: 0.25rem;
}

.sounding-board-description {
  text-transform: none;
  font-size: 1.6em;
}

.sticky {
  top: 3rem;
  position: sticky;
  background-color: #eee;
  padding-top: 0;
  padding-bottom: 0rem;
}

.presets {
  background-color: #eee;
  padding: 1rem 2rem 2rem 2rem;
}

.left-results {
  width: 100%;
  //width: calc(100% - 170px);
}

.right-results {
  height: fit-content;
  margin: 3.5rem 0 0 0;
}

.car-viz-styles {
  transform-origin: 0 0;
}

.configurator {
  background-color: #eee;
  padding: 1rem 2rem 2rem 2rem;
}

.metric[data-v-4aa344e9] {
  background-color: white;
  display: -webkit-box;
  display: -ms-flexbox;
  display: flex;
  -webkit-box-orient: vertical;
  -webkit-box-direction: normal;
  -ms-flex-direction: column;
  flex-direction: column;
  -webkit-box-flex: 1;
  -ms-flex: 1;
  -ms-flex-item-align: stretch;
  align-self: stretch;
  min-height: 500px;
  flex: 1;
}

// .metrics {
//   display: grid;
//   grid-template-columns: 20% 20% 20% 20% 20%;
// }

.metrics .metric {
  border: 1px solid black;
  padding: 1rem;
  width: 18%;
  margin-right: 15px;
  height: fit-content;
  max-height: 600px;
  max-width: 320px;
}

.metrics .metric:last-of-type {
  border: none;
  padding: 0rem;
}

.metric-value {
  margin-top: 1rem;
  font-weight: bold;
  font-size: 1.6rem;
  color: #222;
}

.green-number {
  color: rgb(46, 135, 46);
}

.red-number {
  color: rgb(221, 75, 98);
}

.heading {
  padding: 2rem;
  padding-bottom: 0rem;
}

.section-title {
  font-size: 1.7rem;
  margin-bottom: 0.5rem;
}

.heading p {
  color: #3a76af;
  font-size: 1rem;
  text-transform: none;
}

.description {
  padding: 2rem;
}

.description p {
  color: #3a76af;
  font-size: 1.2rem;
  text-transform: none;
}

.factors {
  display: grid;
  // flex-wrap: wrap;
  grid-template-columns: 50% 50%;
  gap: 1rem;
  margin-right: 1rem;
}

.factor {
  display: grid;
  // flex-wrap: wrap;
  grid-template-columns: 50% 50%;
}

.conditionTitle {
  padding-top: 10px;
  font-size: 1.2em;
  font-weight: bold;
  line-height: 1.2em;
  padding-bottom: 5px;
  border-bottom: 1px #000 solid;
}

.conditionDescriptionTitle {
  margin-top: 10px;
  font-size: 1.1em;
  font-weight: bold;
}

.conditionDescription {
  // margin-top: 10px;
  font-size: 1em;
  // animation: fadeInAnimation ease 3s;
  // animation-fill-mode: forwards;
}

// @keyframes fadeInAnimation {
//   0% {
//     opacity: 0;
//   }

//   100% {
//     opacity: 1;
//   }
// }
.error-text {
  color: #c40d1e;
  font-weight: bold;
}

.voted-text {
  font-weight: bold;
  text-wrap: wrap;
  max-width: max-content;
  font-size: 1.1rem;
  line-height: 1.1;
  margin-top: 10px;
  word-wrap: break-word;
  overflow-wrap: break-word;
  word-break: break-word;
  -ms-hyphens: auto;
  hyphens: auto;
  white-space: normal;
}

.vote-disclaimer {
  font-weight: bold;
  text-wrap: wrap;
  // max-width: 330px;
  font-size: 1.1rem;
  line-height: 1.3;
  margin-top: 10px;
  padding: 1rem 0rem 1rem 2rem;
  word-wrap: break-word;
  overflow-wrap: break-word;
  word-break: break-word;
  -ms-hyphens: auto;
  hyphens: auto;
  white-space: normal;
}

.submit-vote-div {
  // display: flex;
  padding: 1rem 2rem 1rem 2rem;
}

.left-block {
  height: 100%;
}

.metrics {
  display: flex;
  flex-wrap: wrap;
  height: fit-content;
  //justify-content: stretch;

  display: flex;
  flex-direction: row;
  justify-content: center;
  align-content: center;
  gap: 20px;
}

#car-viz-total {
  height: 500px;
  max-height: 500px;
  scale: 1 !important;
}

.metric-title {
  margin-bottom: 0.2rem;
  font-size: 1.2rem;
}

.metric-title-factor {
  height: 3rem;
  margin: 0.5rem;
  margin-left: 0.25rem;
  font-size: 1.2rem;
  position: relative;
  width: min-content;
  height: min-content;
  white-space: nowrap;
}

.factor {
  padding: 0.5rem;
  background-color: white;
  // margin: 0.5rem;
  max-width: 100%;
  display: grid;
}

.buttons-div {
  display: flex;
  flex-wrap: wrap;
  height: fit-content;
  font-size: 9px;
  font-weight: bold;
}

button.is-small.factor-option {
  width: 90%;
  margin-top: 5px;
  font-weight: bold;
  font-size: 1.4em;
}

button.is-small.factor-option:hover {
  color: #fff;
  background-color: #c40d1e;
}

.preset-option {
  font-size: 1rem;
}

.factor-option {
  margin: 0.25rem;
  margin-top: 0rem;
  margin-bottom: 0rem;
  font-size: 0.5rem;
  cursor: pointer;
  font-style: normal;
}

button.is-huge.factor-option.preset-buttons {
  font-size: 0.8em;
}

button.is-huge.factor-option.preset-buttons:hover {
  background-color: #48c78e;
  border-color: transparent;
  color: #fff;
}

.factor-description {
  margin-top: 0.5rem;
  margin-bottom: 0;
}

.temp-box {
  //background-color: red;
  width: 100%;
  height: 420px;
}

.description-text {
  margin-bottom: 0;
}

.subdescription {
  margin-left: 2rem;
}

.headers-hoverText {
  display: none;
  position: absolute;
  text-align: left;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}

.headers-hoverText .headers-top {
  width: 400px;
  transform: translate(0, -100%);
  padding: 10px 20px;
  color: #444444;
  background-color: white;
  font-weight: normal;
  font-size: 13px;
  border-radius: 2px;
  position: absolute;
  z-index: 99999999;
  box-sizing: border-box;
  box-shadow: 0 1px 8px rgba(0, 0, 0, 0.2);
  display: none;
  text-wrap: wrap;
}

.headers-hoverText:hover .headers-top {
  display: block;
}

.headers-hoverText .headers-top i {
  position: absolute;
  top: 100%;
  left: 50%;
  margin-left: -12px;
  width: 24px;
  height: 12px;
  overflow: hidden;
}

.headers-hoverText .headers-top i::after {
  content: '';
  position: absolute;
  width: 12px;
  height: 12px;
  left: 50%;
  transform: translate(-50%, -50%) rotate(45deg);
  background-color: #eeeeee;
  box-shadow: 0 1px 8px rgba(0, 0, 0, 0.5);
}

/* TOOLTIP */
.tooltip {
  display: inline-block;
  position: absolute;
  text-align: left;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}

.tooltip .top {
  min-width: 200px;
  // top: -20px;
  // left: 50%;
  transform: translate(0, -100%);
  padding: 10px 20px;
  color: #444444;
  background-color: white;
  font-weight: normal;
  font-size: 13px;
  border-radius: 2px;
  position: absolute;
  z-index: 99999999;
  box-sizing: border-box;
  box-shadow: 0 1px 8px rgba(0, 0, 0, 0.2);
  display: none;
}

.tooltip:hover .top {
  display: block;
}

#sounding-board > div.results.calc-margin {
  padding: 1rem 2rem 2rem 2rem !important;
  margin-bottom: 0.5rem;
}

.right-results {
  height: fit-content;
  margin: 3.1rem 0 0 0;
}

.tooltip .top i {
  position: absolute;
  top: 100%;
  left: 50%;
  margin-left: -12px;
  width: 24px;
  height: 12px;
  overflow: hidden;
}

.tooltip .top i::after {
  content: '';
  position: absolute;
  width: 12px;
  height: 12px;
  left: 50%;
  transform: translate(-50%, -50%) rotate(45deg);
  background-color: #eeeeee;
  box-shadow: 0 1px 8px rgba(0, 0, 0, 0.5);
}

.button.is-danger {
  background-color: #c40d1e !important;
}

@media only screen and (max-width: 800px) {
  .factors {
    grid-template-columns: 100%;
  }

  // .submit-button {
  //   padding: 3rem 2rem 1rem 3rem;
  // }
}

@media only screen and (max-width: 450px) {
  button.is-small.factor-option {
    font-size: 1em;
    text-wrap: wrap;
    line-height: 1.2em;
  }

  .submit-vote-div[data-v-4aa344e9] {
    display: table;
  }

  .voted-text {
    margin-top: 10px;
    margin-left: 5px;
  }
}

@media only screen and (max-width: 629px) {
  .hide-button {
    margin: 5px;
    width: fit-content;
  }

  .reveal-button {
    margin: 5px;
    width: fit-content;
  }

  .buttons {
    display: grid;
    grid-template-columns: 100%;
  }

  // .submit-button {
  //   margin-left: 5px;
  // }
}

@media only screen and (min-width: 1431px) {
  .metric {
    flex: 17% !important;
  }
}

@media only screen and (max-width: 1430px) {
  .metric {
    flex: 30% !important;
  }

  #car-viz-total {
    scale: 0.98 !important;
    width: 92%;
  }
}

@media only screen and (min-width: 1430px) and (max-width: 1630px) {
  #car-viz-total {
    width: 115%;
  }
}

@media only screen and (min-width: 1600px) {
  .factors {
    width: 100% !important;
  }

  button.is-small.factor-option {
    font-size: 1.4em;
  }
}

@media only screen and (max-width: 620px) {
  .metric {
    flex: 74% !important;
  }

  #car-viz-total {
    scale: 0.78 !important;
    width: 130%;
  }

  #sounding-board > div.results.calc-margin {
    margin-bottom: 0rem !important;
  }
}

@media only screen and (min-width: 1800px) {
  button.is-small.factor-option {
    font-size: 1.9em;
  }

  .button.is-huge.factor-option.preset-buttons {
    font-size: 1.1rem;
  }

  .heading {
    font-size: 1.1rem;
  }

  .header-description-text {
    font-size: 1.5rem;
  }

  .header-mobile-text {
    font-size: 1.1rem;
  }

  .conditionDescription {
    font-size: 1.2rem;
  }

  .conditionDescriptionTitle {
    font-size: 1.2rem;
  }

  .conditionTitle {
    font-size: 1.3rem;
  }
}

@media only screen and (max-width: 1440px) {
  .factor-option {
    font-size: 0.7rem;
  }

  .preset-option {
    font-size: 0.8rem;
  }

  .metric-title-factor {
    height: 1.9rem;
    margin-left: 0.25rem;
    font-size: 0.9rem;
  }

  .metric-title {
    font-size: 1.2rem;
  }

  .metric-value {
    margin-top: 0.5rem;
    font-size: 1.4rem;
  }

  .factor-description {
    font-size: 0.8rem;
  }

  .option-groups {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media only screen and (min-width: 1080px) {
  .factors {
    grid-template-columns: 33.3% 33.3% 33.3%;
  }
}

@media only screen and (min-width: 1280px) and (max-width: 1440px) {
  .metric-title {
    font-size: 1.2rem;
  }
}

@media only screen and (min-width: 1560px) {
  .metric-title {
    font-size: 1.4rem;
  }
}

@media only screen and (min-width: 1280px) {
  .factor-option {
    font-size: 0.6rem;
  }

  .preset-option {
    font-size: 0.7rem;
  }

  // .section-title {
  //   margin-bottom: 0;
  // }

  .metric-title-factor {
    height: 1.5rem;
    font-size: 1.3rem;
    margin-bottom: 0.3rem;
  }

  .metric-value {
    margin-top: 0rem;
    font-size: 1.2rem;
  }

  .factor-description {
    font-size: 0.7rem;
    margin-top: 0.4rem;
    margin-bottom: 0;
  }

  .option-groups {
    grid-template-columns: repeat(2, 1fr);
  }

  .description p {
    font-size: 1.1rem;
  }

  // .header-description {
  //   flex-wrap: wrap;
  //   padding-left: 2em;
  // }

  // .header-description-subtitle {
  //   width: 48%;
  // }

  // .headers-hoverText {
  //   display: none;
  // }

  // .header-description-text {
  //   text-align: left;
  // }

  // .header-images {
  //   margin: unset;
  //   justify-content: left;
  // }

  // .header-mobile-text {
  //   display: block;
  //   left: 80px;
  //   position: absolute;
  //   text-wrap: wrap;
  //   width: 80%;
  //   padding-right: 15px;
  //   font-size: 11px;
  //   text-align: left;
  //   top: 42px;
  // }

  .header-description-subtitle {
    width: 24%;
  }
}

@media only screen and (max-width: 1024px) {
  .presets {
    padding: 1rem 2rem 1rem 2rem;
  }

  .factor-option {
    font-size: 0.55rem;
  }

  .preset-option {
    font-size: 0.65rem;
  }

  .preset-buttons {
    margin-top: 0.5rem;
  }

  .section-title {
    margin-bottom: 0;
    font-size: 1rem;
  }

  .metric-title {
    //height: 1.5rem;
    font-size: 1.2rem;
  }

  .conditionTitle {
    font-size: 1rem;
  }

  .conditionDescriptionTitle {
    font-size: 0.9rem;
  }

  .conditionDescription {
    font-size: 0.8rem;
  }

  .metric-title-factor {
    height: 1.3rem;
    font-size: 1.2rem;
  }

  .metric-value {
    margin-top: 0rem;
    font-size: 0.9rem;
  }

  .factor-description {
    font-size: 0.6rem;
    margin-top: 0rem;
    margin-bottom: 0;
  }

  .right-results {
    height: fit-content;
    margin: 2rem 0 0 0;
  }

  .metric {
    padding: 0.5rem;
  }

  .option-groups {
    grid-template-columns: repeat(2, 1fr);
  }

  .description p {
    font-size: 0.9rem;
  }
}

@media only screen and (max-width: 850px) {
  .option-groups {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media only screen and (max-width: 640px) {
  .banner {
    padding: 2rem 0rem;
  }

  .center-area {
    padding-left: 0rem;
    padding-right: 0rem;
  }

  .option-groups {
    grid-template-columns: repeat(1, 1fr);
  }

  .heading,
  .header-description,
  .presets,
  .configurator {
    padding-left: 1rem;
    padding-right: 0.5rem;
  }

  .factor,
  .charts {
    padding: 0.25rem;
  }
}
</style>
