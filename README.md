# AwsUse

AwsUse is a simple PowerShell utility that lets you switch between multiple AWS accounts from the command line with ease.
It gives you quick access to 3 handy commands:

* `awsuse select <profile>` — Set the selected profile as the current default AWS account.
* `awsuse whoami` — Print the name of the currently active AWS profile.
* `awsuse list` — List all available AWS profiles defined in the script.

---

## 🔧 Setup Instructions

### 1. Clone or download this repository

```
git clone https://github.com/FazlOmar9/AwsUse.git
```

**Important:** You need **both** files: `awsuse.ps1` and `awsuse.cmd`
The `.ps1` script does the work, and the `.cmd` file lets you call `awsuse` easily from any terminal.

---

### 2. Add your AWS accounts

Open `awsuse.ps1` in a text editor and find this section:

```
$accounts = @{
    "main" = @{
        aws_access_key_id = "YOUR_KEY"
        aws_secret_access_key = "YOUR_SECRET"
        region = "ap-south-1"
    }
    "veritex" = @{
        aws_access_key_id = "YOUR_KEY"
        aws_secret_access_key = "YOUR_SECRET"
        region = "us-east-1"
    }
}
```

* Replace the values with your own access keys and regions.
* Add or remove accounts as needed — the key names like `"main"` or `"veritex"` are the profile names you’ll use with `awsuse select`.

---

### 3. Add it to your system PATH

To use `awsuse` from any PowerShell or CMD window:

1. Keep both `awsuse.ps1` and `awsuse.cmd` in a permanent folder (e.g., `C:\Scripts\`).
2. Add that folder to your system `PATH`:

   * Press `Win + S`, search for **"Environment Variables"**.
   * Edit the **System variables** section → Find and edit the `Path` variable.
   * Add the path to the folder (e.g., `C:\Scripts`).
3. Restart your terminal.

Now you can run `awsuse` from anywhere like this:

```
awsuse select main
awsuse whoami
awsuse list
```

---

## 📁 How It Works

* When you `select` an account, it **overwrites** your default AWS config (`~/.aws/credentials` and `~/.aws/config`) with the selected account’s keys and region.
* This way, the AWS CLI and SDKs will always use that account without requiring a `--profile` flag.

---

## 💡 Why Use AwsUse?

* No need to remember or export environment variables.
* No need to pass `--profile` to every CLI command.
* Easy to switch accounts persistently from any PowerShell session.

---

## ⚠️ Warning

This tool stores AWS credentials in plain text within the script file.
**Use with caution and avoid committing sensitive keys to GitHub.**

---

## ✅ License

MIT License — do what you want, but don't blame me if you break something. 😊
