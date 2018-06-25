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

    this.bus.$on('eth-event-triggered', event => this.highlightEvent(event))
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
      if (el.parent.type === 'bpmn:Participant') {
        this.validateRole(el)
      }
      this.highlightElement(el)
      this.bus.$emit('task-triggered', el.businessObject.name)
    },

    validateRole: function(el) {
      const roleName = this.getRoleName(el)
      this.bus.$emit('role-validation-required', roleName)
    },

    getRoleName: function(el) {
      if (el.businessObject.di.bpmnElement.lanes) {
        // if the task is contained in a lane, use the lane name
        return el.businessObject.di.bpmnElement.lanes[0].name
      } else {
        // use the pool name as role name
        return el.parent.businessObject.name
      }
    },

    highlightElement: function(el) {
      const canvas = this.viewer.get('canvas')
      canvas.addMarker(el.id, 'highlight')

    },

    resetElementHighlighting: function(el) {
      const canvas = this.viewer.get('canvas')
      canvas.removeMarker(el.id, 'highlight')
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
    
    highlightEvent: function(eventName) {
      this.viewer.get('elementRegistry').getAll()
        .filter(el => el.businessObject.name === eventName)
        .forEach(el => this.highlightElement(el))
    },

    resetHighlighting: function() {
      this.viewer.get('elementRegistry').getAll()
        .forEach(el => this.resetElementHighlighting(el))
    }
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
