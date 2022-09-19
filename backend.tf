terraform {
  backend "gcs" {
        bucket = "state-file-mt4015"
        prefix = "#{backend-value}#-tf.tfstate"
        credentials = file("serviceaccount.json")
  }
}