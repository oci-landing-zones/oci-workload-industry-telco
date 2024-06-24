#!/bin/bash

# Define the new KMS key ID
NEW_KMS_KEY_ID=$3

# Check if the NEW_KMS_KEY_ID is set
if [ -z "$NEW_KMS_KEY_ID" ]; then
  echo "Error: NEW_KMS_KEY_ID is not set. Please update the script with the new KMS key ID."
  exit 1
fi

# Define the availability domain and compartment ID
AVAILABILITY_DOMAIN=$1
COMPARTMENT_ID=$2

# Fetch the boot volume IDs
BOOT_VOLUME_IDS=$(oci bv boot-volume list \
  --availability-domain $AVAILABILITY_DOMAIN \
  --compartment-id $COMPARTMENT_ID \
  | grep -i '"id":' | cut -d '"' -f 4)

# Check if any boot volume IDs were found
if [ -z "$BOOT_VOLUME_IDS" ]; then
  echo "No boot volumes found in the specified availability domain and compartment."
  exit 1
fi

# Loop through each boot volume ID and update the KMS key
for BOOT_VOLUME_ID in $BOOT_VOLUME_IDS; do
  echo "Updating KMS key for boot volume ID: $BOOT_VOLUME_ID"
  oci bv boot-volume-kms-key update --boot-volume-id $BOOT_VOLUME_ID --kms-key-id $NEW_KMS_KEY_ID

  # Check if the update was successful
  if [ $? -eq 0 ]; then
    echo "Successfully updated KMS key for boot volume ID: $BOOT_VOLUME_ID"
  else
    echo "Failed to update KMS key for boot volume ID: $BOOT_VOLUME_ID"
  fi
done

echo "Script completed."