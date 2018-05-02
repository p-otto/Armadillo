import Modeler from 'bpmn-js/lib/Modeler'
import diagramXML from '../resources/newDiagram.bpmn';

const modeler = new Modeler({ container: '#canvas' })

modeler.importXML(diagramXML, err => {
    if (err) {
        // :(
    } else {
        const canvas = modeler.get('canvas')
        canvas.zoom('fit-viewport')
    }
})