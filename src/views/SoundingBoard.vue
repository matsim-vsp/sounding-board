<template lang="pug">
#sounding-board
  //- .banner
  //-   h2 VSP / Technische Universität Berlin
  //-   h3 {{ $t('title') }}

  .heading
    h2: b {{ title }}
    p(v-html="description")

  .presets(v-if="Object.keys(presets).length")
    h2 {{ $t('scenarios')  }}
    b-button.is-huge.factor-option(
        v-for="preset in Object.keys(presets)" :key="preset"
        :class="preset == currentPreset ? 'is-success' : ''"
        @click="setPreset(preset)"
    ) {{ presets[preset].title }}

  .results
    h2 {{ $t('results')  }}

    .metrics
      .metric(v-for="metric,i in metrics")
        h4.metric-title {{ metric.title }}
        .image(v-if="metric.imageComponents")
          img(:src="`${PUBLIC_SVN}/${runId}/` + generatedImageSrc(metric)")
          p {{ generatedImageSrc(metric)  }}
        .chart(v-else)
          .metric-value {{ formattedValue(metric, displayedValues[i]) }}
          bar-chart(:data="[{x: [' '], y: [displayedValues[i]-1], type: 'bar'}]")

  .configurator
    h2 {{ $t('settings')  }}

    .factors
      .factor(v-for="factor in Object.keys(yaml.inputColumns)" :key="factor")
        .boxx
          .boxleft.flex1
            h4.metric-title {{ factorTitle[factor]  }}
            p {{ factorDescription[factor]  }}
          .boxright.flex1
            b-button.is-small.factor-option(
              v-for="option of factors[factor]"
              :class="option == currentConfiguration[factor] ? 'is-danger' : ''"
              @click="setFactor(factor, option)"
            ) {{ option }}

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
    scenarios: 'Preset Scenarios'
  de:
    results: 'Ergebnis'
    settings: 'Experiment conditions'
    risk-calculator: 'Personalrisiko Rechner'
    badpage: 'Seite wurde nicht gefunden.'
    released: 'Veröffentlicht'
    explore-scenarios: 'Typische Szenarien erforschen'
    try-combos: '...oder versuchen Sie verschiedene Kombinationen unten.'
    estimated-risk: 'Geschätztes Infektionsrisiko'
    remarks: 'Bemerkungen'
  </i18n>

<script lang="ts">
import { Vue, Component, Watch, Prop } from 'vue-property-decorator'
import MarkdownIt from 'markdown-it'
import Papaparse from 'papaparse'
import { Route } from 'vue-router'
import VueSlider from 'vue-slider-component'
import YAML from 'yaml'
import 'vue-slider-component/theme/default.css'

import BarChart from '@/components/BarChart.vue'

type ScenarioYaml = {
  data: string
  title?: string
  title_en?: string
  title_de?: string
  description?: string
  description_en?: string
  description_de?: string
  inputColumns: {
    [column: string]: {
      type?: string
      title?: string
      title_en?: string
      title_de?: string
      description?: string
      description_en?: string
      description_de?: string
    }
  }
  outputColumns: {
    [column: string]: {
      title?: string
      title_en?: string
      title_de?: string
      showPercent?: boolean
      imageComponents?: string
    }
  }
  presets: any
}

@Component({ components: { BarChart, VueSlider }, props: {} })
export default class VueComponent extends Vue {
  // private PUBLIC_SVN = 'http://localhost:8001'
  private PUBLIC_SVN =
    'https://svn.vsp.tu-berlin.de/repos/public-svn/matsim/scenarios/countries/de/berlin/projects/sounding-board'

  private runId = ''
  private selectedScenario = ''

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

  private presets: { [id: string]: { title: string; items: any } } = {}
  private currentPreset = ''

  private factors: { [measure: string]: any } = {}
  private factorTitle: any = {}
  private factorDescription: any = {}

  private currentConfiguration: { [measure: string]: { title: string; value: any } } = {}
  private displayedValues: any[] = []

  private title = ''
  private description = ''

  private metrics: { column: string; title: string; value: any }[] = []
  private data: any[] = []

  @Watch('$route') routeChanged(to: Route, from: Route) {
    if (to.path === from.path) {
      console.log('same path')
    } else {
      this.buildPageForURL()
    }
  }

  private formattedValue(metric: any, v: number) {
    // if showPercent is not in config yaml, just use raw number
    if (!metric.showPercent) return v.toFixed(2)

    // percent mode: scale the values relative to 1.0
    const percent = 100 * (v - 1)
    const sign = percent <= 0 ? '' : '+'
    return `${sign}${percent.toFixed(0)}%`
  }

  private setPreset(preset: string) {
    console.log(preset)

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
    console.log(factor, option)
    this.currentConfiguration[factor] = option
    this.currentConfiguration = Object.assign({}, this.currentConfiguration)
    this.updateValues()

    // disable the preset if user mucks with the settings
    this.currentPreset = ''
    this.setURLQuery()
  }

