/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ua.first.coreference;

import java.io.File;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

/**
 *
 * @author imoreno
 */
class SpanishPronominalAnaphoraStub implements AnaphoraResolutionInterface {

    public SpanishPronominalAnaphoraStub() {
    }

    public String resolveAnaphora(String text) {
        StringBuilder sb = new StringBuilder();
        
        sb.append("<?xml version='1.0' encoding='UTF-8'?>\n<GateDocument>\n<!-- The document's features-->\n");
        sb.append("<GateDocumentFeatures>\n<Feature>\n");
        sb.append("<Name className='java.lang.String'> MimeType</Name>\n");
        sb.append("<Value className='java.lang.String'> >text/xml</Value>\n");
        sb.append("</Feature>\n</GateDocumentFeatures>");
        
        sb.append("<!-- The document content area with serialized nodes -->\n");
        sb.append("<TextWithNodes>\n");
        sb.append("<Node id='0'/>María<Node id='5'/> <Node id='6'/>compró<Node id='12'/> <Node id='13'/>un<Node id='15'/> ");
        sb.append("<Node id='16'/>gato<Node id='20'/> <Node id='21'/>en<Node id='23'/> <Node id='24'/>la<Node id='26'/> ");
        sb.append("<Node id='27'/>tienda<Node id='33'/> <Node id='34'/>de<Node id='36'/> <Node id='37'/>mascotas<Node id='45'/>.<Node id='46'/> ");
        sb.append("<Node id='47'/>Ella<Node id='51'/> <Node id='52'/>lo<Node id='54'/> <Node id='55'/>");
        sb.append("llamo<Node id='59'/> <Node id='60'/>chispas<Node id='67' />.<Node id='68' />");
        sb.append("\n</TextWithNodes>\n");
        
        sb.append("<AnnotationSet></AnnotationSet>\n<AnnotationSet Name='Original markups' ></AnnotationSet>\n");
        
        
        sb.append("<AnnotationSet Name='Discourse Entity markups' >\n");
        sb.append("<Annotation Id='100' Type='DiscourseEntity' StartNode='0' EndNode='5'></Annotation>");
        sb.append("<Annotation Id='101' Type='DiscourseEntity' StartNode='16' EndNode='20'</Annotation>");
        sb.append("</Annotation>\n");
        
        sb.append("<AnnotationSet Name='Anaphora markups' >\n");
        sb.append("<Annotation Id='200' Type='PronounAnaphora' StartNode='47' EndNode='51'>\n");
        sb.append("<Feature> \n <Name className='java.lang.String'>StartNodeAntecedent</Name>\n");
        sb.append("<Value className='java.lang.String'>0</Value>\n</Feature>\n");
        sb.append("<Feature>\n<Name className='java.lang.String'>EndNodeAntecedent</Name>\n");
        sb.append("<Value className='java.lang.String'>5</Value>\n</Feature>\n");
        sb.append("<Feature>\n<Name className='java.lang.String'>confidence</Name>\n");
        sb.append("<Value className='java.lang.String'>0.70</Value>\n</Feature>\n");
        sb.append("<Feature>\n<Name className='java.lang.String'>AntecedentId</Name>\n");
        sb.append("<Value className='java.lang.String'>100</Value>\n</Feature>\n");      
        sb.append("</Annotation>\n");
        
        sb.append("<Annotation Id='201' Type='PronounAnaphora' StartNode='52' EndNode='54'>\n");
        sb.append("<Feature> \n <Name className='java.lang.String'>StartNodeAntecedent</Name>\n");
        sb.append("<Value className='java.lang.String'>16</Value>\n</Feature>\n");
        sb.append("<Feature>\n<Name className='java.lang.String'>EndNodeAntecedent</Name>\n");
        sb.append("<Value className='java.lang.String'>20</Value>\n</Feature>\n");
         sb.append("<Feature>\n<Name className='java.lang.String'>confidence</Name>\n");
        sb.append("<Value className='java.lang.String'>0.70</Value>\n</Feature>\n");
        sb.append("<Feature>\n<Name className='java.lang.String'>AntecedentId</Name>\n");
        sb.append("<Value className='java.lang.String'>101</Value>\n</Feature>\n");      
        sb.append("</Annotation>\n");

        sb.append("</AnnotationSet>\n</GateDocument>");
        
        return sb.toString();
    }

    public String resolveAnaphora(String text, File outputFreeling, int nextID, Element as, Document doc) throws AnaphoraResolutionException {
        return resolveAnaphora(text);
    }
    
}
