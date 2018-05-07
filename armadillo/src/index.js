import Viewer from 'bpmn-js/lib/Viewer'
import diagramXML from '../resources/two_lanes.bpmn';

const viewer = new Viewer({
    container: '#canvas',
    height: 400
 })

function handleTaskClick(id) {
    console.log('click on ' + id);
}

viewer.importXML(diagramXML, err => {
    if (err) {
        // :(
    } else {
        const canvas = viewer.get('canvas')
        //canvas.zoom('fit-viewport')

        var eventBus = viewer.get('eventBus');
        var events = [
            'element.click',
          ];

        events.forEach(function(event) {
            eventBus.on(event, function(e) {
              // e.element = the model element
              // e.gfx = the graphical element
              if (e.element.type == 'bpmn:Task') {
                handleTaskClick(e.element.id)
              }
            });
          });
    }
})
