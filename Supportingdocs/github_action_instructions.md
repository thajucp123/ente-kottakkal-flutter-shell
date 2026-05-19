#### What are GitHub Actions?
GitHub Actions is a tool built into GitHub that automatically runs scripts whenever something happens to your code repository. This process is called CI/CD (Continuous Integration / Continuous Delivery).Instead of building the release file manually on your computer using Docker, GitHub Actions does it for you in the cloud.

#### How it works for your project:
You write code on your computer.You push a code change to GitHub.GitHub automatically wakes up a powerful, clean virtual computer in the cloud.This cloud computer loads Docker, compiles your Flutter project into a signed Play Store .aab bundle, and saves it.You log into GitHub and download your finished app bundle.How to set up a GitHub Actions Workflow for your Flutter AppTo set this up, you don't even need to write a Dockerfile yourself. GitHub has pre-made "Actions" that handle the Flutter and Android environments automatically.
1. Add your Keys to GitHub (Crucial for Security)You must never upload your key.properties or your .jks keystore file directly to GitHub because anyone could steal your app credentials. Instead, you save them as Secrets:
- Open your project on GitHub in a web browser.
- Go to Settings -> Secrets and variables -> Actions.
- Create a secret named KEYSTORE_BASE64. (You will convert your .jks file to a text string using a base64 tool and paste it here). this base 64 text file is in this folder.
- Create secrets for STORE_PASSWORD, KEY_PASSWORD, and KEY_ALIAS.
2. Create the Workflow FileIn your local Flutter project folder, create a series of folders exactly like this: .github/workflows/. Inside that workflows folder, create a file named android-release.yml. **(this code provided in the workflows folder in this)**

#### How to use this workflow:
The next time you type `git push origin main`, navigate to the Actions tab on your GitHub repository page. You will see a live terminal displaying the cloud server fetching your repository, reading this script, and compiling your Flutter code. Within 5 to 10 minutes, a green checkmark will appear, providing a downloadable link to your complete app.aab bundle file.

#### Where is the file actually stored?
When the cloud runner finishes compiling your Flutter app, the `actions/upload-artifact@v4` step extracts the .aab file and attaches it to that specific execution history log as a temporary attachment. It acts exactly like an email attachment. Your source code repository is the email body, and the .aab/.apk file is just a file clipped onto the side of the sent log. 
- By default, GitHub holds this file on its servers for 90 days so you can log into the website and download it.
- After 90 days, GitHub automatically deletes the binary attachment to save server space, while your code history stays completely untouched.

# How it will look when you download it:
The next time you push code, GitHub will compile both versions. When the run finishes, you will see an artifact named play-store-builds at the bottom of the page.
When you download and unzip it, it will cleanly contain:
- **app.aab:** Your official store asset.
- **app-release.apk:** Your shareable app package that can be installed on any physical Android phone immediately.