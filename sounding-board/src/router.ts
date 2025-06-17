import Vue from 'vue'
import VueRouter from 'vue-router'

Vue.use(VueRouter)

const routes = [
  {
    path: '/start-session',
    name: 'Start-Session',
    component: function() {
      return Promise.resolve().then(function() {
        return require('@/views/StartSession.vue')
      })
    },
  },
  {
    path: '/:runId/:config',
    component: () => import(/* webpackChunkName: "scenarios" */ '@/views/SoundingBoard.vue'),
  },
  {
    path: '/:runId/',
    redirect: '/:runId/config',
    component: () => import(/* webpackChunkName: "scenarios" */ '@/views/SoundingBoard.vue'),
  },
  {
    // catch-all back to home page
    path: '/',
    redirect: '/berlin/config',
  },
]

const router = new VueRouter({
  mode: 'history',
  base: process.env.BASE_URL,
  routes, // native-like back/forward and top-of-page routing
  scrollBehavior(to, from, savedPosition) {
    if (to.path === from.path) return
    if (savedPosition) {
      return savedPosition
    } else {
      return { x: 0, y: 0 }
    }
  },
})

export default router