  private mounted() {
    this.lang = this.$i18n.locale.indexOf('de') > -1 ? 'de' : 'en'
    console.log({ locale: this.$i18n.locale })
    console.log({ lang: this.lang })

    this.buildPageForURL()
  }

  private async buildPageForURL() {
    this.yaml = await this.getYAML()
    this.data = await this.loadDataset()
    this.buildUI()
    this.buildOptions()
    this.buildPresets()
    this.setInitialValues()
    this.updateValues()
  }

  // private parseMarkdown(text: string) {
  //   return this.mdParser.render(text)
  // }

  private async getYAML() {
    this.badPage = false
    this.runId = this.$route.params.runId

    const url = `${this.PUBLIC_SVN}/${this.runId}/config.yaml`
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

    this.description =
      this.lang == 'de'
        ? this.yaml.description_de || this.yaml.description || this.yaml.description_en || ''
        : this.yaml.description_en || this.yaml.description || this.yaml.description_de || ''

    // metrics
    for (const column of Object.keys(this.yaml.outputColumns)) {
      const config = this.yaml.outputColumns[column]
      const metric = {
        showPercent: config.showPercent,
        imageComponents: config.imageComponents,
        column,
        value: '...',
        title:
          this.lang === 'de'
            ? config.title_de || config.title || config.title_en || column
            : config.title_en || config.title || config.title_de || column,
      }
      this.metrics.push(metric)
    }
    // console.log(21, this.metrics)
  }

  private async loadDataset() {
    const datasetFilename = `${this.PUBLIC_SVN}/${this.runId}/${this.yaml.data}`

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
      this.factorDescription[factor] =
        this.lang == 'de'
          ? definition.description_de || definition.description || definition.description_en || ''
          : definition.description_en || definition.description || definition.description_de || ''
    }

    this.factors = Object.assign({}, this.factors)
    console.log(70, this.factorDescription)
  }

  private buildPresets() {
    const presets: any = {}

    for (const key of Object.keys(this.yaml.presets || {})) {
      const preset = this.yaml.presets[key]
      // extract titles
      const { title, title_en, title_de, ...items } = preset
      const finalTitle =
        this.lang == 'de'
          ? title_de || title || title_en || key
          : title_en || title || title_de || key

      presets[key] = { title: finalTitle, items }
    }
    this.presets = presets
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
      if (!hasQuery) this.setPreset(presets[0])
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
    console.log(answerRow)
    if (answerRow.length !== 1) {
      throw Error('Should have exactly one row:' + answerRow)
    }

    const row = answerRow[0]

    for (const metric of this.metrics) {
      metric.value = row[metric.column]
    }
    this.animateTowardNewValues()
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
      // some cells don't have numeric values
      if (metric.value === undefined) return

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

  private generatedImageSrc(metric: any) {
    let filename = metric.column + '_'
    const imageComponents = metric.imageComponents.split(',').map((c: string) => c.trim()) as any[]

    const values = [] as any[]
    imageComponents.forEach(column => {
      const metric = this.metrics.find(m => m.column == column)
      values.push(metric?.value)
    })
    const combinedKey = values.join('_')
    filename += combinedKey + '.png'
    return filename
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
  color: #596;
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
  // background-color: #1e1f2c;
  color: white;
  background: url(../assets/images/banner.jpg);
  background-repeat: no-repeat;
  background-size: cover;
}

.banner h2 {
  margin-bottom: 0rem;
  font-size: 1.6rem;
  // background-color: #1e1f2c;
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
  // background-color: #154b30;
  padding: 1rem 2rem 2rem 2rem;
}

.configurator {
  background-color: #eee;
  padding: 1rem 2rem 2rem 2rem;
}

.metrics {
  display: grid;
  grid-template-columns: repeat(auto-fit, 12rem);
  gap: 1rem;
}

.metric {
  background-color: white;
  width: 100%;
  padding: 1rem;
  margin: 0.5rem;
  display: flex;
  flex-direction: column;
  border: 1px solid blue;
}

.metric-value {
  font-weight: bold;
  font-size: 2rem;
  color: #222;
}

.heading {
  padding: 2rem;
}

.heading p {
  color: #33b;
  font-size: 1rem;
  text-transform: none;
}

.factors {
  display: grid;
  // grid-template-columns: repeat(1fr, 3);
}

.factor {
  padding: 1rem;
  background-color: white;
  margin: 0.5rem 0;
  border: 1px solid blue;
  // display: flex;
  // flex-direction: column;
}

.factor-option {
  color: #227;
  // background-color: #cc3;
  margin: 0.25rem;
  cursor: pointer;
}

.boxx {
  display: flex;
}

.flex1 {
  flex: 1;
}

.boxleft {
  margin-right: 1rem;
}

.image {
  // width: 5rem;
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
