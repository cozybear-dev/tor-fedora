terraform {
    required_providers {
        google = {
            source  = "hashicorp/google"
            version = ">= 6.28.0"
        }
        google-beta = {
            source  = "hashicorp/google-beta"
            version = ">= 6.28.0"
        }
        random = {
            source  = "hashicorp/random"
            version = ">= 3.7.1"
        }
        ct = {
            source  = "cozybear-dev/ct"
            version = ">= 0.15.0"
        }
    }
    required_version = ">= 1.11.3"
}