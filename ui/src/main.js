import App from './App.svelte'

const app = new App({
  target:
    document.getElementById('core_panel_bottom_app') || // if embedded
    document.body, // if being served standalone
  props: {},
})

export default app
