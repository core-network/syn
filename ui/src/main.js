import App from './App.svelte'
import Mirror from './Mirror.svelte'

let appElement
if (process.env.APP_ELEMENT_ID) {
  const appElementId = process.env.APP_ELEMENT_ID
  appElement = document.getElementById(appElementId)
  if (!appElement) throw new Error(`No DOM element found with ID: '${appElementId}'`)
} else {
  appElement = document.body
}

const app = new App({ target: appElement })

if (process.env.MIRROR_ELEMENT_ID) {
  const mirrorId = process.env.MIRROR_ELEMENT_ID
  const mirrorElement = document.getElementById(mirrorId)
  if (!mirrorElement) throw new Error(`No DOM element found with ID: '${mirrorId}'`)
  new Mirror({ target: mirrorElement })
}

export default app
