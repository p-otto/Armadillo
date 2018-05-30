import Viewer from 'bpmn-js/lib/Viewer'
import diagramXML from '../../resources/two_lanes.bpmn';

window.BPMNEngine = {
    start: function() {
        const viewer = new Viewer({
            container: '#canvas',
            height: 400
         })

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
        });
    },

    handleTaskClick: function(id) {
        console.log('click on ' + id);
    }
}

window.addEventListener('load', function() {
  BPMNEngine.start();
});
