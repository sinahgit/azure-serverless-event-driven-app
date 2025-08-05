import csv
import logging
import os

import azure.functions as func
from azure.cosmos import CosmosClient, PartitionKey
from azure.eventgrid import EventGridEvent, EventGridPublisherClient
from azure.core.credentials import AzureKeyCredential

COSMOS_CONN = os.getenv('CosmosDBConnection')
EVENTGRID_ENDPOINT = os.getenv('EventGridTopicEndpoint')
EVENTGRID_KEY = os.getenv('EventGridTopicKey')

cosmos_client = CosmosClient.from_connection_string(COSMOS_CONN) if COSMOS_CONN else None
if cosmos_client:
    database = cosmos_client.create_database_if_not_exists('files')
    container = database.create_container_if_not_exists(
        id='rows',
        partition_key=PartitionKey(path='/id'),
        offer_throughput=400,
    )
else:
    container = None

event_client = (
    EventGridPublisherClient(EVENTGRID_ENDPOINT, AzureKeyCredential(EVENTGRID_KEY))
    if EVENTGRID_ENDPOINT and EVENTGRID_KEY
    else None
)

def main(blob: func.InputStream) -> None:
    """Triggered when a CSV file is uploaded to Blob Storage."""
    logging.info("Processing blob %s, size %s bytes", blob.name, blob.length)

    lines = blob.read().decode('utf-8').splitlines()
    reader = csv.DictReader(lines)

    rows = [row for row in reader]
    for row in rows:
        container.upsert_item(dict(row))

    event = EventGridEvent(
        subject=blob.name,
        data={"fileName": blob.name, "rowCount": len(rows)},
        event_type="FileProcessed",
        data_version="1.0",
    )

    event_client.send([event])
    logging.info("Processed %s rows and sent event", len(rows))
