terraform {
  required_version = ">= 1.5.0"

  required_providers {
    freebox = {
      source  = "nikolalohinski/freebox"
      version = "2.7.0"
    }
  }
}
