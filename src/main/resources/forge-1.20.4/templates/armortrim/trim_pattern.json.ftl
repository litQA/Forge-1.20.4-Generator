<#include "../mcitems_json.ftl">
{
  "asset_id": "${modid}:${registryname}",
  "decal": false,
  "description": {
    "translate": "trim_pattern.${modid}.${registryname}"
  },
  "template_item": "${mappedMCItemToRegistryName(data.item, true)}"
}