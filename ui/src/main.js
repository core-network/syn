import App from './App.svelte'
import Mirror from './Mirror.svelte'

const app = new App({
  target:
    document.getElementById('core_panel_bottom_app') || // if embedded
    document.body, // if being served standalone
  props: {},
})

new Mirror({
  target:
    document.getElementById('core_panel_bottom_addition_app') ,
  props: {},
})

export default app
