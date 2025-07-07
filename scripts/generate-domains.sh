#!/usr/bin/env bash
set -e

# Domain generation script for batch operations
DOMAINS_FILE="${1:-domains.txt}"
TYPE="${2:-application}"

if [ ! -f "$DOMAINS_FILE" ]; then
    echo "Creating example domains.txt file..."
    cat > domains.txt << EOF
allocation
payments
invoicing
inventory
shipping
analytics
EOF
    echo "Edit domains.txt and run again: ./scripts/generate-domains.sh"
    exit 0
fi

echo "Reading domains from $DOMAINS_FILE..."
while IFS= read -r domain || [ -n "$domain" ]; do
    # Skip empty lines and comments
    [[ -z "$domain" || "$domain" =~ ^#.*$ ]] && continue

    echo "Creating $TYPE stack for domain: $domain"
    make domain-stack DOMAIN="$domain"
done < "$DOMAINS_FILE"

echo "Domain generation complete!"
