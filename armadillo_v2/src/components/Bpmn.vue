<template>
  <div class="bpmn">

    <label for="bpmn-select">Upload BPMN diagram:</label>
    <input type="file" id="bpmn-select" @change="loadDiagram($event)">
    <button v-on:click="submitDiagram">Submit</button>

    <!-- BPMN diagram container -->
    <div id="canvas"></div>
  </div>
</template>

<script>
import Viewer from 'bpmn-js/lib/Viewer'


export default {
  name: 'Bpmn',
  props: ['bus'],
  mounted: function() {
    this.diagramXml = null
    this.viewer = new Viewer({
        container: '#canvas',
        height: 400
      })
    this.setUpViewer()

    this.bus.$on('eth-event-triggered', event => this.highlightEvent(event))
  },
  methods: {
    setUpViewer: function() {

      const eventBus = this.viewer.get('eventBus')
      const clickEvent = 'element.click'

      eventBus.on(clickEvent, e => {
        if (e.element.type === 'bpmn:ServiceTask') {
          this.triggerTask(e.element)
        }
        else {
          console.log('[BPMN] click on ' + e.element + ' ignored')
        }
      })
    },

    triggerTask: function(el) {
      this.toggleElementHighlight(el)

      this.bus.$emit('task-triggered', el)
    },

    toggleElementHighlight: function(el) {
      const highlightableElements = [
        'bpmn:Task',
        'bpmn:ServiceTask'
      ]

      const canvas = this.viewer.get('canvas')

      // if (!hightlightableElements.includes(e.element.type)) {
      //   return
      // }

      if (el.isSelected) {
        el.isSelected = false
        canvas.removeMarker(el.id, 'highlight')
      } else {
        el.isSelected = true
        canvas.addMarker(el.id, 'highlight')
      }
    },

    loadDiagram: function(event) {
      const file = event.target.files.item(0)
      if (file === null) {
        return
      }

      const reader = new FileReader()
      reader.readAsText(file.slice())
      reader.onload = event => {
        this.diagramXml = event.target.result
      }
    },

    submitDiagram: function() {
      this.viewer.importXML(this.diagramXml, err => {
        if (err) {
          alert('upload failed')
          console.log(err)
        } else {
          const canvas = this.viewer.get('canvas')
          canvas.zoom('fit-viewport')
        }
      })
    },

    highlightEvent: function(eventName) {
      this.viewer.get('elementRegistry').getAll()
        .filter(el => el.businessObject.name === eventName)
        .forEach(el => this.toggleElementHighlight(el))
    }
  }
}
</script>

<style scoped>
.bpmn {
  width: 55%;
  padding-top: 50px;
}

#canvas {
  padding-top: 10px;
}

label {
  padding-bottom: 10px;
}
</style>