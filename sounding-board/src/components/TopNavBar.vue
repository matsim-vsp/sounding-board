<template lang="pug">
nav.navbar.is-link(role="navigation" aria-label="main navigation")
  .navbar-brand
    p.navbar-item(:style="{color: 'white'}") {{ title }}


  .navbar-end
    img(src="@/assets/images/vsp-logo-white.png" width=275)

</template>

<script lang="ts">
import { Vue, Component, Watch, Prop } from 'vue-property-decorator'

@Component({})
export default class VueComponent extends Vue {
  @Prop() private title: string

  private isBurgerActive = false
  private isDropdownActive = false

  private clickedBurger() {
    this.isBurgerActive = !this.isBurgerActive
  }

  @Watch('$route') private async routeChanged(to: any, from: any) {
    //console.log(this.$route)
    this.isBurgerActive = false
    this.isDropdownActive = false
  }
}
</script>

<style scoped lang="scss">
@import '@/styles.scss';

.navbar.is-link {
  background-color: #c40d1e;
  font-weight: 600;
  font-size: 1.4rem;
  padding-left: 18px;
}

#nav a.router-link-exact-active {
  font-weight: bold;
  color: green;
}

.home-link {
  margin-left: 2.25rem;
}

.navbar-dropdown hr {
  margin: 0.25rem 0;
}

.navbar-dropdown .navbar-item {
  font-size: 0.85rem;
}

.navbar-end {
  margin: 0.5rem 1.25rem 0.5rem 0;
}

.navbar {
  min-height: 4rem !important;
}

.navbar,
.navbar-menu,
.navbar-start,
.navbar-end {
  -webkit-box-align: stretch;
  -ms-flex-align: stretch;
  align-items: stretch;
  display: -webkit-box;
  display: -ms-flexbox;
  display: flex;
}

.navbar-end {
  -webkit-box-pack: end;
  -ms-flex-pack: end;
  justify-content: flex-end;
  margin-left: auto;
  display: flex;
  -webkit-box-align: stretch;
  -ms-flex-align: stretch;
  align-items: stretch;
  padding: 10px;
}

@media screen and (max-width: 600px) {
  .navbar.is-link {
    display: flex;
    flex-wrap: wrap;
    flex-direction: column;
    padding: 0 0;
  }

  .navbar-end {
    justify-content: initial;
    margin-left: initial;
  }
}
</style>
