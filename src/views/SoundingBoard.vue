<template lang="pug">
#sounding-board

  top-nav-bar

  .heading
    h2.section-title: b {{ title }}

  .description
    .description-subtitle(v-for="item in yaml.descriptionOutput")
      //p.description-text(:style="{'font-weight' : 'bold'}") {{ item.title + ':' }} {{ item.description }}
      p.description-text(v-html="'<b>' + item.title + ': </b>' + item.description")

  .presets(v-if="Object.keys(presets).length")
    h2.section-title {{ $t('scenarios')  }}
    b-button.is-huge.factor-option.preset-buttons.preset-option(
          v-for="preset in orderedPresets"
          :class="preset.key == currentPreset ? 'is-success' : ''"
          @click="setPreset(preset.key)"
        ) {{ preset.title }}


  .results(:class="!title.startsWith('Güter') ? 'calc-margin' : ''")
    .left-results
      h2.section-title {{ $t('results')  }}
      .charts
        .metrics
          .metric(v-for="metric,i in metrics" v-if="!metric.title.startsWith('Staat')")
            h4.metric-title {{ metric.title }}
            // The percentage sign is not displayed when it comes to costs
            .metric-value {{ formattedValue(displayedValues[i] + 1, false) }} %
            bar-chart(v-if="metric.title.startsWith('CO')" :data="[{x: [' '], y: [displayedValues[i]], type: 'bar', base: '0', marker: {color:'rgb(221,75,98)'}}]")
            bar-chart(v-else :data="[{x: [' '], y: [displayedValues[i]], type: 'bar', base: '0'}]")
          .metric(v-if="metrics.length")
            h4.metric-title {{ metrics[3].title }}
            .metric-value.metric-value-costs(:class="[displayedValues[3] < -0.5 ? 'red-number' : '',displayedValues[3] >= 0.5 ? 'green-number' : '']") {{ formattedValue(displayedValues[3], true)}} €
            h4.metric-title(:style="{ 'margin-top': '0.5rem' }") {{ metrics[4].title }}
            .metric-value.metric-value-costs(:class="[displayedValues[4] < -0.5 ? 'red-number' : '', ,displayedValues[4] >= 0.5 ? 'green-number' : '']") {{ formattedValue(displayedValues[4], true) }} €
            h4.metric-title(:style="{ 'margin-top': '0.5rem' }") {{ metrics[5].title }}
            .metric-value.metric-value-costs(:class="[displayedValues[5] < -0.5 ? 'red-number' : '', ,displayedValues[5] >= 0.5 ? 'green-number' : '']") {{ formattedValue(displayedValues[5], true) }} €
          .metric 
            car-viz.car-viz-styles(v-if="!title.startsWith('Güter')" :style="{scale: 2}" :numberOfParkingCars="numberOfParkingCars" :numberOfDrivingCars="numberOfDrivingCars" :plotWidth="plotWidth" :plotHeight="plotHeight")  

          
    // .right-results
    //   car-viz.car-viz-styles(v-if="!title.startsWith('Güter')" :style="{scale: 2}" :numberOfParkingCars="numberOfParkingCars" :numberOfDrivingCars="numberOfDrivingCars" :plotWidth="plotWidth" :plotHeight="plotHeight")

  .configurator
    h2.section-title {{ $t('settings') }}

    .factors
      .factor(v-for="[key, value] in Object.entries(yaml.inputColumns)")
        h4.metric-title.metric-title-factor {{ factorTitle[key]  }}
        b-button.is-small.factor-option(
          v-for="option of factors[key]"
          :key="option"
          :class="option == currentConfiguration[key] ? 'is-danger' : ''"
          @click="setFactor(key, option)"
        ) {{ option }}
        p.factor-description {{value.description}}

  .description
    h2.section-title {{ $t('description') }}
    .description-subtitle(v-for="item in yaml.descriptionInput")
      p.description-text(:style="{'font-weight' : 'bold'}") {{ item.title + ':' }} {{ item.description }}
      .subdescription(v-for="sub in item.subdescriptions")
        p.description-text {{ sub }}
    

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
//import { debounce } from 'debounce'
import YAML from 'yaml'
import 'vue-slider-component/theme/default.css'
import BarChart from '@/components/BarChart.vue'
import CarViz from '@/components/CarViz.vue'
import TopNavBar from '@/components/TopNavBar.vue'

// const PUBLIC_SVN = 'http://localhost:8000'
const PUBLIC_SVN =
  'https://svn.vsp.tu-berlin.de/repos/public-svn/matsim/scenarios/countries/de/berlin/projects/sounding-board'

