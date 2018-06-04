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
import diagramXml from '../../resources/two_lanes.bpmn'


export default {
  name: 'Bpmn',
  props: ['bus'],
  mounted: function() {
    this.diagramXml = diagramXml
    this.viewer = new Viewer({
        container: '#canvas',
        height: 400
      })
    this.setUpViewer()
    
  },
  methods: {
    setUpViewer: function() {
      const canvas = this.viewer.get('canvas')
      this.viewer.importXML(this.diagramXml, err => {
        if (err) {
          alert('upload failed')
          console.log(err)
        } else {
          canvas.zoom('fit-viewport')
        }
      })

      const eventBus = this.viewer.get('eventBus')
      const clickEvent = 'element.click'

      eventBus.on(clickEvent, e => this.triggerTask(e, canvas))
    },

    triggerTask: function(e, canvas) {
      this.toggleElementHighlight(e, canvas)

      this.bus.$emit('task-triggered', e.element)
    },
    
    toggleElementHighlight: function(e, canvas) {
      const hightlightableElements = [
        'bpmn:Task',
        'bpmn:serviceTask'
      ]

      // TODO what about service tasks etc.
      if (hightlightableElements.includes(e.element.type)) {
        if (e.element.isSelected) {
          e.element.isSelected = false
          canvas.removeMarker(e.element.id, 'highlight')
        } else {
          e.element.isSelected = true
          canvas.addMarker(e.element.id, 'highlight')
        }
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