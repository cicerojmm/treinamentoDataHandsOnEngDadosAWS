from awsglue.context import GlueContext
from pyspark.context import SparkContext
from pyspark.sql import functions as F
from pyspark.sql.avro.functions import from_avro
import requests


def get_spark_context():
    sc = SparkContext()
    glueContext = GlueContext(sc)
    return glueContext.spark_session


def get_avro_schema(schema_registry: str, topic: str) -> str:
    subject = f"{topic}-value"
    url = f"{schema_registry}/subjects/{subject}/versions/latest/schema"
    return requests.get(url).text


def read_from_kafka(spark, kafka_bootstrap: str, topic: str):
    return (
        spark.readStream
        .format("kafka")
        .option("kafka.bootstrap.servers", kafka_bootstrap)
        .option("subscribe", topic)
        .option("startingOffsets", "earliest")
        .option("failOnDataLoss", "false")
        .load()
    )


def decode_avro(df, schema_json: str):
    # Remove magic bytes do Confluent
    value_bytes = F.expr("substring(value, 6, length(value)-5)")
    return df.select(from_avro(value_bytes, schema_json).alias("data"))


def transform_data(decoded_df):
    final_df = (
        decoded_df
        .select(
            F.when(F.col("data.op") == "d", F.col("data.before"))
             .otherwise(F.col("data.after")).alias("row"),
            "data.op", "data.ts_ms"
        )
        .select("row.*", "op", "ts_ms")
    )
    
    from pyspark.sql.functions import col, to_timestamp

    final_df = final_df.withColumn(
        "event_timestamp",
        to_timestamp(col("event_timestamp"), "yyyy-MM-dd HH:mm:ss.SSSSSS")
    )

    # Drop colunas que não queremos
    cols_to_drop = [
        "ip_address", "browser_name", "browser_user_agent",
        "browser_language", "os", "os_name",
        "device_type", "device_is_mobile", "user_custom_id"
    ]
    return final_df.drop(*cols_to_drop)


def write_to_opensearch(df, server: str, checkpoint_path: str, index_opensearch: str):
    return (
        df.writeStream
        .format("opensearch")
        .option("opensearch.nodes", f"https://{server}:9200")
        .option("opensearch.index.auto.create", "true")
        .option("opensearch.resource", index_opensearch)
        .option("opensearch.net.http.auth.user", "admin")
        .option("opensearch.net.http.auth.pass", "Mds2025123456")
        .option("opensearch.nodes.wan.only", "true")
        .option("opensearch.net.ssl", "true")
        .option("opensearch.net.ssl.cert.allow.self.signed", "true")
        .option("checkpointLocation", checkpoint_path)
        .outputMode("append")
        .start()
    )


def main():
    SERVER = "ec2-3-142-48-245.us-east-2.compute.amazonaws.com"
    topic = "ecommercefinal.public.web_events"
    kafka_bootstrap = f"{SERVER}:29092"
    schema_registry = f"http://{SERVER}:8081"
    checkpoint_path = "s3://cjmm-mds-lake-logs/spark/teste"
    index_opensearch = "ecommerce_web_events_cinco"

    spark = get_spark_context()
    schema_json = get_avro_schema(schema_registry, topic)

    kafka_df = read_from_kafka(spark, kafka_bootstrap, topic)
    decoded_df = decode_avro(kafka_df, schema_json)
    transformed_df = transform_data(decoded_df)

    query = write_to_opensearch(transformed_df, SERVER, checkpoint_path, index_opensearch)
    query.awaitTermination()


if __name__ == "__main__":
    main()
