
# Coffee Mailserver Support - https://blog.lowlevelforest.com/

This repository provides a Bash script for setting up and managing a mail server using Postfix and Dovecot. It includes features for creating and managing users, domains, and emails.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [DNS Configuration](#dns-configuration)
- [Examples](#examples)
- [License](#license)

## Prerequisites

- A VPS or dedicated server running Ubuntu.
- Root access to the server.
- Basic knowledge of Linux command line.

## Installation

1. Clone the repository to your server:
   ```bash
   git clone https://github.com/coffeecms/coffee_mailserver_support.git
   cd coffee_mailserver_support
   ```

2. Make the script executable:
   ```bash
   chmod +x mailserver_setup.sh
   ```

3. Run the script:
   ```bash
   sudo ./mailserver_setup.sh
   ```

## Usage

### Main Menu Options

After running the script, you'll see a menu with the following options:

1. **Install Postfix & Dovecot**: Installs and configures the mail server.
2. **Optimize Postfix & Dovecot**: Adjusts settings based on server specifications.
3. **List Domains**: Displays the currently configured domains.
4. **Add Domain**: Adds a new domain to the mail server.
5. **Remove Domain**: Removes an existing domain from the mail server.
6. **Add User**: Creates a new email user.
7. **Create Random Users**: Generates random email users.
8. **Read Email of User**: Allows users to read their emails.
9. **Delete All Emails of a User**: Removes all emails for a specified user.
10. **Delete All Emails**: Permanently deletes all emails from the server.
11. **Delete Emails Older Than n Days**: Deletes emails older than a specified number of days.
12. **Delete Users from File**: Removes users listed in a specified file.
13. **Create Users from File**: Creates users with passwords from a specified file.
14. **Exit**: Closes the script.

### Example Commands

- To add a domain:
  ```bash
  Enter the domain name: example.com
  ```

- To create a user:
  ```bash
  Select a domain: example.com
  Enter the username: user1
  ```

- To read emails for a user:
  ```bash
  Enter user (e.g., user@example.com): user1@example.com
  Enter password: ********
  ```

## DNS Configuration

To ensure your mail server operates correctly, you need to configure DNS records for your domain. Follow these steps:

1. **A Record**: Point your domain to your server's IP address.
   ```
   Type: A
   Host: @
   Value: <your-server-ip>
   TTL: 3600
   ```

2. **MX Record**: Set the mail exchange record for your domain.
   ```
   Type: MX
   Host: @
   Value: mail.example.com
   Priority: 10
   TTL: 3600
   ```

3. **SPF Record**: Add an SPF record to authorize your server to send emails.
   ```
   Type: TXT
   Host: @
   Value: "v=spf1 a mx ip4:<your-server-ip> -all"
   TTL: 3600
   ```

4. **DKIM Record**: If you have DKIM enabled, add the DKIM public key as a TXT record.
   ```
   Type: TXT
   Host: default._domainkey
   Value: "v=DKIM1; k=rsa; p=<your-dkim-public-key>"
   TTL: 3600
   ```

5. **DMARC Record**: Optionally, set up DMARC to control email authentication.
   ```
   Type: TXT
   Host: _dmarc
   Value: "v=DMARC1; p=none; rua=mailto:postmaster@example.com"
   TTL: 3600
   ```

## Examples

### Adding a Domain
After installation, you can add your domain by selecting the option in the menu and entering your domain name.

### Creating a User
Select the domain you want to create a user for and provide a username. The script will generate a random password for you.

### Deleting Emails
To delete emails for a user, select the appropriate option, enter the username, and confirm the action.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


### Notes
- Replace `<your-server-ip>` and `<your-dkim-public-key>` with the actual values for your mail server.
- Ensure that the instructions match the actual behavior of your script, and feel free to customize any sections as needed.