type ScenarioYaml = {
  data: string
  title?: string
  title_en?: string
  title_de?: string
  description?: string
  description_en?: string
  description_de?: string
  descriptionOutput?: {}
  descriptionInput?: {}
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
  private allowedConfigs = [
    'config',
    'config_gueter',
    'config_kommerziell',
    'config_sonder',
    'config_privaterPersonenverkehr',
  ]

  private yaml: ScenarioYaml = {
    data: '',
    title: '',
    inputColumns: {},
    outputColumns: {},
    presets: {},
  }

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

  @Watch('$route') routeChanged(to: Route, from: Route) {
    if (to.path === from.path) {
    } else {
      this.buildPageForURL()
    }
  }

  //private handleResize = debounce(this.realHandleResize, 250)

  private plotHeight = 1
  private plotWidth = 1

  // private async realHandleResize(c: Event) {
  //   this.updateWidth()
  // }

  private updateWidth() {
    console.log('Update')
    //const firstPlot = document.getElementsByClassName('metric')[0] as HTMLElement
    // if (firstPlot) {
    //   if (!(Math.abs(firstPlot.clientHeight - this.plotHeight) < 20))
    //     this.plotHeight = firstPlot.clientHeight
    //   if (!(Math.abs(firstPlot.clientWidth - this.plotWidth) < 20))
    //     this.plotWidth = firstPlot.clientWidth
    //   // const leftSide = document.getElementsByClassName('left-results')[0] as HTMLElement
    //   // if (leftSide) {
    //   //   if (!this.title.startsWith('Güter'))
    //   //     leftSide.style.width = 'calc(100% - ' + (this.plotWidth - 0) + 'px)'
    //   //   else leftSide.style.width = 'calc(100%)'
    //   // }
    // }
  }

  private updateSize() {
    // window.setInterval(() => {
    //   this.updateWidth()
    // }, 1000)
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
    this.updateValues()
    this.currentPreset = preset

    this.setURLQuery()
  }

  private setFactor(factor: string, option: any) {
    this.currentConfiguration[factor] = option
    this.currentConfiguration = Object.assign({}, this.currentConfiguration)
    this.updateValues()

    // disable the preset if user mucks with the settings
    this.currentPreset = ''
    this.setURLQuery()
  }

  private mounted() {
    console.log({ locale: this.$i18n.locale })

    this.lang = this.$i18n.locale.indexOf('de') > -1 ? 'de' : 'en'
    console.log({ lang: this.lang })
    this.buildPageForURL()
    //window.addEventListener('resize', this.handleResize)
    //this.updateSize()
  }

  private async buildPageForURL() {
    this.yaml = await this.getYAML()
    this.data = await this.loadDataset()
    this.addDescriptionToggle()
    this.buildUI()
    this.buildOptions()
    this.buildPresets()
    this.setInitialValues()
    this.updateValues()
    console.log(this.yaml)
  }

  // private parseMarkdown(text: string) {
  //   return this.mdParser.render(text)
  // }

  private async getYAML() {
    this.badPage = false
    this.runId = this.$route.params.runId
    this.config = this.$route.params.config

    if (!this.allowedConfigs.includes(this.config)) this.config = 'config'

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

    this.factors = Object.assign({}, this.factors)
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

  private addDescriptionToggle() {
    for (const value of Object.values(this.yaml.inputColumns)) {
      value.showDescription = true
    }
  }

  /*   private showInformation(text: string) {
    for (const [key, value] of Object.entries(this.yaml.inputColumns)) {
      if (text == key) value.showDescription = !value.showDescription
    }
  } */
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

.description {
  font-size: 0.85rem;
  margin-top: 0;
  margin-bottom: 0.25rem;
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

.results {
  padding: 1rem 2rem 1rem 2rem;
  display: flex;
  width: 100%;
}

.left-results {
  //width: calc(100% - 170px);
  width: 100%;
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

.metric {
  background-color: white;
  //width: max-content;
  //width: 320px;
  //padding: 1rem;
  //margin: 0.5rem;
  display: flex;
  flex-direction: column;
  //min-width: 100px;
  flex: 1;
  //height: fit-content;
  //border: 1px solid black;
  align-self: stretch;
  //justify-content: center;
}

.metrics .metric {
  border: 1px solid black;
  padding: 1rem;
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
  color: #33b;
  font-size: 1rem;
  text-transform: none;
}

.description {
  padding: 2rem;
}

.description p {
  color: #33b;
  font-size: 1.2rem;
  text-transform: none;
}

.factors {
  display: flex;
  flex-wrap: wrap;
}
.metrics {
  display: flex;
  //flex-wrap: wrap;
  flex-wrap: nowrap;
  //justify-content: space-around;
  height: fit-content;
  //justify-content: stretch;
  display: flex;
  flex-direction: row;
  flex-wrap: nowrap;
  justify-content: center;
  align-content: center;
  gap: 20px;
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
}

.factor {
  padding: 0.5rem;
  background-color: white;
  margin: 0.5rem;
  max-width: fit-content;
}

.preset-option {
  font-size: 1rem;
}

.factor-option {
  margin: 0.25rem;
  margin-top: 0rem;
  margin-bottom: 0rem;
  font-size: 0.8rem;
  cursor: pointer;
  font-style: normal;
}

.factor-description {
  margin-top: 0.5rem;
  margin-bottom: 0;
}

.description-text {
  margin-bottom: 0;
}

.subdescription {
  margin-left: 2rem;
}

.temp-box {
  width: 100%;
  height: 100%;
  background-color: red;
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
    font-size: 0.9rem;
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

@media only screen and (max-width: 1280px) {
  .factor-option {
    font-size: 0.6rem;
  }

  .preset-option {
    font-size: 0.7rem;
  }

  .section-title {
    margin-bottom: 0;
  }

  .metric-title {
    font-size: 0.8rem;
  }

  .metric-title-factor {
    height: 1.5rem;
    font-size: 0.8rem;
    margin-bottom: 0.3rem;
  }

  .metric-value {
    margin-top: 0rem;
    font-size: 1rem;
  }

  .factor-description {
    font-size: 0.7rem;
    margin-top: 0.4rem;
    margin-bottom: 0;
  }

  .results {
    padding-bottom: 0;
    margin-bottom: 1rem;
  }

  .right-results {
    height: fit-content;
    margin: 3.1rem 0 0 0;
  }

  .option-groups {
    grid-template-columns: repeat(2, 1fr);
  }

  .description p {
    font-size: 1.1rem;
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
    font-size: 0.7rem;
  }

  .metric-title-factor {
    height: 1.3rem;
    font-size: 0.7rem;
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

  .results {
    padding-bottom: 0;
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
    padding: 2rem 1rem;
  }

  .center-area {
    padding-left: 1rem;
    padding-right: 1rem;
  }

  .option-groups {
    grid-template-columns: repeat(1, 1fr);
  }
}
</style>
