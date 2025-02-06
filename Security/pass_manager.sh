#!/bin/bash

PASSWORD_FILE="passwords.enc"
SALT_FILE="salt.key"

# Function to generate a salt
generate_salt() {
    if [ ! -f "$SALT_FILE" ]; then
        head -c 16 /dev/urandom > "$SALT_FILE"
    fi
}

# Function to load the salt
load_salt() {
    cat "$SALT_FILE"
}

# Function to derive an encryption key from the master password
derive_key() {
    local master_password="$1"
    local salt=$(load_salt)
    
    echo -n "$master_password$salt" | sha256sum | awk '{print $1}'
}

# Function to encrypt passwords
encrypt_password() {
    local password="$1"
    local key="$2"
    
    # Encrypt the message and output to the terminal
    echo -n "$password" | openssl enc -aes-256-ecb -nosalt -K $key -a

}

# Function to decrypt passwords
decrypt_password() {
    local encrypted_password="$1"
    local key="$2"
    # Decrypt the message and output to the terminal
    echo "$encrypted_password" | openssl enc -aes-256-ecb -d -nosalt -K $key -a

    
}

# Function to save passwords
save_passwords() {
    local key="$1"
    cat passwords.txt | while IFS= read -r line; do
        site=$(echo "$line" | cut -d ':' -f1)
        password=$(echo "$line" | cut -d ':' -f2)
        encrypted_password=$(encrypt_password "$password" "$key")
        echo "$site:$encrypted_password" >> "$PASSWORD_FILE"
    done
    rm passwords.txt
}

# Function to retrieve a password
retrieve_password() {
    local site="$1"
    local key="$2"
    grep "^$site:" "$PASSWORD_FILE" | cut -d ':' -f2 | while IFS= read -r encrypted_password; do
        decrypt_password "$encrypted_password" "$key"
    done
}

# Function to copy password to clipboard
copy_to_clipboard() {
    local site="$1"
    local key="$2"
    local password=$(retrieve_password "$site" "$key")
    echo -n "$password" | xclip -selection clipboard
    echo "Password for $site copied to clipboard."
}

# Main script execution
echo -n "Enter master password: "
stty -echo
read master_password
stty echo
echo

generate_salt
key=$(derive_key "$master_password")

echo "Options:"
echo "1. Add password"
echo "2. Retrieve password"
echo "3. Copy password to clipboard"
echo "4. Exit"
read -p "Choose an option: " choice

case "$choice" in
    1)
        read -p "Enter site name: " site
        echo -n "Enter password: "
        stty -echo
        read password
        stty echo
        echo
        echo "$site:$password" >> passwords.txt
        save_passwords "$key"
        echo "Password saved."
        ;;
    2)
        read -p "Enter site name: " site
        password=$(retrieve_password "$site" "$key")
        echo "Password: $password"
        ;;
    3)
        read -p "Enter site name: " site
        copy_to_clipboard "$site" "$key"
        ;;
    4)
        exit 0
        ;;
    *)
        echo "Invalid option."
        ;;
esac
