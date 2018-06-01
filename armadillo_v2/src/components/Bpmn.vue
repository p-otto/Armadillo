<template>
  <div class="bpmn">
    <!-- BPMN diagram container -->
    <div id="canvas"></div>

    <label for="bpmn-select">Upload BPMN diagram:</label>
    <input type="file" id="bpmn-select" @change="loadDiagram($event)">
    <button v-on:click="submitDiagram">Submit</button>
  </div>
</template>

<script>
import Viewer from 'bpmn-js/lib/Viewer'
import diagramXml from '../../resources/two_lanes.bpmn'


export default {
  name: 'Bpmn',
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

      eventBus.on(clickEvent, e => this.toggleElementHighlight(e, canvas))
    },

    toggleElementHighlight: function(e, canvas) {
      // TODO what about service tasks etc.
      if (e.element.type === 'bpmn:Task') {
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
  padding-top: 10px;
}
</style>