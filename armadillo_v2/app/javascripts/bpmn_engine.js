import Viewer from 'bpmn-js/lib/Viewer'
import diagramXML from '../../resources/two_lanes.bpmn'

window.addEventListener('load', function () {
  window.BPMNViewer = new Viewer({
    container: '#canvas',
    height: 400
  })

  BPMNEngine.start()

  document.getElementById('bpmn_select').addEventListener('change', BPMNEngine.handleFileChanged, false)
})

window.BPMNEngine = {
  start: function () {
    const eventBus = BPMNViewer.get('eventBus')
    const clickEvent = 'element.click'

    eventBus.on(clickEvent, e => toggleElementHighlight(e))

    BPMNViewer.importXML(diagramXML, err => {
      if (err) {
        alert('upload failed')
      } else {
        const canvas = BPMNViewer.get('canvas')
        canvas.zoom('fit-viewport')
      }
    })
  },

  toggleElementHighlight: (e, canvas) => {
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

  handleFileChanged: function (event) {
    const file = event.target.files.item(0)
    if (file === null) {
      return
    }

    const reader = new FileReader()
    reader.readAsText(file.slice())
    const bpmnXml = reader.result

    BPMNViewer.importXML(bpmnXml, err => {
      if (err) {
        alert('upload failed')
      } else {
        const canvas = BPMNViewer.get('canvas')
        canvas.zoom('fit-viewport')
      }
    })
  }
}
