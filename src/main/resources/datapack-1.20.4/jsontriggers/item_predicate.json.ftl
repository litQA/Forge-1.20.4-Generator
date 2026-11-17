${input$item}
<#if field$min?number gt 1 || field$max?number lt 99>
,"count": {
  "min": ${field$min},
  "max": ${field$max}
}
</#if>
<#list input_list$predicateComponent as comp>
,${comp}
</#list>
