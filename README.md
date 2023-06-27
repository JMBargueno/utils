# Utils

## Scripts

### Install Apps

This scripts install all necesary apps for a geek.

```shell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/JMBargueno/utils/main/scripts/installApps/index.ps1'))
```
