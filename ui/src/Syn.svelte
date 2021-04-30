<script>
  import { connection, scribeStr, content, folks } from './stores.js'
  import { createEventDispatcher } from 'svelte'
  import { Connection} from './syn.js'
  import { bufferToBase64 } from './utils.js'

  let session

  // this properties are the app-defined functions to apply and undo changes
  export let applyDeltaFn
  export let undoFn

  // this is the list of sessions returned by the DNA
  let sessions

  export function requestChange(deltas) {
    $session.requestChange(deltas)
  }

  // -----------------------------------------------------------------------

  const dispatch = createEventDispatcher()

  let appHost= process.env.APP_HOST || 'localhost'
  let appPort=9000
  let appId='syn'
  async function toggle() {
    if (!$connection) {
      $connection = new Connection(appHost, appPort, appId)
      await $connection.open({title:'', body:''}, applyDeltaFn)

      session = $connection.syn.session

      console.log('joining session...')
      await $connection.joinSession()
      sessions = $connection.sessions
    }
    else {
      $connection.syn.clearState()
      sessions = undefined
      console.log('disconnected')
    }
  }

  async function commitChange() {
    $session.commitChange()
  }

  $: noscribe = $scribeStr === ''
</script>
<style>
  :global(.noscribe) {
  pointer-events: none;
  position: relative;
  }

  :global(.noscribe:after) {
  content: ' ';
  z-index: 20;
  display: block;
  position: absolute;
  height: 100%;
  top: 0;
  left: 0;
  right: 0;
  }

</style>
<button class="syn_commit" class:noscribe on:click={commitChange}>Save</button>

<div class="syn_connection">
  <label for="syn_host">Holochain Host:</label> <input id="syn_host" bind:value={appHost}>
  <div class="row">
    <div class="column_2"><label for="syn_port">Port:</label> <input id="syn_port" bind:value={appPort}></div>
    <div class="column_2"><label for="syn_appid">AppId:</label> <input id="syn_appid" bind:value={appId}></div>
  </div>
  <button class="syn_connect" on:click={toggle}>
    {#if $connection}
      Disconnect
    {:else}
      Connect
    {/if}
  </button>


  <div class="syn_sessions">
    {#if sessions}
    {#each sessions as session}
      <span class="syn_session">
        Id: {bufferToBase64(session).slice(-4)}
      </span>
    {/each}
    {/if}
  </div>

</div><!-- syn_connection Right Area -->
