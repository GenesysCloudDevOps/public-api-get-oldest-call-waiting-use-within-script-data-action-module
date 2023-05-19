resource "genesyscloud_integration_action" "action" {
    name           = var.action_name
    category       = var.action_category
    integration_id = var.integration_id
    secure         = var.secure_data_action
    
    contract_input  = jsonencode({
        "$schema" = "http://json-schema.org/draft-04/schema#",
        "description" = "The oldest call waiting for a queue.",
        "properties" = {
            "INTERVAL" = {
                "description" = "The interval",
                "type" = "string"
            },
            "QUEUE_ID" = {
                "description" = "The queue ID.",
                "type" = "string"
            }
        },
        "required" = [
            "QUEUE_ID",
            "INTERVAL"
        ],
        "title" = "Oldest Call Waiting",
        "type" = "object"
    })
    contract_output = jsonencode({
        "$schema" = "http://json-schema.org/draft-04/schema#",
        "description" = "Returns the oldest call waiting",
        "properties" = {
            "OLDEST_CALL_WAITING" = {
                "description" = "oldest call waiting in the queue",
                "type" = "string"
            }
        },
        "title" = "Oldest Call Waiting",
        "type" = "object"
    })
    
    config_request {
        request_template     = "{\n\t \"interval\": \"$${input.INTERVAL}\",\n\t \"order\": \"asc\",\n\t \"orderBy\": \"conversationStart\",\n\t \"paging\": {\n\t  \"pageSize\": 25,\n\t  \"pageNumber\": 1\n\t },\n\t \"segmentFilters\": [\n\t  {\n\t   \"type\": \"and\",\n\t   \"predicates\": [\n\t    {\n\t     \"type\": \"dimension\",\n\t     \"dimension\": \"queueId\",\n\t     \"operator\": \"matches\",\n\t     \"value\": \"$${input.QUEUE_ID}\"\n\t    },\n\t   \t{\n\t     \"type\": \"dimension\",\n\t     \"dimension\": \"userId\",\n\t     \"operator\": \"notExists\",\n\t     \"value\": null\n\t    }\n\t   ]\n\t  }\n\t ],\n\t \"conversationFilters\": [\n\t  {\n\t   \"type\": \"and\",\n\t   \"predicates\": [\n\t    {\n\t     \"type\": \"dimension\",\n\t     \"dimension\": \"conversationEnd\",\n\t     \"operator\": \"notExists\",\n\t     \"value\": null\n\t    }\n\t   ]\n\t  }\n\t ]\n}"
        request_type         = "POST"
        request_url_template = "/api/v2/analytics/conversations/details/query"
        headers = {
			Content-Type = "application/json"
		}
    }

    config_response {
        success_template = "{\n   \"OLDEST_CALL_WAITING\": $${OLDEST_CALL_WAITING}\n }"
        translation_map = { 
			OLDEST_CALL_WAITING = "$.conversations[0].conversationStart"
		}
        translation_map_defaults = {       
			OLDEST_CALL_WAITING = "null"
		}
    }
}