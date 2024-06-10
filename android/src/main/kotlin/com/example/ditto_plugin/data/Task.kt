package com.example.ditto_plugin.data

import live.ditto.DittoDocument
import java.util.*

data class Task(
    val id: String = UUID.randomUUID().toString(),
    val body: String,
    val isCompleted: Boolean
) {
    constructor(document: DittoDocument) : this(
        document["id"].stringValue,
        document["body"].stringValue,
        document["isCompleted"].booleanValue
    ) {

    }
}
