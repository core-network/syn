<script>
  import { content, connection, session } from './stores.js'
  import { createEventDispatcher } from 'svelte'
  import { CSSifyHSL } from './colors.js'

  const dispatch = createEventDispatcher()

  function getLoc(tag) {
    return $content.meta ? ($content.meta[tag] ? $content.meta[tag] : 0) : 0
  }

  let editor
  $: myTag = $session ? $session.myTag : ''
  $: editor_content1 = $content.body.slice(0, getLoc(myTag))
  $: editor_content2 = $content.body.slice(getLoc(myTag))

  function addText(text) {
    const loc = getLoc(myTag)
    const deltas = [{type:'Add', value:[loc, text]}]
    for (const [tag, tagLoc] of Object.entries($content.meta)) {
      if (tagLoc >=  loc) {
        deltas.push({type:'Meta', value: {setLoc: [tag,tagLoc+text.length] }})
      }
    }
    dispatch('requestChange', deltas)
  }

  function handleInput(event) {
    const loc = getLoc(myTag)
    const key = event.key
    if (key.length == 1) {
      addText(key)
    } else {
      switch (key) {
      case 'ArrowRight':
        if (loc < $content.body.length) {
          dispatch('requestChange', [
            {type:'Meta', value:{setLoc: [myTag, loc+1]}}
          ])
        }
        break
      case 'ArrowLeft':
        if (loc > 0){
          dispatch('requestChange', [
            {type:'Meta', value:{setLoc: [myTag, loc-1]}}
          ])
        }
        break
      case 'Enter':
        addText('\n')
        break
      case 'Backspace':
        if (loc>0) {
          const deltas = [{type:'Delete', value:[loc-1, loc]}]
          for (const [tag, tagLoc] of Object.entries($content.meta)) {
            if (tagLoc >=  loc) {
              deltas.push({type:'Meta', value: {setLoc: [tag,tagLoc-1] }})
            }
          }
          dispatch('requestChange', deltas)
        }
      }
    }
    // console.log('input', event.key)
  }
  function handleClick(e) {
    const offset = window.getSelection().focusOffset
    let loc = offset > 0 ? offset : 0
    if (window.getSelection().focusNode.parentElement == editor.lastChild) {
      loc += editor_content1.length
    }
    if (loc != getLoc(myTag)) {
      dispatch('requestChange', [
        {type:'Meta', value:{setLoc: [myTag, loc]}}
      ])
    }
  }

  let cursor
  $: {
    // wait for cursor and connection and color inside connection to exist
    // before updating the cursor color
    if (cursor && $connection && $connection.syn && $connection.syn.myColors) {
      cursor.style['border-color'] = CSSifyHSL($connection.syn.myColors.primary)
    }
  }

</script>
<style>
  editor {
    min-height: 6em;
    display: block;
    white-space: pre-wrap;
  }
  .cursor {
    display: inline;
    margin-right: -2px;
    z-index: 10;
    position: relative;
  }
</style>
<div class="syn_editor">
    <editor on:click={handleClick} on:keydown={handleInput} tabindex=0 start=0 bind:this={editor}>
      <span>{editor_content1}</span><span class='cursor' bind:this={cursor}></span><span>{editor_content2}</span>
  </editor>
</div>
