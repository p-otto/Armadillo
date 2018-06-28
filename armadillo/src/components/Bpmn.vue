<template>
  <div class="bpmn">

    <label for="bpmn-select">Upload BPMN diagram:</label>
    <input type="file" id="bpmn-select" @change="loadDiagram($event)">

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
    this.registerClickEvents()

    this.bus.$on('eth-call-succeeded', taskName => this.highlightTask(taskName))
    this.bus.$on('eth-call-failed', taskName => this.resetTaskHighlight(taskName))
    this.bus.$on('eth-event-triggered', ethEventName => this.highlightEvent(ethEventName))
    this.bus.$on('instance-terminated', () => this.resetHighlighting())
  },
  methods: {
    registerClickEvents: function() {

      const eventBus = this.viewer.get('eventBus')
      const clickEvent = 'element.click'

      eventBus.on(clickEvent, e => {
        if (e.element.type === 'bpmn:ServiceTask') {
          this.triggerTask(e.element)
        } else if (e.element.type === 'bpmn:Task') {
          this.highlightElement(e.element)
        } else {
          console.log('[BPMN] click on ' + e.element + ' ignored')
        }
      })
    },

    triggerTask: function(el) {
      this.highlightElement(el, 'lesser-highlight')
      this.bus.$emit('task-triggered', el.businessObject.name)
    },

    loadDiagram: function(event) {
      const file = event.target.files.item(0)
      if (file === null) {
        return
      }

      const reader = new FileReader()
      reader.readAsText(file.slice())
      reader.onload = event => {
        this.viewer.importXML(event.target.result, err => {
          if (err) {
            alert('upload failed')
            console.log(err)
          } else {
            const canvas = this.viewer.get('canvas')
            canvas.zoom('fit-viewport')
          }
        })
      }
    },

    highlightElement: function(el, marker) {
      const canvas = this.viewer.get('canvas')
      canvas.addMarker(el.id, marker ? marker : 'highlight')
    },

    highlightTask: function(taskName) {
      const task = this.viewer.get('elementRegistry').getAll()
        .filter(el => el.businessObject.name === taskName)[0]
      this.resetTaskHighlight(taskName)
      this.highlightElement(task)
    },

    resetTaskHighlight: function(taskName) {
      const task = this.viewer.get('elementRegistry').getAll()
        .filter(el => el.businessObject.name === taskName)[0]
      const canvas = this.viewer.get('canvas')
      canvas.removeMarker(task.id, 'highlight')
      canvas.removeMarker(task.id, 'lesser-highlight')
    },

    highlightEvent: function(ethEventName) {
      const event = this.viewer.get('elementRegistry').getAll()
        .filter(el => this.toEthEventName(el.businessObject.name) === ethEventName)[0]
      this.highlightElement(event)
    },

    resetHighlighting: function() {
      const canvas = this.viewer.get('canvas')
      this.viewer.get('elementRegistry').getAll()
        .forEach(el => {
          canvas.removeMarker(el.id, 'highlight')
          canvas.removeMarker(el.id, 'lesser-highlight')
        })
    },

    toEthEventName: function(str) {
      if (!str) {
        return ''
      }

      return str
        .replace(/\s(.)/g, letter => letter.toUpperCase())
        .replace(/\s/g, '')
    }

    /*getRoleName: function(el) {
      if (el.businessObject.di.bpmnElement.lanes) {
        // if the task is contained in a lane, use the lane name
        return el.businessObject.di.bpmnElement.lanes[0].name
      } else {
        // use the pool name as role name
        return el.parent.businessObject.name
      }
    },*/
  }
}
</script>

<style scoped>
.bpmn {
  width: 55%;
  padding-top: 50px;
  padding-left: 50px;
}

#canvas {
  padding-top: 10px;
}

label {
  padding-bottom: 10px;
}
</style>
