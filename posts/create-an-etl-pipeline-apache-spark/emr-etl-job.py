from pyspark.sql import SparkSession
from pyspark.sql import functions as F

S3_INPUT_DATA = '<YOUR_BUCKET_LOCATION_OF_RAW_DATA>'
S3_OUTPUT_DATA = '<YOUR_BUCKET_LOCATION_OF_CLEANED_DATA>'


def main():

    spark = SparkSession.builder.appName("My Demo ETL App").getOrCreate()
    spark.sparkContext.setLogLevel('ERROR')

    # Spark Dataframe (Raw)- Transformation 
    df = spark.read.option("Header", True).option("InferSchema", True).csv(S3_INPUT_DATA)
    
    replacements = {c:c.replace(' ','_') for c in df.columns if ' ' in c}
    final_df = df.select([F.col(c).alias(replacements.get(c, c)) for c in df.columns])

    print(f"Total no. of records in the source data set is : {final_df.count()}")

try:
    final_df.write.mode('overwrite').parquet(S3_OUTPUT_DATA)
    print('The cleaned data is uploaded')
except:
    print('Something went wrong, please check the logs :P')

if __name__ == '__main__':
    main()