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
  data: () => {
    return {
      taskTypes: [
        'bpmn:Task',
        'bpmn:ServiceTask'
      ]
    }
  },
  mounted: function() {
    this.diagramXml = null
    this.viewer = new Viewer({
        container: '#canvas',
        height: 400
      })
    this.registerClickEvents()

    this.bus.$on('eth-event-triggered', event => this.highlightEvent(event))
  },
  methods: {
    registerClickEvents: function() {

      const eventBus = this.viewer.get('eventBus')
      const clickEvent = 'element.click'

      eventBus.on(clickEvent, e => {
        if (this.taskTypes.includes(e.element.type)) {
          this.triggerTask(e.element)
        } else {
          console.log('[BPMN] click on ' + e.element + ' ignored')
        }
      })
    },

    triggerTask: function(el) {
      if (el.parent.type === 'bpmn:Participant') {
        this.validateRole(el)
      }
      this.toggleElementHighlight(el)
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

    toggleElementHighlight: function(el) {
      const canvas = this.viewer.get('canvas')

      // if (!this.hightlightableElements.includes(e.element.type)) {
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
  padding-left: 50px;
}

#canvas {
  padding-top: 10px;
}

label {
  padding-bottom: 10px;
}
</style>
