#!/bin/bash

# Function to check if postfix and dovecot are installed
check_installation() {
    if ! dpkg -l | grep -q postfix; then
        return 1
    fi
    if ! dpkg -l | grep -q dovecot; then
        return 1
    fi
    return 0
}

# Function to install postfix and dovecot
install_postfix_dovecot() {
    apt update
    apt install -y postfix dovecot-core dovecot-imapd
    # Basic configuration for postfix and dovecot
    postconf -e 'myhostname = mail.example.com'
    postconf -e 'mydomain = example.com'
    postconf -e 'mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain'
    systemctl restart postfix
    systemctl restart dovecot
}

# Function to optimize postfix and dovecot
optimize_services() {
    postconf -e 'default_process_limit = 100'
    postconf -e 'smtpd_client_connection_count_limit = 100'
    systemctl restart postfix
    systemctl restart dovecot
}

# Function to list domains
list_domains() {
    postmap -q "*" /etc/postfix/virtual | cut -d' ' -f1
}

# Function to add a domain
add_domain() {
    read -p "Enter the domain name: " domain
    echo "$domain" >> /etc/postfix/virtual
    postmap /etc/postfix/virtual
    systemctl restart postfix
}

# Function to remove a domain
remove_domain() {
    read -p "Enter the domain name to remove: " domain
    sed -i "/^$domain/d" /etc/postfix/virtual
    postmap /etc/postfix/virtual
    systemctl restart postfix
}

# Function to add a user
add_user() {
    domains=$(list_domains)
    echo "List of domains:"
    echo "$domains"
    read -p "Select a domain: " domain
    read -p "Enter the username: " user
    password=$(openssl rand -base64 12)
    echo "$user@$domain $password" >> /etc/postfix/users
    echo "$user:$password" | chpasswd
}

# Function to create random users
create_random_users() {
    domains=$(list_domains)
    echo "List of domains:"
    
    if [[ -z "$domains" ]]; then
        echo "No domains available. Please add a domain first."
        return
    fi
    
    read -p "Select a domain: " domain
    read -p "Enter the number of random emails to create: " count
    output_file="/etc/emails_account_$(date +%d_%m_%Y).txt"
    
    for i in $(seq 1 $count); do
        firstname=$(shuf -n 1 /usr/share/dict/words)
        lastname=$(shuf -n 1 /usr/share/dict/words)
        random_char=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 1)
        user="${firstname}.${lastname}${random_char}"
        password=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 8)
        
        # Add user to postfix
        echo "$user@$domain" >> /etc/postfix/virtual
        echo "$user:$password" | chpasswd
        
        # Write information to file
        echo "$user@$domain $password" >> "$output_file"
    done
    
    # Update postfix configuration
    postmap /etc/postfix/virtual
    systemctl restart postfix
    
    echo "User list has been saved to $output_file"
}

# Function to read emails of a user
read_email_of_user() {
    read -p "Enter user (e.g., user@example.com): " user
    read -sp "Enter password: " password
    echo
    
    # Authenticate user (assumes Dovecot is configured to support this)
    if dovecot-authenticate "$user" "$password"; then
        # Fetch email
        emails=$(fetchmail --user "$user" --password "$password" --mda "/usr/bin/procmail" 2>&1)
        
        # Display the top 5 newest emails
        echo "Top 5 newest emails for $user:"
        echo "$emails" | head -n 5
    else
        echo "Invalid login credentials."
    fi
}

# Function to delete all emails of a user
delete_user_emails() {
    read -p "Enter user (e.g., user@example.com) to delete all emails: " user
    
    # Check if user exists
    if grep -q "$user" /etc/postfix/virtual; then
        # Command to delete emails (assumes maildir format)
        rm -rf /var/mail/$user/*
        echo "All emails for $user have been deleted."
    else
        echo "User does not exist."
    fi
}

# Function to delete all emails
delete_all_emails() {
    read -p "Are you sure you want to delete all emails? (y/n): " confirmation
    if [[ "$confirmation" == "y" ]]; then
        rm -rf /var/mail/*/*
        echo "All emails have been deleted."
    else
        echo "Operation canceled."
    fi
}

# Function to delete emails older than n days
delete_emails_older_than_n_days() {
    read -p "Enter the number of days: " days
    find /var/mail/* -type f -mtime +$days -exec rm {} \;
    echo "Emails older than $days days have been deleted."
}

# Function to delete users listed in a file
delete_users_from_file() {
    while IFS= read -r user; do
        # Remove user
        userdel "$user"
        echo "Deleted user: $user"
    done < /etc/users_delete.txt
}

# Function to create users from a file
create_users_from_file() {
    while IFS= read -r line; do
        IFS=' ' read -r user password <<< "$line"
        echo "$user:$password" | chpasswd
        echo "$user has been created."
    done < /etc/users_add.txt
}

# Main menu
while true; do
    clear
    echo "1. Install postfix & dovecot"
    echo "2. Optimize postfix & dovecot"
    echo "3. List domains"
    echo "4. Add domain"
    echo "5. Remove domain"
    echo "6. Add user"
    echo "7. Create random users"
    echo "8. Read email of user"
    echo "9. Delete all emails of a user"
    echo "10. Delete all emails"
    echo "11. Delete emails older than n days"
    echo "12. Delete users from file"
    echo "13. Create users from file"
    echo "14. Exit"
    read -p "Select an option: " choice

    case $choice in
        1)
            if check_installation; then
                echo "Postfix and Dovecot are already installed."
            else
                install_postfix_dovecot
            fi
            ;;
        2)
            optimize_services
            ;;
        3)
            list_domains
            read -p "Press Enter to continue..."
            ;;
        4)
            add_domain
            ;;
        5)
            remove_domain
            ;;
        6)
            add_user
            ;;
        7)
            create_random_users
            ;;
        8)
            read_email_of_user
            ;;
        9)
            delete_user_emails
            ;;
        10)
            delete_all_emails
            ;;
        11)
            delete_emails_older_than_n_days
            ;;
        12)
            delete_users_from_file
            ;;
        13)
            create_users_from_file
            ;;
        14)
            exit 0
            ;;
        *)
            echo "Invalid choice!"
            ;;
    esac
done
