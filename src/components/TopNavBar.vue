<template lang="pug">
nav.navbar.is-link(role="navigation" aria-label="main navigation")
    .navbar-brand
      p.navbar-item(:style="{color: 'white'}") Sounding Board - Berlin
        //- img(src="https://bulma.io/images/bulma-logo.png" width="112" height="28")

      a.navbar-burger.burger(
        @click='clickedBurger'
        :class="{'is-active': isBurgerActive}"
        role="button"
        aria-label="menu"
        aria-expanded="false"
        data-target="navbarBasicExample")
        span(aria-hidden="true")
        span(aria-hidden="true")
        span(aria-hidden="true")

    #navbarBasicExample.navbar-menu(
      :class="{'is-active': isBurgerActive}"
      @click='clickedBurger'
    )

      .navbar-end
        //- router-link.navbar-item(:to="'/ccc/config'") privater Personenverkehr
        //- router-link.navbar-item(:to="'/ccc/config'") privater Personenverkehr
        //- router-link.navbar-item(:to="'/ccc/config_gueter'") Güterverkehr
        //- router-link.navbar-item(:to="'/ccc/config_kommerziell'") kommerzieller Personenverkehr
        
</template>

<script lang="ts">
import { Vue, Component, Watch, Prop } from 'vue-property-decorator'

@Component({})
export default class VueComponent extends Vue {
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
  background-color: rgb(58, 118, 175);
  font-weight: 600;
  font-size: 1rem;
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

@media only screen and (max-width: 640px) {
  .home-link {
    margin-left: 0.25rem;
  }

  .space {
    margin: 0 0.6rem;
  }
}
</style>
