# cs282_final_project

# Setting up the data
## MIMIC-III Data Processing with Google Cloud

This repository details the process of handling and processing the MIMIC-III dataset using Google Cloud services.

### Step 1: Copying MIMIC-III Data to Personal Bucket

Initially, I copied the MIMIC-III dataset from a public Google Cloud Storage bucket to my own:

```bash
gsutil -m cp -r gs://[SOURCE_BUCKET_NAME]/* gs://[MY_BUCKET_NAME]/
```

### Step 2: Setting Up Google Cloud SDK

Configured Google Cloud SDK on my local machine for cloud interactions:

```bash
gcloud auth login
gcloud config set project [MY_PROJECT_ID]
```

### Step 3: Deploying a Cloud Function

Created a Python script `main.py` for a Google Cloud Function to uncompress `.gz` files. The function is triggered upon new object creation in the bucket.

Deployed the function:

```bash
gcloud functions deploy uncompress_gzip --runtime python37 --trigger-resource [MY_BUCKET_NAME] --trigger-event google.storage.object.finalize
```

### Step 4: Triggering Function for Existing Files

Used the following script to trigger the function for existing `.gz` files in the bucket:

```bash
for file in $(gsutil ls gs://[MY_BUCKET_NAME]/*.gz); do
    gsutil cp $file ${file%.gz}_copy.gz
done
```

### Step 5: Renaming Processed Files

After processing, renamed the unzipped files to remove the `_copy` suffix:

```bash
for file in $(gsutil ls gs://[MY_BUCKET_NAME]/*_copy); do
    new_file=$(echo $file | sed 's/_copy//')
    gsutil mv $file $new_file
done
```

This README provides an overview of how I utilized Google Cloud services to manage and process the large MIMIC-III dataset, demonstrating the power and flexibility of cloud computing in data science.

---

*Note: Replace placeholder text (e.g., `[MY_BUCKET_NAME]`) with actual bucket and project names.*
